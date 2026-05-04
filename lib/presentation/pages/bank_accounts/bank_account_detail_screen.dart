import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/goals/goals_bloc.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/goals/goal_form_content.dart';
import 'package:hestia/presentation/widgets/goals/goal_progress_card.dart';
import 'package:hestia/presentation/widgets/bank_accounts/balance_line_chart.dart';
import 'package:hestia/presentation/widgets/bank_accounts/income_expense_summary.dart';
import 'package:hestia/presentation/widgets/bank_accounts/monthly_io_bar_chart.dart';
import 'package:hestia/presentation/widgets/bank_accounts/wallet_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show NavArrowRight, Plus, ClockRotateRight;
import 'package:skeletonizer/skeletonizer.dart';

class BankAccountDetailScreen extends StatefulWidget {
  final String sourceId;
  const BankAccountDetailScreen({super.key, required this.sourceId});

  @override
  State<BankAccountDetailScreen> createState() => _BankAccountDetailScreenState();
}

class _BankAccountDetailScreenState extends State<BankAccountDetailScreen> {
  BankAccount? _source;
  List<Transaction> _transactions = const [];
  List<FinancialGoal> _goals = const [];
  List<BankAccount> _allSources = const [];
  String? _householdId;
  String? _userId;
  bool _notFound = false;
  GoalsBloc? _goalsBloc;

  /// Analytics window: 0 = current month, 1 = last 6 months, 2 = last 12 months.
  int _periodIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _goalsBloc?.close();
    super.dispose();
  }

  Future<void> _load() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final profile = authState.profile;
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(profile.id);
    if (household == null) return;

    final (sources, _) = await AppDependencies.instance.bankAccountRepository
        .getBankAccounts(
      householdId: household.id,
      viewMode: ViewMode.personal,
      userId: profile.id,
      activeOnly: false,
    );
    final source = sources.where((s) => s.id == widget.sourceId).firstOrNull;
    if (!mounted) return;
    if (source == null) {
      setState(() => _notFound = true);
      return;
    }

    final (transactions, _) = await AppDependencies.instance.transactionRepository
        .getTransactions(
      householdId: household.id,
      viewMode: ViewMode.personal,
      userId: profile.id,
      bankAccountId: source.id,
      limit: 500,
    );
    final (goals, _) = await AppDependencies.instance.goalRepository.getGoals(
      householdId: household.id,
      viewMode: ViewMode.personal,
      userId: profile.id,
    );
    if (!mounted) return;
    setState(() {
      _source = source;
      _transactions = transactions;
      _allSources = sources;
      _householdId = household.id;
      _userId = profile.id;
      _goals = goals.where((g) => g.bankAccountId == source.id).toList();
    });
  }

  ({DateTime start, DateTime end, int barMonths}) _periodBounds() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (_periodIndex) {
      1 => (
          start: DateTime(now.year, now.month - 5, 1),
          end: today,
          barMonths: 6,
        ),
      2 => (
          start: DateTime(now.year - 1, now.month, 1),
          end: today,
          barMonths: 12,
        ),
      _ => (
          start: DateTime(now.year, now.month, 1),
          end: today,
          barMonths: 1,
        ),
    };
  }

  String _periodShortLabel() => switch (_periodIndex) {
        1 => 'Last 6 months',
        2 => 'Last 12 months',
        _ => 'This month',
      };

  List<Transaction> _transactionsInPeriod() {
    final p = _periodBounds();
    final list = _transactions.where((tx) {
      final d = DateTime(tx.date.year, tx.date.month, tx.date.day);
      return !d.isBefore(p.start) && !d.isAfter(p.end);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> _openGoalSheet({FinancialGoal? existing}) async {
    if (_householdId == null || _userId == null) return;
    _goalsBloc ??= GoalsBloc(AppDependencies.instance.goalRepository)
      ..add(GoalsLoad(householdId: _householdId!, userId: _userId!));
    await showAppBottomSheet<void>(
      context: context,
      title: existing == null ? 'New goal' : 'Edit goal',
      heightFactor: 0.92,
      child: BlocProvider.value(
        value: _goalsBloc!,
        child: GoalFormContent(
          existing: existing,
          householdId: _householdId!,
          userId: _userId!,
          prefilledBankAccountId: widget.sourceId,
          bankAccounts: _allSources,
        ),
      ),
    );
    // Reload goals after CRUD operation completes.
    if (mounted) await _load();
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
    final expense = _c(theme.colorRed);
    final income = _c(theme.colorGreen);

    final source = _source;

    late final Widget body;
    late final String? barTitle;

    if (_notFound) {
      barTitle = null;
      body = Center(
        child: Text(
          'Account not found',
          style: AppFonts.body(fontSize: 13, color: muted),
        ),
      );
    } else if (source == null) {
      barTitle = 'Account';
      body = Skeletonizer(
        enabled: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              height: 148,
              decoration: BoxDecoration(
                color: surface,
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              alignment: Alignment.center,
              child: Text(
                'Loading',
                style: AppFonts.body(fontSize: 14, color: muted),
              ),
            ),
            const SizedBox(height: 16),
            Text('Period', style: AppFonts.sectionLabel(color: muted)),
            const SizedBox(height: 8),
            SizedBox(height: 36),
            Text('Balance · this month', style: AppFonts.sectionLabel(color: muted)),
            const SizedBox(height: 200),
            Text('Goals', style: AppFonts.sectionLabel(color: muted)),
          ],
        ),
      );
    } else {
      barTitle = source.name;
      body = Builder(
        builder: (context) {
          final filteredTxs = _transactionsInPeriod();
          final p = _periodBounds();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
                          WalletCard(source: source),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Period',
                                  style: AppFonts.sectionLabel(color: muted),
                                ),
                              ),
                              Text(
                                _periodShortLabel(),
                                style: AppFonts.body(
                                    fontSize: 11, color: muted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SegmentedControl(
                            options: const ['Month', '6 months', '1 year'],
                            active: _periodIndex,
                            onChanged: (i) =>
                                setState(() => _periodIndex = i),
                            surface: surface,
                            border: border,
                            fg: fg,
                            muted: muted,
                            activeColor: accent,
                            activeFg: CupertinoColors.white,
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: surface,
                              border: Border.all(color: border, width: 1),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.xl),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Text(
                                  'Balance · ${_periodShortLabel().toLowerCase()}',
                                  style: AppFonts.sectionLabel(color: muted),
                                ),
                                BalanceLineChart(
                                  transactions: filteredTxs,
                                  currentBalance: source.currentBalance,
                                  line: accent,
                                  grid: border,
                                  axis: muted,
                                  tooltipBg: fg,
                                  tooltipFg: bg,
                                  currency: source.currency,
                                  windowStart: p.start,
                                  windowEnd: p.end,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          IncomeExpenseSummary(
                            transactions: filteredTxs,
                            currency: source.currency,
                            income: income,
                            expense: expense,
                            surface: surface,
                            border: border,
                            fg: fg,
                            muted: muted,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: surface,
                              border: Border.all(color: border, width: 1),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.xl),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Text(
                                  'Income vs expense · ${_periodShortLabel().toLowerCase()}',
                                  style: AppFonts.sectionLabel(color: muted),
                                ),
                                MonthlyIoBarChart(
                                  transactions: filteredTxs,
                                  income: income,
                                  expense: expense,
                                  axis: muted,
                                  grid: border,
                                  tooltipBg: fg,
                                  tooltipFg: bg,
                                  currency: source.currency,
                                  months: p.barMonths,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => context.push(
                              AppRoutes.recurringTransactions,
                              extra: source.id,
                            ),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: surface,
                                border: Border.all(color: border, width: 1),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.xl),
                              ),
                              child: Row(
                                spacing: 12,
                                children: [
                                  ClockRotateRight(
                                      width: 18,
                                      height: 18,
                                      color: accent),
                                  Expanded(
                                    child: Text(
                                      'Recurring transactions',
                                      style: AppFonts.body(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: fg,
                                      ),
                                    ),
                                  ),
                                  NavArrowRight(
                                      width: 14,
                                      height: 14,
                                      color: muted),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Goals on this account',
                                  style: AppFonts.sectionLabel(color: muted),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _openGoalSheet(),
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  spacing: 4,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Plus(
                                        width: 14,
                                        height: 14,
                                        color: accent),
                                    Text(
                                      'Add goal',
                                      style: AppFonts.body(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_goals.isEmpty)
                            GestureDetector(
                              onTap: () => _openGoalSheet(),
                              behavior: HitTestBehavior.opaque,
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
                                    'No goals yet — tap to add one',
                                    style: AppFonts.body(
                                        fontSize: 12, color: muted),
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              spacing: 10,
                              children: [
                                for (final g in _goals)
                                  GoalProgressCard(
                                    goal: g,
                                    color: g.color != null
                                        ? Color(int.parse(g.color!
                                            .replaceFirst('#', '0xff')))
                                        : accent,
                                    surface: surface,
                                    border: border,
                                    fg: fg,
                                    muted: muted,
                                    onTap: () =>
                                        _openGoalSheet(existing: g),
                                  ),
                              ],
                            ),
                          const SizedBox(height: 18),
                          Text(
                            'Action logs',
                            style: AppFonts.sectionLabel(color: muted),
                          ),
                          const SizedBox(height: 8),
                          if (filteredTxs.isEmpty)
                            Container(
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
                                  'No activity in this window',
                                  style: AppFonts.body(
                                      fontSize: 12, color: muted),
                                ),
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: surface,
                                border: Border.all(color: border, width: 1),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.xl),
                              ),
                              child: Column(
                                children: [
                                  _row('Date', 'Action', 'Amount', muted,
                                      border),
                                  for (final tx in filteredTxs.take(50))
                                    _row(
                                      _fmtDate(tx.date),
                                      tx.type == TransactionType.income
                                          ? 'Income'
                                          : 'Expense',
                                      '${tx.type == TransactionType.income ? '+' : '-'}${tx.amount.toStringAsFixed(2)} ${source.currency}',
                                      tx.type == TransactionType.income
                                          ? income
                                          : expense,
                                      border,
                                    ),
                                ],
                              ),
                            ),
            ],
          );
        },
      );
    }

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: barTitle,
      child: body,
    );
  }

  Widget _row(String c1, String c2, String c3, Color c3Color, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(c1)),
          Expanded(child: Text(c2)),
          Expanded(
            child: Text(
              c3,
              textAlign: TextAlign.right,
              style: TextStyle(color: c3Color),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
