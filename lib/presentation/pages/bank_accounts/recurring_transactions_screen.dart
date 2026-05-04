import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Sub-screen of money source detail. Lists every recurring transaction tied
/// to a single account: subscriptions, salaries, scheduled bills, etc.
class RecurringTransactionsScreen extends StatefulWidget {
  final String sourceId;
  const RecurringTransactionsScreen({super.key, required this.sourceId});

  @override
  State<RecurringTransactionsScreen> createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends State<RecurringTransactionsScreen> {
  BankAccount? _source;
  List<Transaction> _recurring = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final profile = auth.profile;
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
    final (txs, _) =
        await AppDependencies.instance.transactionRepository.getTransactions(
      householdId: household.id,
      viewMode: ViewMode.personal,
      userId: profile.id,
      bankAccountId: widget.sourceId,
      limit: 200,
    );
    if (!mounted) return;
    setState(() {
      _source = source;
      _recurring = txs.where((t) => t.isRecurring).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final income = _c(theme.colorGreen);
    final expense = _c(theme.colorRed);

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Recurring',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_source != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                _source!.name,
                style: AppFonts.body(fontSize: 13, color: muted),
              ),
            ),
          Expanded(
            child: _loading
                ? Skeletonizer(
                    enabled: true,
                    child: ListView(
                      padding:
                          const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        for (var i = 0; i < 5; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: surface,
                                border: Border.all(color: border),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.xl),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : _recurring.isEmpty
                    ? Center(
                        child: Text(
                          'No recurring transactions yet',
                          style: AppFonts.body(
                              fontSize: 13, color: muted),
                        ),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding:
                            const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        itemCount: _recurring.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final tx = _recurring[i];
                          final isIncome =
                              tx.type == TransactionType.income;
                          final tint = isIncome ? income : expense;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: surface,
                              border: Border.all(color: border, width: 1),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.xl),
                            ),
                            child: Row(
                              spacing: 12,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: tint,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 2,
                                    children: [
                                      Text(
                                        tx.note ??
                                            tx.categoryName ??
                                            'Recurring',
                                        style: AppFonts.body(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: fg,
                                        ),
                                      ),
                                      Text(
                                        '${_freqLabel(tx.recurringRule)} · ${tx.categoryName ?? '—'}',
                                        style: AppFonts.body(
                                            fontSize: 11, color: muted),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${isIncome ? '+' : '−'}${tx.amount.abs().toStringAsFixed(2)} ${_source?.currency ?? 'EUR'}',
                                  style: AppFonts.numeric(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: tint,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _freqLabel(Map<String, dynamic>? rule) {
    if (rule == null) return 'Recurring';
    final freq = rule['frequency'] ?? rule['interval'] ?? rule['type'];
    if (freq is String && freq.isNotEmpty) return freq;
    return 'Recurring';
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
