import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/transaction.dart';

/// Compact income/expense totals card for a given list of transactions.
/// Renders a stacked horizontal bar visualizing income share vs expense share.
class IncomeExpenseSummary extends StatelessWidget {
  final List<Transaction> transactions;
  final String currency;
  final Color income;
  final Color expense;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;

  const IncomeExpenseSummary({
    super.key,
    required this.transactions,
    required this.currency,
    required this.income,
    required this.expense,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    double inc = 0;
    double exp = 0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.income) {
        inc += tx.amount.abs();
      } else {
        exp += tx.amount.abs();
      }
    }
    final total = inc + exp;
    final incShare = total == 0 ? 0.5 : inc / total;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'Income',
                  value: '${inc.toStringAsFixed(0)} $currency',
                  color: income,
                  muted: muted,
                  fg: fg,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'Expense',
                  value: '${exp.toStringAsFixed(0)} $currency',
                  color: expense,
                  muted: muted,
                  fg: fg,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (incShare * 1000).round(),
                    child: ColoredBox(color: income),
                  ),
                  Expanded(
                    flex: ((1 - incShare) * 1000).round().clamp(1, 1000),
                    child: ColoredBox(color: expense),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color fg;
  final Color muted;
  final bool alignEnd;

  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    required this.fg,
    required this.muted,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            if (!alignEnd) _dot(color),
            Text(label, style: AppFonts.body(fontSize: 11, color: muted)),
            if (alignEnd) _dot(color),
          ],
        ),
        Text(
          value,
          style: AppFonts.numeric(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ],
    );
  }

  Widget _dot(Color c) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}
