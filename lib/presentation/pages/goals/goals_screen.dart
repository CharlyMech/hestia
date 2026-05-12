import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/goals/goals_bloc.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:hestia/presentation/widgets/dashboard/progress_ring.dart';
import 'package:hestia/presentation/widgets/goals/goal_form_content.dart';
import 'package:hestia/presentation/widgets/goals/goal_progress_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Plus;
import 'package:skeletonizer/skeletonizer.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
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

    if (auth is! AuthAuthenticated || _resolving || _householdId == null) {
      final theme = context.myTheme;
      final bg = _c(theme.backgroundColor);
      final border = _c(theme.borderColor);
      final fg = _c(theme.onBackgroundColor);
      final muted = _c(theme.onInactiveColor);
      final surface = _c(theme.surfaceColor);

      Widget body = auth is! AuthAuthenticated
          ? Center(
              child: Text(
                'Sign in to view goals',
                style: AppFonts.body(fontSize: 14, color: muted),
              ),
            )
          : Skeletonizer(
              enabled: true,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Text(
                    '0 active goals',
                    style: AppFonts.body(fontSize: 13, color: muted),
                  ),
                  const SizedBox(height: 200),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                    ),
                  ),
                ],
              ),
            );

      return CupertinoPushedRouteShell(
        backgroundColor: bg,
        navBackground: surface,
        borderColor: border,
        foregroundColor: fg,
        titleText: 'Goals',
        child: body,
      );
    }

    return BlocProvider(
      create: (_) => GoalsBloc(AppDependencies.instance.goalRepository)
        ..add(GoalsLoad(
          householdId: _householdId!,
          userId: auth.profile.id,
        )),
      child: _Body(
        householdId: _householdId!,
        userId: auth.profile.id,
      ),
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
  int _filter = 0; // 0=All 1=Household 2=Personal
  List<BankAccount> _moneySources = const [];

  @override
  void initState() {
    super.initState();
    _loadMoneySources();
  }

  Future<void> _loadMoneySources() async {
    final (sources, _) =
        await AppDependencies.instance.bankAccountRepository.getBankAccounts(
      householdId: widget.householdId,
      viewMode: ViewMode.household,
      userId: widget.userId,
    );
    if (!mounted) return;
    setState(() => _moneySources = sources);
  }

  Future<void> _openGoalSheet({FinancialGoal? existing, String? prefilled}) {
    return showAppBottomSheet<void>(
      context: context,
      title: existing == null ? 'New goal' : 'Edit goal',
      heightFactor: 0.92,
      child: BlocProvider.value(
        value: context.read<GoalsBloc>(),
        child: GoalFormContent(
          existing: existing,
          householdId: widget.householdId,
          userId: widget.userId,
          prefilledBankAccountId: prefilled,
          bankAccounts: _moneySources,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final surface2 = _c(theme.surface2Color);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final tints = theme.categoryTints.map(_c).toList();

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Goals',
      trailing: GestureDetector(
        onTap: () => _openGoalSheet(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: const Center(
            child: Plus(
              width: 18,
              height: 18,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
      child: BlocBuilder<GoalsBloc, GoalsState>(
        builder: (context, state) {
          if (state is GoalsLoading || state is GoalsInitial) {
            return Skeletonizer(
              enabled: true,
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Text(
                        '0 active goals',
                        style: AppFonts.body(fontSize: 13, color: muted),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 200)),
                ],
              ),
            );
          }
          if (state is GoalsError) {
            return ScreenShell(
              bg: bg,
              slivers: [
                SliverFillRemaining(
                  child: Center(
                    child: Text(state.message,
                        style: AppFonts.body(fontSize: 13, color: muted)),
                  ),
                ),
              ],
            );
          }
          final loaded = state as GoalsLoaded;
          final filtered = switch (_filter) {
            1 => loaded.household,
            2 => loaded.personal,
            _ => loaded.goals,
          };

          return ScreenShell(
            bg: bg,
            onRefresh: () async {
              final bloc = context.read<GoalsBloc>();
              bloc.add(GoalsRefresh());
              await bloc.stream.firstWhere((s) => s is! GoalsLoading);
            },
            slivers: [
              SliverToBoxAdapter(
                child: _GoalsSubtitle(
                  muted: muted,
                  total: loaded.goals.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SummaryCard(
                    progress: loaded.overallProgress,
                    current: loaded.totalCurrent,
                    target: loaded.totalTarget,
                    currency: loaded.goals.firstOrNull?.currency ?? 'EUR',
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                    accent: accent,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    spacing: 6,
                    children: [
                      _Pill(
                        label: 'All',
                        active: _filter == 0,
                        onTap: () => setState(() => _filter = 0),
                        surface: surface2,
                        border: border,
                        muted: muted,
                        fg: fg,
                      ),
                      _Pill(
                        label: 'Household',
                        active: _filter == 1,
                        onTap: () => setState(() => _filter = 1),
                        surface: surface2,
                        border: border,
                        muted: muted,
                        fg: fg,
                      ),
                      _Pill(
                        label: 'Personal',
                        active: _filter == 2,
                        onTap: () => setState(() => _filter = 2),
                        surface: surface2,
                        border: border,
                        muted: muted,
                        fg: fg,
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No goals yet',
                      style: AppFonts.body(fontSize: 13, color: muted),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final g = filtered[i];
                      return GoalProgressCard(
                        goal: g,
                        color: _goalColor(g, accent, tints),
                        surface: surface,
                        border: border,
                        fg: fg,
                        muted: muted,
                        onTap: () => _openGoalSheet(existing: g),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Color _goalColor(FinancialGoal g, Color accent, List<Color> tints) {
    if (g.color != null) {
      return Color(int.parse(g.color!.replaceFirst('#', '0xff')));
    }
    if (tints.isEmpty) return accent;
    final idx = g.id.hashCode.abs() % tints.length;
    return tints[idx];
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _GoalsSubtitle extends StatelessWidget {
  final Color muted;
  final int total;

  const _GoalsSubtitle({
    required this.muted,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Text(
        '$total active',
        style: AppFonts.body(fontSize: 13, color: muted),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double progress;
  final double current;
  final double target;
  final String currency;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;

  const _SummaryCard({
    required this.progress,
    required this.current,
    required this.target,
    required this.currency,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Row(
        spacing: 16,
        children: [
          ProgressRing(
            value: progress,
            size: 68,
            stroke: 6,
            color: accent,
            trackColor: border,
            child: Text(
              '${(progress * 100).round()}%',
              style: AppFonts.numeric(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  'Overall progress',
                  style: AppFonts.body(fontSize: 12, color: muted),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: 4,
                  children: [
                    Text(
                      '${current.toStringAsFixed(0)}$currency',
                      style: AppFonts.numeric(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    Text(
                      '/ ${target.toStringAsFixed(0)}$currency',
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color surface;
  final Color border;
  final Color muted;
  final Color fg;

  const _Pill({
    required this.label,
    required this.active,
    required this.onTap,
    required this.surface,
    required this.border,
    required this.muted,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? surface : const Color(0x00000000),
          border: Border.all(
            color:
                active ? muted.withValues(alpha: 0.4) : const Color(0x00000000),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppFonts.body(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: active ? fg : muted,
          ),
        ),
      ),
    );
  }
}
