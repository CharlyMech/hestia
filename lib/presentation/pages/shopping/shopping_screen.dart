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
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/shopping/shopping_list_form_content.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show CartAlt, Plus;

/// Shopping index — Active and History segmentation. Tapping a list pushes
/// the detail screen; "+" opens the new-list bottom sheet.
class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  String? _householdId;
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    _resolveHousehold();
  }

  Future<void> _resolveHousehold() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      if (mounted) setState(() => _resolving = false);
      return;
    }
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (!mounted) return;
    setState(() {
      _householdId = household?.id;
      _resolving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    if (auth is! AuthAuthenticated || _resolving || _householdId == null) {
      return ColoredBox(
        color: bg,
        child: const SafeArea(
          bottom: false,
          child: Center(child: CupertinoActivityIndicator()),
        ),
      );
    }
    return BlocProvider(
      create: (_) => ShoppingListsBloc(
        AppDependencies.instance.shoppingRepository,
      )..add(ShoppingListsLoad(
          householdId: _householdId!,
          userId: auth.profile.id,
        )),
      child: _Body(householdId: _householdId!, userId: auth.profile.id),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Body extends StatefulWidget {
  final String householdId;
  final String userId;
  const _Body({required this.householdId, required this.userId});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  /// 0 = Active, 1 = History.
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);

    return ColoredBox(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<ShoppingListsBloc, ShoppingListsState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    final bloc = context.read<ShoppingListsBloc>();
                    bloc.add(ShoppingListsRefresh());
                    await bloc.stream
                        .firstWhere((s) => s is! ShoppingListsLoading);
                  },
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
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
                        IconBtn(
                          icon: Plus(width: 16, height: 16, color: fg),
                          surface: surface,
                          border: border,
                          onTap: () async {
                            final bloc = context.read<ShoppingListsBloc>();
                            await showAppBottomSheet<void>(
                              context: context,
                              title: l10n.shopping_newList,
                              heightFactor: 0.88,
                              expand: true,
                              child: ShoppingListFormContent(
                                householdId: widget.householdId,
                                userId: widget.userId,
                                onSuccess: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  bloc.add(ShoppingListsRefresh());
                                },
                              ),
                            );
                          },
                          size: 36,
                          radius: AppRadii.lg,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SegmentedControl(
                      options: const ['Active', 'History'],
                      active: _segment,
                      onChanged: (i) => setState(() => _segment = i),
                      surface: surface,
                      border: border,
                      fg: fg,
                      muted: muted,
                      activeColor: accent,
                      activeFg: CupertinoColors.white,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ..._buildBody(state, surface, border, fg, muted),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildBody(ShoppingListsState state, Color surface,
      Color border, Color fg, Color muted) {
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
    final lists = _segment == 0 ? loaded.active : loaded.history;
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
                  _segment == 0
                      ? 'No active lists — tap + to start one'
                      : 'No paid or cancelled lists yet',
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
              if (!mounted) return;
              bloc.add(ShoppingListsRefresh());
            },
          ),
        ),
      ),
    ];
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _ListTile extends StatelessWidget {
  final ShoppingList list;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final VoidCallback onTap;

  const _ListTile({
    required this.list,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final accent =
        Color(int.parse(theme.primaryColor.replaceFirst('#', '0xff')));
    final green =
        Color(int.parse(theme.colorGreen.replaceFirst('#', '0xff')));
    final red = Color(int.parse(theme.colorRed.replaceFirst('#', '0xff')));
    final tint = switch (list.status) {
      ShoppingListStatus.active => accent,
      ShoppingListStatus.paid => green,
      ShoppingListStatus.cancelled => red,
    };
    final statusLabel = switch (list.status) {
      ShoppingListStatus.active => 'Active',
      ShoppingListStatus.paid => 'Paid',
      ShoppingListStatus.cancelled => 'Cancelled',
    };
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: border, width: 1),
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
                    '${list.scope.name} · $statusLabel',
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
