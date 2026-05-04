import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/transaction.dart';

/// Income vs expense totals for the transactions in the current date range
/// (caller filters). Pairs with the dashboard time-range tabs.
class RangeCashFlowBars extends StatelessWidget {
  final List<Transaction> transactions;
  final Color income;
  final Color expense;
  final Color axis;
  final Color grid;
  final Color fg;
  final String periodLabel;
  final String currency;

  const RangeCashFlowBars({
    super.key,
    required this.transactions,
    required this.income,
    required this.expense,
    required this.axis,
    required this.grid,
    required this.fg,
    required this.periodLabel,
    this.currency = 'EUR',
  });

  ({double income, double expense}) _totals() {
    double inc = 0;
    double exp = 0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.income) {
        inc += tx.amount.abs();
      } else {
        exp += tx.amount.abs();
      }
    }
    return (income: inc, expense: exp);
  }

  String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k $currency';
    return '${v.toStringAsFixed(0)} $currency';
  }

  @override
  Widget build(BuildContext context) {
    final t = _totals();
    final maxY = (t.income > t.expense ? t.income : t.expense) * 1.15;
    final cap = maxY < 1 ? 1.0 : maxY;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          'Cash flow · $periodLabel',
          style: AppFonts.sectionLabel(color: axis),
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    'Income',
                    style: AppFonts.body(fontSize: 11, color: axis),
                  ),
                  Text(
                    _fmt(t.income),
                    style: AppFonts.numeric(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: income,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    'Expenses',
                    style: AppFonts.body(fontSize: 11, color: axis),
                  ),
                  Text(
                    _fmt(t.expense),
                    style: AppFonts.numeric(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: expense,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 140,
          child: BarChart(
            BarChartData(
              maxY: cap,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: cap > 0 ? cap / 4 : 1,
                getDrawingHorizontalLine: (v) =>
                    FlLine(color: grid, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, m) => Text(
                      v >= 1000
                          ? '${(v / 1000).toStringAsFixed(0)}k'
                          : v.toStringAsFixed(0),
                      style: AppFonts.body(fontSize: 9, color: axis),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) {
                      final i = v.toInt();
                      final label = i == 0 ? 'In' : 'Out';
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          label,
                          style: AppFonts.body(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: i == 0 ? income : expense,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: t.income,
                      width: 22,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      color: income,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: t.expense,
                      width: 22,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      color: expense,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Text(
          'Net ${_fmt(t.income - t.expense)}',
          style: AppFonts.body(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ],
    );
  }
}
