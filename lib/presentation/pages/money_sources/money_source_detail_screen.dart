import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/money_source.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/dashboard/sparkline.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show NavArrowLeft;

class MoneySourceDetailScreen extends StatefulWidget {
  final String sourceId;
  const MoneySourceDetailScreen({super.key, required this.sourceId});

  @override
  State<MoneySourceDetailScreen> createState() => _MoneySourceDetailScreenState();
}

class _MoneySourceDetailScreenState extends State<MoneySourceDetailScreen> {
  MoneySource? _source;
  List<Transaction> _transactions = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final profile = authState.profile;
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(profile.id);
    if (household == null) return;

    final (sources, _) = await AppDependencies.instance.moneySourceRepository
        .getMoneySources(
      householdId: household.id,
      viewMode: ViewMode.personal,
      userId: profile.id,
      activeOnly: false,
    );
    final source = sources.where((s) => s.id == widget.sourceId).firstOrNull;
    if (source == null || !mounted) return;

    final (transactions, _) = await AppDependencies.instance.transactionRepository
        .getTransactions(
      householdId: household.id,
      viewMode: ViewMode.household,
      userId: profile.id,
      moneySourceId: source.id,
      limit: 20,
    );
    if (!mounted) return;
    setState(() {
      _source = source;
      _transactions = transactions;
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
    final accent = _c(theme.primaryColor);
    final expense = _c(theme.colorRed);
    final income = _c(theme.colorGreen);

    final source = _source;
    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: SafeArea(
        child: source == null
            ? const Center(child: CupertinoActivityIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Row(
                    children: [
                      IconBtn(
                        icon: NavArrowLeft(width: 16, height: 16, color: fg),
                        surface: surface,
                        border: border,
                        onTap: context.pop,
                        size: 36,
                        radius: 10,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          source.name,
                          style: AppFonts.heading(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: fg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface,
                      border: Border.all(color: border, width: 1),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${source.institution ?? 'No institution'} · ${source.accountType.name}',
                          style: AppFonts.body(fontSize: 12, color: muted),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${source.currentBalance.toStringAsFixed(2)} ${source.currency}',
                          style: AppFonts.numeric(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: fg,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Sparkline(color: accent, height: 52),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Action logs', style: AppFonts.sectionLabel(color: muted)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: surface,
                      border: Border.all(color: border, width: 1),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                    ),
                    child: Column(
                      children: [
                        _row('Date', 'Action', 'Amount', muted, border),
                        for (final tx in _transactions.take(10))
                          _row(
                            _fmtDate(tx.date),
                            tx.type == TransactionType.income ? 'Income' : 'Expense',
                            '${tx.type == TransactionType.income ? '+' : '-'}${tx.amount.toStringAsFixed(2)} ${source.currency}',
                            tx.type == TransactionType.income ? income : expense,
                            border,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
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
