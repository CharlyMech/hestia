import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/transaction.dart';

/// Per-month income/expense vertical paired bar chart for the last
/// [months] months. Tap a bar to see a tooltip with the exact value.
class MonthlyIoBarChart extends StatelessWidget {
  final List<Transaction> transactions;
  final Color income;
  final Color expense;
  final Color axis;
  final Color grid;
  final Color tooltipBg;
  final Color tooltipFg;
  final int months;
  final String currency;

  const MonthlyIoBarChart({
    super.key,
    required this.transactions,
    required this.income,
    required this.expense,
    required this.axis,
    required this.grid,
    required this.tooltipBg,
    required this.tooltipFg,
    this.months = 12,
    this.currency = 'EUR',
  });

  /// Returns a list of (income, expense) totals indexed oldest → newest.
  List<({double income, double expense, DateTime month})> _aggregate() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - (months - 1), 1);
    final out = <({double income, double expense, DateTime month})>[];
    for (var i = 0; i < months; i++) {
      final m = DateTime(start.year, start.month + i, 1);
      double inc = 0;
      double exp = 0;
      for (final tx in transactions) {
        if (tx.date.year == m.year && tx.date.month == m.month) {
          if (tx.type == TransactionType.income) {
            inc += tx.amount.abs();
          } else {
            exp += tx.amount.abs();
          }
        }
      }
      out.add((income: inc, expense: exp, month: m));
    }
    return out;
  }

  String _xLabel(DateTime m) {
    const names = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return names[m.month - 1];
  }

  String _yLabel(double v) {
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final data = _aggregate();
    final maxVal = data.fold<double>(
      0,
      (m, e) => [m, e.income, e.expense].reduce((a, b) => a > b ? a : b),
    );
    if (maxVal == 0) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No activity in this window',
            style: AppFonts.body(fontSize: 12, color: axis),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.18,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxVal / 4).clamp(1, double.infinity),
            getDrawingHorizontalLine: (_) =>
                FlLine(color: grid, strokeWidth: 0.6),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _xLabel(data[i].month),
                      style: AppFonts.body(fontSize: 10, color: axis),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (v, meta) => Text(
                  _yLabel(v),
                  style: AppFonts.body(fontSize: 10, color: axis),
                ),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => tooltipBg,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, gIdx, rod, rIdx) {
                final isIncome = rIdx == 0;
                final label = isIncome ? '+ ' : '− ';
                return BarTooltipItem(
                  '$label${rod.toY.toStringAsFixed(0)} $currency',
                  AppFonts.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tooltipFg,
                  ),
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 3,
                barRods: [
                  BarChartRodData(
                    toY: data[i].income,
                    color: income,
                    width: 6,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(2)),
                  ),
                  BarChartRodData(
                    toY: data[i].expense,
                    color: expense,
                    width: 6,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(2)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
