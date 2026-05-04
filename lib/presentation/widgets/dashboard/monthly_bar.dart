import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/transaction.dart';

/// Net per month bar chart (income − expense). Bars switch color based on sign.
class MonthlyBar extends StatelessWidget {
  final List<Transaction> transactions;
  final int months;
  final Color income;
  final Color expense;
  final Color axis;
  final Color grid;
  final Color tooltipBg;
  final Color tooltipFg;
  final String currency;

  const MonthlyBar({
    super.key,
    required this.transactions,
    this.months = 6,
    required this.income,
    required this.expense,
    required this.axis,
    required this.grid,
    required this.tooltipBg,
    required this.tooltipFg,
    this.currency = 'EUR',
  });

  List<({double net, DateTime month})> _aggregate() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - (months - 1), 1);
    final out = <({double net, DateTime month})>[];
    for (var i = 0; i < months; i++) {
      final m = DateTime(start.year, start.month + i, 1);
      double net = 0;
      for (final tx in transactions) {
        if (tx.date.year == m.year && tx.date.month == m.month) {
          net += tx.type == TransactionType.income
              ? tx.amount.abs()
              : -tx.amount.abs();
        }
      }
      out.add((net: net, month: m));
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
    if (data.every((d) => d.net == 0)) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'No activity in this window',
            style: AppFonts.body(fontSize: 12, color: axis),
          ),
        ),
      );
    }
    final maxAbs =
        data.map((d) => d.net.abs()).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: -maxAbs * 1.2,
          maxY: maxAbs * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxAbs.clamp(1, double.infinity),
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
                final v = rod.toY;
                final sign = v >= 0 ? '+' : '−';
                return BarTooltipItem(
                  '$sign${v.abs().toStringAsFixed(0)} $currency',
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
                barRods: [
                  BarChartRodData(
                    toY: data[i].net,
                    color: data[i].net >= 0 ? income : expense,
                    width: 14,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(3)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
