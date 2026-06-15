import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_lists_bloc.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/animated_pill_tabs.dart';

import 'package:hestia/presentation/widgets/common/dotted_border.dart';
import 'package:hestia/presentation/widgets/shopping/shopping_list_form.dart';
import 'package:hestia/presentation/widgets/shopping/start_shopping_session_sheet.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show CartAlt, PlaySolid;
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
  /// 0 Sessions · 1 Templates · 2 History
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
    final bloc = context.read<ShoppingListsBloc>();
    await showAppBottomSheet<void>(
      context: context,
      title: template == null
          ? AppLocalizations.of(context).shopping_startSession
          : AppLocalizations.of(context).shopping_startFromTemplate,
      heightFactor: 0.88,
      expand: true,
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
        }) {
          bloc.add(ShoppingListsStartSession(
            name: name,
            scope: scope,
            bankAccountId: bankAccountId,
            transactionSourceId: transactionSourceId,
            templateListId: templateListId,
          ));
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    );
    if (context.mounted) bloc.add(ShoppingListsRefresh());
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
      heightFactor: 0.88,
      expand: true,
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
                        AnimatedButton(
                          size: 32,
                          padding: const EdgeInsets.all(4),
                          onTap: () => _openStartSession(context),
                          child: PlaySolid(width: 22, height: 22, color: fg),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state is ShoppingListsLoaded &&
                    state.activeSessions.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _ActiveSessionBanner(
                        list: state.activeSessions.first,
                        surface: surface,
                        border: border,
                        fg: fg,
                        muted: muted,
                        accent: accent,
                        onOpen: () async {
                          final bloc = context.read<ShoppingListsBloc>();
                          await context.push(
                            AppRoutes.shoppingListDetail,
                            extra: state.activeSessions.first,
                          );
                          if (context.mounted) {
                            bloc.add(ShoppingListsRefresh());
                          }
                        },
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedPillTabs(
                      labels: [
                        l10n.shopping_sessionsTab,
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
    if (_segment == 0) {
      final lists = loaded.activeSessions;
      if (lists.isEmpty) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  CartAlt(width: 44, height: 44, color: muted),
                  Text(
                    AppLocalizations.of(context).shopping_noActiveSessions,
                    style: AppFonts.body(fontSize: 13, color: muted),
                  ),
                ],
              ),
            ),
          ),
        ];
      }
      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          sliver: SliverList.separated(
            itemCount: lists.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ListTile(
              list: lists[i],
              surface: surface,
              border: border,
              fg: fg,
              muted: muted,
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
    if (_segment == 1) {
      final templates = loaded.templates;
      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          sliver: SliverList.separated(
            itemCount: templates.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              if (i == templates.length) {
                return _CreateTemplateTile(
                  border: accent.withValues(alpha: 0.7),
                  muted: muted,
                  onTap: () => _openCreateTemplate(context),
                );
              }
              return _ListTile(
                list: templates[i],
                surface: surface,
                border: border,
                fg: fg,
                muted: muted,
                template: true,
                onTap: () async {
                  final bloc = context.read<ShoppingListsBloc>();
                  await context.push(
                    AppRoutes.shoppingListDetail,
                    extra: templates[i],
                  );
                  if (!context.mounted) return;
                  bloc.add(ShoppingListsRefresh());
                },
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
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        sliver: SliverList.separated(
          itemCount: lists.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _ListTile(
            list: lists[i],
            surface: surface,
            border: border,
            fg: fg,
            muted: muted,
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

class _ActiveSessionBanner extends StatelessWidget {
  final ShoppingList list;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final VoidCallback onOpen;

  const _ActiveSessionBanner({
    required this.list,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final shared = list.scope == ShoppingListScope.shared;
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.play_circle_fill, size: 20, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    AppLocalizations.of(context)
                        .dashboard_activeShoppingSession,
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                  Text(
                    list.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                  if (shared)
                    Text(
                      AppLocalizations.of(context).shopping_sharedCollaboration,
                      style: AppFonts.body(fontSize: 11, color: muted),
                    ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_forward, size: 16, color: muted),
          ],
        ),
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
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final bool template;
  final VoidCallback onTap;

  const _ListTile({
    required this.list,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    this.template = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final accent = hexToColor(theme.primaryColor);
    final green = hexToColor(theme.colorGreen);
    final red = hexToColor(theme.colorRed);
    final tint = template
        ? accent
        : switch (list.status) {
            ShoppingListStatus.active => accent,
            ShoppingListStatus.paid => green,
            ShoppingListStatus.cancelled => red,
          };
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 8,
              height: 36,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(AppRadii.xs),
              ),
            ),
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
                    '$kindBit · ${list.scope.name} · $statusLabel',
                    style: AppFonts.body(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
