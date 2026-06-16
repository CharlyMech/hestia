import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_session.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_lists_bloc.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_sessions_bloc.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/animated_pill_tabs.dart';

import 'package:hestia/presentation/widgets/common/dotted_border.dart';
import 'package:hestia/presentation/widgets/shopping/shopping_list_form.dart';
import 'package:hestia/presentation/widgets/shopping/start_shopping_session_sheet.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show CartAlt, PlaySolid;
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shopping index — sessions, templates, and history.
class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    if (auth is! AuthAuthenticated) {
      return ColoredBox(
        color: bg,
        child: const SafeArea(
          bottom: false,
          child: Center(child: CupertinoActivityIndicator()),
        ),
      );
    }
    return _Body(userId: auth.profile.id);
  }
}

class _Body extends StatefulWidget {
  final String userId;
  const _Body({required this.userId});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  /// 0 Templates · 1 History
  int _segment = 0;
  bool _refreshing = false;
  RealtimeChannel? _householdChannel;
  String? _subscribedHouseholdId;

  @override
  void dispose() {
    AppDependencies.instance.shoppingRealtimeService
        .unsubscribe(_householdChannel);
    super.dispose();
  }

  void _syncHouseholdSubscription(String? householdId) {
    if (householdId == null || householdId == _subscribedHouseholdId) return;
    AppDependencies.instance.shoppingRealtimeService
        .unsubscribe(_householdChannel);
    _subscribedHouseholdId = householdId;
    _householdChannel = AppDependencies.instance.shoppingRealtimeService
        .subscribeToHouseholdShopping(
      householdId: householdId,
      onChanged: () {
        if (!mounted) return;
        context.read<ShoppingListsBloc>().add(const ShoppingListsRemoteSync());
        context
            .read<ShoppingSessionsBloc>()
            .add(const ShoppingSessionsRemoteSync());
      },
    );
  }

  Future<void> _onPullRefresh(BuildContext context) async {
    setState(() => _refreshing = true);
    try {
      final bloc = context.read<ShoppingListsBloc>();
      final start = bloc.state;
      final startRev = start is ShoppingListsLoaded ? start.revision : -1;
      bloc.add(ShoppingListsRefresh());
      await bloc.stream.firstWhere((s) {
        if (s is ShoppingListsLoaded) return s.revision > startRev;
        if (s is ShoppingListsError) return true;
        return false;
      });
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _openStartSession(
    BuildContext context, {
    ShoppingList? template,
  }) async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (household == null || !context.mounted) return;
    final sessionsBloc = context.read<ShoppingSessionsBloc>();
    await showAppBottomSheet<void>(
      context: context,
      title: template == null
          ? AppLocalizations.of(context).shopping_startSession
          : AppLocalizations.of(context).shopping_startFromTemplate,
      child: StartShoppingSessionSheet(
        householdId: household.id,
        userId: widget.userId,
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
            userId: widget.userId,
            name: name,
            scope: scope,
            bankAccountId: bankAccountId,
            transactionSourceId: transactionSourceId,
            templateId: templateListId,
            sharedWithUserIds: sharedWithUserIds,
          );
          sessionsBloc.add(ShoppingSessionsRefresh());
          if (session != null && context.mounted) {
            await context.push(AppRoutes.shoppingListDetail, extra: session);
            if (context.mounted) sessionsBloc.add(ShoppingSessionsRefresh());
          }
        },
      ),
    );
    if (context.mounted) sessionsBloc.add(ShoppingSessionsRefresh());
  }

  Future<void> _openCreateTemplate(BuildContext context) async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (household == null || !context.mounted) return;
    final bloc = context.read<ShoppingListsBloc>();
    await showAppBottomSheet<void>(
      context: context,
      title: AppLocalizations.of(context).shopping_newTemplate,
      child: ShoppingListForm(
        householdId: household.id,
        userId: widget.userId,
        asTemplate: true,
        onSuccess: () {
          Navigator.of(context, rootNavigator: true).pop();
          bloc.add(ShoppingListsRefresh());
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

    final topInset = MediaQuery.viewPaddingOf(context).top;
    return ColoredBox(
      color: bg,
      child: BlocConsumer<ShoppingListsBloc, ShoppingListsState>(
        listenWhen: (prev, next) =>
            context.read<ShoppingListsBloc>().householdId !=
            _subscribedHouseholdId,
        listener: (context, state) {
          _syncHouseholdSubscription(
            context.read<ShoppingListsBloc>().householdId,
          );
        },
        builder: (context, state) {
          _syncHouseholdSubscription(
            context.read<ShoppingListsBloc>().householdId,
          );
          return Skeletonizer(
            enabled: _refreshing,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () => _onPullRefresh(context),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 0),
                    child: Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.shopping_title,
                            style: AppFonts.heading(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                        ),
                        BlocBuilder<ShoppingSessionsBloc,
                            ShoppingSessionsState>(
                          builder: (context, sessionsState) {
                            final count =
                                sessionsState is ShoppingSessionsLoaded
                                    ? sessionsState.activeCount
                                    : 0;
                            return _ActiveSessionsButton(
                              activeCount: count,
                              surface: primary,
                              fg: onPrimary,
                              red: hexToColor(theme.colorRed),
                              onRed: hexToColor(theme.onRedColor),
                              onTap: () async {
                                final bloc =
                                    context.read<ShoppingSessionsBloc>();
                                await context.push(
                                  AppRoutes.activeShoppingSessions,
                                  extra: bloc,
                                );
                                if (context.mounted) {
                                  bloc.add(ShoppingSessionsRefresh());
                                }
                              },
                            );
                          },
                        ),
                        AnimatedButton(
                          backgroundColor: primary,
                          size: 32,
                          padding: const EdgeInsets.all(4),
                          onTap: () => _openStartSession(context),
                          child: PlaySolid(
                              width: 22, height: 22, color: onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AnimatedPillTabs(
                      labels: [
                        l10n.shopping_templatesTab,
                        l10n.shopping_history,
                      ],
                      selectedIndex: _segment,
                      onChanged: (i) => setState(() => _segment = i),
                      surface: surface,
                      border: border,
                      fg: fg,
                      muted: muted,
                      pillColor: accent,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ..._buildBody(
                    context, state, surface, border, fg, muted, accent),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildBody(
    BuildContext context,
    ShoppingListsState state,
    Color surface,
    Color border,
    Color fg,
    Color muted,
    Color accent,
  ) {
    if (state is ShoppingListsLoading || state is ShoppingListsInitial) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CupertinoActivityIndicator()),
        ),
      ];
    }
    if (state is ShoppingListsError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(state.message,
                style: AppFonts.body(fontSize: 13, color: muted)),
          ),
        ),
      ];
    }
    final loaded = state as ShoppingListsLoaded;
    final sessionsState = context.watch<ShoppingSessionsBloc>().state;
    final activeSessions = sessionsState is ShoppingSessionsLoaded
        ? sessionsState.active
        : const <ShoppingSession>[];
    if (_segment == 0) {
      final templates = loaded.templates;
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverList.separated(
            itemCount: templates.length + 1,
            separatorBuilder: (_, i) => i < templates.length - 1
                ? Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    color: border.withValues(alpha: 0.5),
                  )
                : const SizedBox.shrink(),
            itemBuilder: (_, i) {
              if (i == templates.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: _CreateTemplateTile(
                    border: accent.withValues(alpha: 0.7),
                    muted: muted,
                    onTap: () => _openCreateTemplate(context),
                  ),
                );
              }
              final template = templates[i];
              final hasActive =
                  activeSessions.any((s) => s.templateId == template.id);
              return _ListTile(
                list: template,
                fg: fg,
                muted: muted,
                template: true,
                hasActiveSession: hasActive,
                itemCount: loaded.itemCounts[template.id],
                onTap: () async {
                  final bloc = context.read<ShoppingListsBloc>();
                  await context.push(
                    AppRoutes.shoppingListDetail,
                    extra: template,
                  );
                  if (!context.mounted) return;
                  bloc.add(ShoppingListsRefresh());
                },
                onStartSession: () => _openStartSession(context, template: template),
              );
            },
          ),
        ),
      ];
    }
    final lists = loaded.sessionHistory;
    if (lists.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              AppLocalizations.of(context).shopping_noFinishedSessions,
              style: AppFonts.body(fontSize: 13, color: muted),
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: SliverList.separated(
          itemCount: lists.length,
          separatorBuilder: (_, i) => i < lists.length - 1
              ? Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  color: border.withValues(alpha: 0.5),
                )
              : const SizedBox.shrink(),
          itemBuilder: (_, i) => _ListTile(
            list: lists[i],
            fg: fg,
            muted: muted,
            itemCount: loaded.itemCounts[lists[i].id],
            onTap: () async {
              final bloc = context.read<ShoppingListsBloc>();
              await context.push(
                AppRoutes.shoppingListDetail,
                extra: lists[i],
              );
              if (!context.mounted) return;
              bloc.add(ShoppingListsRefresh());
            },
          ),
        ),
      ),
    ];
  }
}

/// Cart button beside the title; shows a red badge with count when sessions are active.
class _ActiveSessionsButton extends StatelessWidget {
  final int activeCount;
  final Color surface;
  final Color fg;
  final Color red;
  final Color onRed;
  final VoidCallback onTap;

  const _ActiveSessionsButton({
    required this.activeCount,
    required this.surface,
    required this.fg,
    required this.red,
    required this.onRed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasActive = activeCount > 0;
    return AnimatedButton(
      backgroundColor: surface,
      size: 32,
      padding: const EdgeInsets.all(4),
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CartAlt(width: 20, height: 20, color: fg),
          if (hasActive)
            Positioned(
              top: -4,
              right: -6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 14),
                height: 14,
                padding: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: red,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$activeCount',
                  style: AppFonts.label(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: onRed,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CreateTemplateTile extends StatelessWidget {
  final Color border;
  final Color muted;
  final VoidCallback onTap;

  const _CreateTemplateTile({
    required this.border,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 88,
        child: DottedBorder(
          color: border,
          radius: AppRadii.xl,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Icon(CupertinoIcons.add_circled, size: 22, color: muted),
                Text(
                  AppLocalizations.of(context).shopping_createTemplate,
                  style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final ShoppingList list;
  final Color fg;
  final Color muted;
  final bool template;
  final bool hasActiveSession;
  final int? itemCount;
  final VoidCallback onTap;
  final VoidCallback? onStartSession;

  const _ListTile({
    required this.list,
    required this.fg,
    required this.muted,
    this.template = false,
    this.hasActiveSession = false,
    this.itemCount,
    required this.onTap,
    this.onStartSession,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final green = hexToColor(theme.colorGreen);
    final border = hexToColor(theme.borderColor);
    final surface = hexToColor(theme.surfaceColor);
    final accent = hexToColor(theme.primaryColor);
    final onPrimary = hexToColor(theme.onPrimaryColor);
    final statusLabel = template
        ? l10n.shopping_kindTemplate
        : switch (list.status) {
            ShoppingListStatus.active => l10n.shopping_active,
            ShoppingListStatus.paid => l10n.shopping_statusPaid,
            ShoppingListStatus.cancelled => l10n.shopping_statusCancelled,
          };
    final kindBit = list.kind == ShoppingListKind.template
        ? l10n.shopping_kindTemplate
        : l10n.shopping_kindSession;
    final dateStr = DateFormat.MMMd().format(list.lastUpdate);
    final countBit =
        itemCount == null ? null : l10n.shopping_itemCount(itemCount!);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: border.withValues(alpha: 0.5), width: 0.8),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    list.name,
                    style: AppFonts.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                  Text(
                    [
                      kindBit,
                      list.scope.name,
                      statusLabel,
                      if (countBit != null) countBit,
                      dateStr,
                    ].join(' · '),
                    style: AppFonts.body(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
            if (hasActiveSession)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: green,
                  shape: BoxShape.circle,
                ),
              ),
            if (template && onStartSession != null && !hasActiveSession)
              AnimatedButton(
                backgroundColor: accent,
                size: 28,
                padding: const EdgeInsets.all(4),
                onTap: onStartSession!,
                child: PlaySolid(width: 16, height: 16, color: onPrimary),
              ),
          ],
        ),
      ),
    );
  }
}
