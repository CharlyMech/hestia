import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Material, ReorderableListView, ReorderableDelayedDragStartListener;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/domain/entities/shopping_session.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_list_bloc.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_sessions_bloc.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/layout/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/shopping/finish_session_flow.dart';
import 'package:hestia/presentation/widgets/shopping/shopping_item_card.dart';
import 'package:hestia/presentation/widgets/shopping/start_shopping_session_sheet.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Plus, Trash, Check, PlaySolid, FloppyDisk;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Detail screen for a single [ShoppingList]: items, add row, finish session,
/// or start a session from a template.
class ShoppingListDetailScreen extends StatelessWidget {
  /// Template mode (edits `shopping_lists` items).
  final ShoppingList? list;

  /// Session mode (edits `shopping_sessions` items, local or remote).
  final ShoppingSession? session;

  const ShoppingListDetailScreen({super.key, this.list})
      : session = null;
  const ShoppingListDetailScreen.session({super.key, required this.session})
      : list = null;

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies.instance;
    final asList = session?.toShoppingList() ?? list!;
    return BlocProvider(
      create: (_) {
        final bloc = ShoppingListBloc(
          deps.shoppingRepository,
          sessionRepo: deps.shoppingSessionRepository,
        );
        if (session != null) {
          bloc.add(ShoppingListLoadSession(session!));
        } else {
          bloc.add(ShoppingListLoad(list!));
        }
        return bloc;
      },
      child: _Body(list: asList, session: session),
    );
  }
}

class _Body extends StatefulWidget {
  final ShoppingList list;
  final ShoppingSession? session;
  const _Body({required this.list, this.session});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _newItemCtrl = TextEditingController();
  RealtimeChannel? _itemsChannel;
  String? _draggingItemId;
  bool _itemsChanged = false;

  bool get _isSession => widget.session != null;

  @override
  void initState() {
    super.initState();
    _subscribeToItems();
  }

  void _subscribeToItems() {
    final rt = AppDependencies.instance.shoppingRealtimeService;
    final session = widget.session;
    if (session != null) {
      // Personal sessions are local-only — no realtime. Shared sessions watch
      // their session_items.
      if (session.scope != ShoppingListScope.shared) return;
      _itemsChannel = rt.subscribeToSessionItems(
        sessionId: session.id,
        onChanged: () {
          if (!mounted) return;
          context.read<ShoppingListBloc>().add(const ShoppingListRemoteSync());
        },
      );
      return;
    }
    _itemsChannel = rt.subscribeToListItems(
      listId: widget.list.id,
      onChanged: () {
        if (!mounted) return;
        context.read<ShoppingListBloc>().add(const ShoppingListRemoteSync());
      },
    );
  }

  @override
  void dispose() {
    AppDependencies.instance.shoppingRealtimeService.unsubscribe(_itemsChannel);
    _newItemCtrl.dispose();
    super.dispose();
  }

  /// Top-bar finish action: native confirm, then the shared finish flow
  /// (template sync + save-as-template + optional transaction), then pop.
  Future<void> _onFinish(BuildContext context, ShoppingSession session) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.shopping_finishConfirmTitle),
        content: Text(l10n.shopping_finishConfirmBody),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.shopping_keepShopping),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.shopping_finish),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final finished = await FinishSessionFlow.finish(context, session: session);
    if (finished && context.mounted) {
      _refreshSessionsBloc(context);
      context.pop();
    }
  }

  Future<void> _onDelete(BuildContext context, ShoppingSession session) async {
    final deleted = await FinishSessionFlow.delete(context, session: session);
    if (deleted && context.mounted) {
      _refreshSessionsBloc(context);
      context.pop();
    }
  }

  /// Best-effort refresh of the sessions bloc if it's an ancestor of this route.
  void _refreshSessionsBloc(BuildContext context) {
    try {
      context.read<ShoppingSessionsBloc>().add(ShoppingSessionsRefresh());
    } catch (_) {
      /* not an ancestor on this route — index refreshes on return */
    }
  }

  Future<void> _openStartFromTemplate(
      BuildContext context, ShoppingList template) async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (household == null || !context.mounted) return;

    await showAppBottomSheet<void>(
      context: context,
      title: AppLocalizations.of(context).shopping_startFromTemplate,
      child: StartShoppingSessionSheet(
        householdId: household.id,
        userId: auth.profile.id,
        template: template,
        onStart: ({
          required String name,
          required ShoppingListScope scope,
          String? bankAccountId,
          String? transactionSourceId,
          String? templateListId,
          List<String> sharedWithUserIds = const [],
        }) async {
          Navigator.of(context, rootNavigator: true).pop();
          final (session, _) =
              await AppDependencies.instance.shoppingSessionRepository
                  .startSession(
            householdId: household.id,
            userId: auth.profile.id,
            name: name,
            scope: scope,
            bankAccountId: bankAccountId,
            transactionSourceId: transactionSourceId,
            templateId: templateListId,
            sharedWithUserIds: sharedWithUserIds,
          );
          if (session != null && context.mounted) {
            _refreshSessionsBloc(context);
            await context.push(AppRoutes.shoppingListDetail, extra: session);
            if (context.mounted) _refreshSessionsBloc(context);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final primary = hexToColor(theme.primaryColor);
    final onPrimary = hexToColor(theme.onPrimaryColor);
    final red = hexToColor(theme.colorRed);
    final onRed = hexToColor(theme.onStatusColor);

    return BlocBuilder<ShoppingListBloc, ShoppingListState>(
      builder: (context, state) {
        final loaded = state is ShoppingListLoaded ? state : null;
        final list = loaded?.list ?? widget.list;
        final items = loaded?.items ?? const <ShoppingListItem>[];
        final session = widget.session;
        final immutable = _isSession ? !session!.isActive : list.isImmutable;
        final isTemplate = !_isSession;
        final isActiveSession = _isSession && session!.isActive;

        return CupertinoPushedRouteShell(
          backgroundColor: bg,
          navBackground: surface,
          borderColor: border,
          foregroundColor: fg,
          titleText: list.name,
          trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    if (isTemplate && _itemsChanged)
                      AnimatedButton(
                        padding: const EdgeInsets.all(4),
                        backgroundColor: primary,
                        size: 32,
                        onTap: () => setState(() => _itemsChanged = false),
                        child: FloppyDisk(width: 18, height: 18, color: onPrimary),
                      ),
                    if (isTemplate)
                      AnimatedButton(
                        padding: const EdgeInsets.all(4),
                        backgroundColor: primary,
                        size: 32,
                        onTap: () => _openStartFromTemplate(context, list),
                        child: PlaySolid(width: 18, height: 18, color: onPrimary),
                      ),
                    if (isActiveSession) ...[
                      AnimatedButton(
                        padding: const EdgeInsets.all(4),
                        backgroundColor: red,
                        size: 32,
                        onTap: () => _onDelete(context, session),
                        child: Trash(width: 20, height: 20, color: onRed),
                      ),
                      AnimatedButton(
                        padding: const EdgeInsets.all(4),
                        size: 32,
                        backgroundColor: primary,
                        onTap: items.isEmpty
                            ? null
                            : () => _onFinish(context, session),
                        child: Check(width: 22, height: 22, color: onPrimary),
                      ),
                    ],
                  ],
                ),
          child: Column(
            children: [
              Expanded(
                child: state is ShoppingListLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.only(bottom: 16, top: 8),
                        buildDefaultDragHandles: false,
                        itemCount: items.length,
                        onReorderStart: (index) {
                          if (!immutable && index < items.length) {
                            setState(() => _draggingItemId = items[index].id);
                          }
                        },
                        onReorderEnd: (_) =>
                            setState(() => _draggingItemId = null),
                        onReorder: immutable
                            ? (_, __) {}
                            : (oldIndex, newIndex) {
                                setState(() {
                                  _draggingItemId = null;
                                  if (!_isSession) _itemsChanged = true;
                                });
                                context.read<ShoppingListBloc>().add(
                                      ShoppingListReorder(
                                        oldIndex: oldIndex,
                                        newIndex: newIndex,
                                      ),
                                    );
                              },
                        proxyDecorator: (child, index, anim) => AnimatedBuilder(
                          animation: anim,
                          builder: (_, __) => Material(
                            color: CupertinoColors.transparent,
                            elevation: 8 * anim.value,
                            shadowColor:
                                CupertinoColors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            child: Transform.scale(
                              scale: 1.0 + 0.03 * anim.value,
                              child: child,
                            ),
                          ),
                        ),
                        itemBuilder: (_, i) {
                          final item = items[i];
                          final isDragging = _draggingItemId != null;
                          final isThisOne = item.id == _draggingItemId;
                          final isLast = i == items.length - 1;
                          final card = KeyedSubtree(
                            key: ValueKey(item.id),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isDragging && !isThisOne ? 0.35 : 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.vertical(
                                    top: i == 0
                                        ? Radius.circular(AppRadii.lg)
                                        : Radius.zero,
                                    bottom: isLast
                                        ? Radius.circular(AppRadii.lg)
                                        : Radius.zero,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ShoppingItemCard(
                                      item: item,
                                      surface: CupertinoColors.transparent,
                                      fg: fg,
                                      muted: muted,
                                      accent: accent,
                                      red: red,
                                      disabled: immutable,
                                      onToggle: () => context
                                          .read<ShoppingListBloc>()
                                          .add(ShoppingListToggleItem(item.id)),
                                      onDelete: () {
                                        context
                                            .read<ShoppingListBloc>()
                                            .add(ShoppingListDeleteItem(item.id));
                                        if (!_isSession) setState(() => _itemsChanged = true);
                                      },
                                      onQtyChanged: (qty) => context
                                          .read<ShoppingListBloc>()
                                          .add(ShoppingListUpdateItem(
                                              item.copyWith(qty: qty))),
                                    ),
                                    if (!isLast)
                                      Container(
                                        height: 1,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        color: border.withValues(alpha: 0.5),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                          if (immutable || item.isChecked) return card;
                          return ReorderableDelayedDragStartListener(
                            key: ValueKey('drag-${item.id}'),
                            index: i,
                            child: card,
                          );
                        },
                      ),
              ),
              if (!immutable)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
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
                            child: FTextField(
                              controller: _newItemCtrl,
                              hint: l10n.shopping_addItem,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmit: _submitNewItem,
                            ),
                          ),
                          AnimatedButton(
                            backgroundColor: primary,
                            padding: const EdgeInsets.all(4.0),
                            onTap: () => _submitNewItem(_newItemCtrl.text),
                            child:
                                Plus(width: 28, height: 28, color: onPrimary),
                          ),
                        ],
                      ),
                      if (isTemplate)
                        SizedBox(
                          height: 50,
                          child: AnimatedButton(
                            backgroundColor: primary,
                            borderRadius: AppRadii.xl,
                            padding: EdgeInsets.zero,
                            onTap: () => _openStartFromTemplate(context, list),
                            child: Center(
                              child: Text(
                                l10n.shopping_startSession,
                                style: AppFonts.body(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: onPrimary,
                                ),
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
    if (!_isSession) setState(() => _itemsChanged = true);
  }
}
