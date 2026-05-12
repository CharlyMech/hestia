import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/category.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_list_bloc.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_lists_bloc.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/shopping/start_shopping_session_content.dart';
import 'package:hestia/presentation/widgets/transactions/transaction_form.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Plus, Trash, Check;

/// Detail screen for a single [ShoppingList]: items, add row, finish session,
/// or start a session from a template.
class ShoppingListDetailScreen extends StatelessWidget {
  final ShoppingList list;
  const ShoppingListDetailScreen({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ShoppingListBloc(AppDependencies.instance.shoppingRepository)
            ..add(ShoppingListLoad(list)),
      child: _Body(list: list),
    );
  }
}

class _Body extends StatefulWidget {
  final ShoppingList list;
  const _Body({required this.list});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _newItemCtrl = TextEditingController();

  @override
  void dispose() {
    _newItemCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmCancel(BuildContext context, ShoppingList list) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Cancel this shopping list?'),
        content: const Text(
            'Cancelling moves the list to History. This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel list'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      context.read<ShoppingListsBloc>().add(ShoppingListsCancel(list.id));
    } catch (_) {
      await AppDependencies.instance.shoppingRepository.updateList(
        list.copyWith(
          status: ShoppingListStatus.cancelled,
          sessionEndedAt: DateTime.now(),
        ),
      );
    }
    if (context.mounted) context.pop();
  }

  Future<void> _openFinishSession(
      BuildContext context, ShoppingList list) async {
    final auth = AppDependencies.instance.authRepository.currentUserId;
    if (auth == null) return;

    final deps = AppDependencies.instance;
    final (cats, _) = await deps.categoryRepository.getCategories(
      householdId: list.householdId,
    );
    Category? expenseCat;
    for (final c in cats) {
      if (c.type == TransactionType.expense) {
        expenseCat = c;
        break;
      }
    }
    expenseCat ??= cats.isNotEmpty ? cats.first : null;
    if (expenseCat == null || !context.mounted) return;

    final (accounts, _) = await deps.bankAccountRepository.getBankAccounts(
      householdId: list.householdId,
      viewMode: ViewMode.personal,
      userId: auth,
    );
    final bankId =
        list.bankAccountId ?? (accounts.isNotEmpty ? accounts.first.id : '');

    final initial = Transaction(
      id: '',
      householdId: list.householdId,
      userId: auth,
      categoryId: expenseCat.id,
      bankAccountId: bankId,
      transactionSourceId: list.transactionSourceId,
      amount: 0,
      type: TransactionType.expense,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      lastUpdate: DateTime.now(),
    );

    var paid = false;
    if (!context.mounted) return;
    await showAppBottomSheet<void>(
      context: context,
      title: 'Finish session',
      heightFactor: 0.92,
      expand: true,
      child: TransactionForm(
        householdId: list.householdId,
        userId: auth,
        initialTransaction: initial,
        onSubmitted: (tx) {
          paid = true;
          try {
            context.read<ShoppingListsBloc>().add(
                  ShoppingListsMarkPaid(listId: list.id, transactionId: tx.id),
                );
          } catch (_) {
            deps.shoppingRepository.updateList(
              list.copyWith(
                status: ShoppingListStatus.paid,
                transactionId: tx.id,
                paidAt: DateTime.now(),
                sessionEndedAt: DateTime.now(),
              ),
            );
          }
        },
      ),
    );
    if (paid && context.mounted) context.pop();
  }

  Future<void> _openStartFromTemplate(
      BuildContext context, ShoppingList template) async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (household == null || !context.mounted) return;

    ShoppingListsBloc? listsBloc;
    try {
      listsBloc = context.read<ShoppingListsBloc>();
    } catch (_) {
      listsBloc = null;
    }

    await showAppBottomSheet<void>(
      context: context,
      title: 'Start from template',
      heightFactor: 0.88,
      expand: true,
      child: StartShoppingSessionContent(
        householdId: household.id,
        userId: auth.profile.id,
        template: template,
        onStart: ({
          required String name,
          required ShoppingListScope scope,
          String? bankAccountId,
          String? transactionSourceId,
          String? templateListId,
        }) {
          if (listsBloc != null) {
            listsBloc.add(ShoppingListsStartSession(
              name: name,
              scope: scope,
              bankAccountId: bankAccountId,
              transactionSourceId: transactionSourceId,
              templateListId: templateListId,
            ));
          } else {
            AppDependencies.instance.shoppingRepository.startShoppingSession(
              householdId: household.id,
              userId: auth.profile.id,
              name: name,
              scope: scope,
              bankAccountId: bankAccountId,
              transactionSourceId: transactionSourceId,
              templateListId: templateListId,
            );
          }
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final destructive = _c(theme.colorRed);

    return BlocBuilder<ShoppingListBloc, ShoppingListState>(
      builder: (context, state) {
        final loaded = state is ShoppingListLoaded ? state : null;
        final list = loaded?.list ?? widget.list;
        final items = loaded?.items ?? const <ShoppingListItem>[];
        final immutable = list.isImmutable;
        final isTemplate = list.kind == ShoppingListKind.template;
        final showCancel = !immutable && !isTemplate;

        return CupertinoPushedRouteShell(
          backgroundColor: bg,
          navBackground: surface,
          borderColor: border,
          foregroundColor: fg,
          titleText: list.name,
          trailing: !showCancel
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(44, 36),
                    onPressed: () => _confirmCancel(context, list),
                    child: Trash(
                      width: 20,
                      height: 20,
                      color: destructive,
                    ),
                  ),
                ),
          child: Column(
            children: [
              Expanded(
                child: state is ShoppingListLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _ItemRow(
                          key: ValueKey(items[i].id),
                          item: items[i],
                          disabled: immutable,
                          surface: surface,
                          border: border,
                          fg: fg,
                          muted: muted,
                          accent: accent,
                          onToggle: () => context
                              .read<ShoppingListBloc>()
                              .add(ShoppingListToggleItem(items[i].id)),
                          onDelete: () => context
                              .read<ShoppingListBloc>()
                              .add(ShoppingListDeleteItem(items[i].id)),
                        ),
                      ),
              ),
              if (!immutable)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border(top: BorderSide(color: border, width: 1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: bg,
                                border: Border.all(color: border, width: 1),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.lg),
                              ),
                              child: CupertinoTextField(
                                controller: _newItemCtrl,
                                placeholder: 'Add an item…',
                                decoration: const BoxDecoration(),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                style: AppFonts.body(fontSize: 14, color: fg),
                                onSubmitted: _submitNewItem,
                              ),
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size.square(44),
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            color: accent,
                            onPressed: () => _submitNewItem(_newItemCtrl.text),
                            child: Plus(
                              width: 18,
                              height: 18,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                      if (isTemplate)
                        SizedBox(
                          height: 50,
                          child: CupertinoButton(
                            color: accent,
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                            padding: EdgeInsets.zero,
                            onPressed: () =>
                                _openStartFromTemplate(context, list),
                            child: Text(
                              'Start shopping session',
                              style: AppFonts.body(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 50,
                          child: CupertinoButton(
                            color: accent,
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                            padding: EdgeInsets.zero,
                            onPressed: items.isEmpty
                                ? null
                                : () => _openFinishSession(context, list),
                            child: Text(
                              'Finish session',
                              style: AppFonts.body(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _submitNewItem(String value) {
    final name = value.trim();
    if (name.isEmpty) return;
    context.read<ShoppingListBloc>().add(ShoppingListAddItem(name: name));
    _newItemCtrl.clear();
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _ItemRow extends StatelessWidget {
  final ShoppingListItem item;
  final bool disabled;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ItemRow({
    super.key,
    required this.item,
    required this.disabled,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final checked = item.isChecked;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: checked ? surface.withValues(alpha: 0.6) : surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        spacing: 12,
        children: [
          GestureDetector(
            onTap: disabled ? null : onToggle,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: checked ? accent : const Color(0x00000000),
                border: Border.all(
                  color: checked ? accent : const Color(0x00000000),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: checked
                  ? Center(
                      child: Check(
                        width: 14,
                        height: 14,
                        color: CupertinoColors.white,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: Text(
              item.qty > 1 ? '${item.qty}× ${item.name}' : item.name,
              style: AppFonts.body(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: checked ? muted : fg,
              ).copyWith(
                decoration:
                    checked ? TextDecoration.lineThrough : TextDecoration.none,
                decorationColor: muted,
              ),
            ),
          ),
          if (!disabled)
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Trash(width: 14, height: 14, color: muted),
              ),
            ),
        ],
      ),
    );
  }
}
