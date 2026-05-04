import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_list_bloc.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_lists_bloc.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/transactions/transaction_form.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Plus, Trash, Check;

/// Detail screen for a single [ShoppingList]: items list, add input, finish &
/// pay flow, cancel. Items animate to bottom on check (350ms delay).
class ShoppingListDetailScreen extends StatelessWidget {
  final ShoppingList list;
  const ShoppingListDetailScreen({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShoppingListBloc(AppDependencies.instance.shoppingRepository)
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
    // Reuse the index bloc if we can find it; else hit the repo directly.
    try {
      context.read<ShoppingListsBloc>().add(ShoppingListsCancel(list.id));
    } catch (_) {
      await AppDependencies.instance.shoppingRepository
          .updateList(list.copyWith(status: ShoppingListStatus.cancelled));
    }
    if (context.mounted) context.pop();
  }

  Future<void> _openFinishAndPay(
      BuildContext context, ShoppingList list, double subtotal) async {
    final auth =
        AppDependencies.instance.authRepository.currentUserId;
    if (auth == null) return;

    // Show the transaction form prefilled. Listen for `mounted` to know if
    // the form actually completed (success path) — if the user dismisses,
    // the list stays active.
    final beforeIds = await _transactionIdsForUser(auth);
    if (!context.mounted) return;
    await showAppBottomSheet<void>(
      context: context,
      title: 'Finish & pay',
      heightFactor: 0.92,
      expand: true,
      child: TransactionForm(
        householdId: list.householdId,
        userId: auth,
      ),
    );
    final afterIds = await _transactionIdsForUser(auth);
    final newId = afterIds.difference(beforeIds).firstOrNull;
    if (newId == null || !context.mounted) return;
    // Mark paid via the index bloc if mounted; otherwise direct repo write.
    try {
      context.read<ShoppingListsBloc>().add(
            ShoppingListsMarkPaid(listId: list.id, transactionId: newId),
          );
    } catch (_) {
      await AppDependencies.instance.shoppingRepository.updateList(
        list.copyWith(
          status: ShoppingListStatus.paid,
          transactionId: newId,
          paidAt: DateTime.now(),
        ),
      );
    }
    if (context.mounted) context.pop();
    // Silence unused subtotal — future revision will pre-fill the amount.
    // ignore: unused_local_variable
    final _ = subtotal;
  }

  Future<Set<String>> _transactionIdsForUser(String userId) async {
    final (txs, _) =
        await AppDependencies.instance.transactionRepository.getTransactions(
      householdId: widget.list.householdId,
      viewMode: ViewMode.household,
      userId: userId,
      limit: 200,
    );
    return txs.map((t) => t.id).toSet();
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

        return CupertinoPushedRouteShell(
          backgroundColor: bg,
          navBackground: surface,
          borderColor: border,
          foregroundColor: fg,
          titleText: list.name,
          trailing: immutable
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
                        padding:
                            const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              decoration: BoxDecoration(
                                color: bg,
                                border:
                                    Border.all(color: border, width: 1),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.lg),
                              ),
                              child: CupertinoTextField(
                                controller: _newItemCtrl,
                                placeholder: 'Add an item…',
                                decoration: const BoxDecoration(),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                style: AppFonts.body(
                                    fontSize: 14, color: fg),
                                onSubmitted: _submitNewItem,
                              ),
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size.square(44),
                            borderRadius:
                                BorderRadius.circular(AppRadii.lg),
                            color: accent,
                            onPressed: () =>
                                _submitNewItem(_newItemCtrl.text),
                            child: Plus(
                              width: 18,
                              height: 18,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                        child: CupertinoButton(
                          color: accent,
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          padding: EdgeInsets.zero,
                          onPressed: items.isEmpty
                              ? null
                              : () => _openFinishAndPay(
                                  context, list, 0),
                          child: Text(
                            'Finish & pay',
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
        border: Border.all(color: border, width: 1),
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
                  color: checked ? accent : border,
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
                decoration: checked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
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
