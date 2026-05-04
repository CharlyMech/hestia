import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:hestia/presentation/widgets/bank_accounts/wallet_card.dart';
import 'package:hestia/presentation/widgets/common/date_range_selector.dart';
import 'package:hestia/presentation/widgets/dashboard/balance_trend_line.dart';
import 'package:hestia/presentation/widgets/dashboard/range_cash_flow_bars.dart';
import 'package:hestia/presentation/widgets/dashboard/notifications_popover.dart';
import 'package:hestia/presentation/widgets/dashboard/spend_donut.dart';
import 'package:hestia/presentation/widgets/dashboard/tx_row.dart';
import 'package:hestia/presentation/widgets/goals/goal_progress_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Bell, Bank, CreditCard;
import 'package:skeletonizer/skeletonizer.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<String>? onOpenMoneySource;
  const DashboardScreen({super.key, this.onOpenMoneySource});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<BankAccount> _accounts = const [];
  List<Transaction> _allTransactions = const [];
  List<TxData> _recentTx = const [];
  List<Transaction> _recentTransactions = const [];
  List<FinancialGoal> _goals = const [];
  bool _loading = true;
  DateRangePreset _range = DateRangePreset.d30;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final profile = authState.profile;
    final deps = AppDependencies.instance;
    final (household, _) =
        await deps.householdRepository.getCurrentHousehold(profile.id);
    if (household == null) return;

    final (accounts, _) = await deps.bankAccountRepository.getBankAccounts(
      householdId: household.id,
      viewMode: ViewMode.personal,
      userId: profile.id,
    );
    final (transactions, _) = await deps.transactionRepository.getTransactions(
      householdId: household.id,
      viewMode: ViewMode.personal,
      userId: profile.id,
      limit: 500,
    );
    final (goals, _) = await deps.goalRepository.getGoals(
      householdId: household.id,
      viewMode: ViewMode.personal,
      userId: profile.id,
    );
    if (mounted) {
      context
          .read<NotificationsBloc>()
          .add(NotificationsLoad(profile.id));
    }

    final recentTransactions = transactions.take(6).toList();
    final recent =
        recentTransactions.map((tx) => _toTxData(tx, accounts)).toList();

    if (!mounted) return;
    setState(() {
      _accounts = accounts;
      _allTransactions = transactions;
      _recentTx = recent;
      _recentTransactions = recentTransactions;
      _goals = goals.where((g) => g.isActive).toList();
      _loading = false;
    });
  }

  List<Transaction> _txInRange() {
    final r = DateRange.fromPreset(_range);
    return _allTransactions
        .where((tx) => tx.date.isAfter(r.start) && tx.date.isBefore(r.end))
        .toList();
  }

  int _trendDays() => switch (_range) {
        DateRangePreset.d7 => 7,
        DateRangePreset.d30 => 30,
        DateRangePreset.d90 => 90,
        DateRangePreset.m6 => 180,
        DateRangePreset.y1 => 365,
        DateRangePreset.custom => 30,
      };

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final income = _c(theme.colorGreen);
    final expense = _c(theme.colorRed);
    final tints = theme.categoryTints.map(_c).toList();
    final auth = context.watch<AuthBloc>().state;
    final userId = auth is AuthAuthenticated ? auth.profile.id : '';
    final initials = auth is AuthAuthenticated
        ? _initials(auth.profile.displayName ?? auth.profile.email)
        : '··';

    return ColoredBox(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: _loading
            ? Skeletonizer(
                enabled: true,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding:
                      const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'User name goes here long',
                            style: AppFonts.heading(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'BANK ACCOUNTS',
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: muted,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 172,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 262,
                            height: 148,
                            decoration: BoxDecoration(
                              color: surface,
                              border: Border.all(color: border),
                              borderRadius: BorderRadius.circular(
                                  AppRadii.xl),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            'SPENDING',
                            style: AppFonts.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: muted,
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 220),
                      const SizedBox(height: 220),
                      Text(
                        'RECENT ACTIVITY placeholder',
                        style: AppFonts.body(
                          fontSize: 12,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  CupertinoSliverRefreshControl(onRefresh: _load),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 110),
                    sliver: SliverList.list(children: [
                      _Header(
                        fg: fg,
                        muted: muted,
                        surface: surface,
                        border: border,
                        accent: accent,
                        initials: initials,
                        userId: userId,
                        unreadCount:
                            (context.watch<NotificationsBloc>().state
                                    is NotificationsLoaded)
                                ? (context.watch<NotificationsBloc>().state
                                        as NotificationsLoaded)
                                    .unreadCount
                                : 0,
                      ),
                      const SizedBox(height: 20),
                      _SectionLabel(
                        label: 'Bank accounts',
                        muted: muted,
                      ),
                      const SizedBox(height: 12),
                      // Real WalletCard carousel.
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _accounts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            return SizedBox(
                              width: 280,
                              child: WalletCard(
                                source: _accounts[i],
                                index: i,
                                onTap: () =>
                                    (widget.onOpenMoneySource ??
                                            ((id) => context.push(
                                                AppRoutes.bankAccountDetail,
                                                extra: id)))
                                        .call(_accounts[i].id),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: DateRangeSelector(
                          selected: _range,
                          onChanged: (r) => setState(() => _range = r),
                          surface: surface,
                          border: border,
                          fg: fg,
                          muted: muted,
                          activeColor: accent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionLabel(
                        label: 'Spending',
                        muted: muted,
                        accent: accent,
                      ),
                      const SizedBox(height: 8),
                      _ChartCard(
                        surface: surface,
                        border: border,
                        child: SpendDonut(
                          transactions: _txInRange(),
                          fg: fg,
                          muted: muted,
                          border: border,
                          palette: tints,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ChartCard(
                        surface: surface,
                        border: border,
                        child: RangeCashFlowBars(
                          transactions: _txInRange(),
                          income: income,
                          expense: expense,
                          axis: muted,
                          grid: border,
                          fg: fg,
                          periodLabel: dateRangePresetShortLabel(_range),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ChartCard(
                        surface: surface,
                        border: border,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Text(
                              'Balance trend · ${_trendDays()}d',
                              style: AppFonts.sectionLabel(color: muted),
                            ),
                            BalanceTrendLine(
                              transactions: _allTransactions,
                              bankAccounts: _accounts,
                              line: accent,
                              grid: border,
                              axis: muted,
                              tooltipBg: fg,
                              tooltipFg: bg,
                              days: _trendDays(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel(
                        label: 'Active goals',
                        action: 'See all',
                        muted: muted,
                        accent: accent,
                        onTap: () => context.push(AppRoutes.goals),
                      ),
                      const SizedBox(height: 8),
                      if (_goals.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 18),
                            decoration: BoxDecoration(
                              color: surface,
                              border: Border.all(color: border, width: 1),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.xl),
                            ),
                            child: Center(
                              child: Text(
                                'No active goals — tap See all to create one',
                                style: AppFonts.body(
                                    fontSize: 12, color: muted),
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 86,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _goals.take(4).length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, i) {
                              final g = _goals[i];
                              final color = g.color != null
                                  ? Color(int.parse(
                                      g.color!.replaceFirst('#', '0xff')))
                                  : accent;
                              return SizedBox(
                                width: 240,
                                child: GoalProgressCard(
                                  goal: g,
                                  color: color,
                                  surface: surface,
                                  border: border,
                                  fg: fg,
                                  muted: muted,
                                  onTap: () =>
                                      context.push(AppRoutes.goals),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                      _SectionLabel(
                        label: 'Recent',
                        muted: muted,
                        accent: accent,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: surface,
                          border: Border.all(color: border, width: 1),
                          borderRadius:
                              BorderRadius.circular(AppRadii.xl),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (var i = 0; i < _recentTx.length; i++)
                              TxRow(
                                tx: _recentTx[i],
                                showDivider: i < _recentTx.length - 1,
                                onTap: () => context.push(
                                  AppRoutes.transactionDetail,
                                  extra: _recentTransactions[i],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '··';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  TxData _toTxData(Transaction tx, List<BankAccount> sources) {
    final source = sources.where((s) => s.id == tx.bankAccountId).firstOrNull;
    final isShared = source?.ownerType == OwnerType.shared;
    final icon = tx.type == TransactionType.income
        ? CreditCard(width: 18, height: 18, color: const Color(0xFF4CB782))
        : Bank(width: 18, height: 18, color: const Color(0xFF8B7AE6));
    return TxData(
      icon: icon,
      color: const Color(0xFF8B7AE6),
      title: tx.note ?? tx.categoryName ?? 'Transaction',
      category: tx.categoryName ?? tx.type.name,
      source: source?.name ?? tx.bankAccountName ?? 'Account',
      amount: tx.type == TransactionType.expense
          ? -tx.amount.abs()
          : tx.amount.abs(),
      shared: isShared,
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Header extends StatelessWidget {
  final Color fg;
  final Color muted;
  final Color surface;
  final Color border;
  final Color accent;
  final String initials;
  final String userId;
  final int unreadCount;

  const _Header({
    required this.fg,
    required this.muted,
    required this.surface,
    required this.border,
    required this.accent,
    required this.initials,
    required this.userId,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  'Welcome back',
                  style: AppFonts.body(fontSize: 13, color: muted),
                ),
                Text(
                  'Overview',
                  style: AppFonts.heading(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Bell with FPopover preview of latest unread notifications.
          FPopover.tappable(
            followerBuilder: (_, __, ___) =>
                NotificationsPopover(userId: userId),
            target: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: surface,
                border: Border.all(color: border, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Bell(width: 18, height: 18, color: fg),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 6,
                      right: 7,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: surface, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => context.push(AppRoutes.profile),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF8B7AE6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: AppFonts.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final String? action;
  final Color muted;
  final Color? accent;
  final VoidCallback? onTap;

  const _SectionLabel({
    required this.label,
    this.action,
    required this.muted,
    this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final linkColor = accent ?? muted;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: muted,
                letterSpacing: 1.0,
              ),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                action!,
                style: AppFonts.body(
                  fontSize: 12,
                  color: linkColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final Widget child;
  final Color surface;
  final Color border;

  const _ChartCard({
    required this.child,
    required this.surface,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: border, width: 1),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: child,
      ),
    );
  }
}
