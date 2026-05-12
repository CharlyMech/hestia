import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/transaction.dart';

/// Total household balance trend across all bank accounts for [days] days.
/// Walks transactions backward from current totals to derive historical
/// balances. Touch a point to see the exact value.
class BalanceTrendLine extends StatelessWidget {
  final List<Transaction> transactions;
  final List<BankAccount> bankAccounts;
  final Color line;
  final Color grid;
  final Color axis;
  final Color tooltipBg;
  final Color tooltipFg;
  final int days;
  final String currency;

  const BalanceTrendLine({
    super.key,
    required this.transactions,
    required this.bankAccounts,
    required this.line,
    required this.grid,
    required this.axis,
    required this.tooltipBg,
    required this.tooltipFg,
    this.days = 30,
    this.currency = 'EUR',
  });

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<FlSpot> _buildSpots() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final currentTotal =
        bankAccounts.fold<double>(0, (s, a) => s + a.currentBalance);

    double netInWindow = 0;
    for (final tx in transactions) {
      if (tx.date.isAfter(start) || _sameDay(tx.date, start)) {
        netInWindow += tx.type == TransactionType.income
            ? tx.amount.abs()
            : -tx.amount.abs();
      }
    }
    double running = currentTotal - netInWindow;

    final spots = <FlSpot>[];
    for (var i = 0; i < days; i++) {
      final d = DateTime(start.year, start.month, start.day + i);
      double dayDelta = 0;
      for (final tx in transactions) {
        if (_sameDay(tx.date, d)) {
          dayDelta += tx.type == TransactionType.income
              ? tx.amount.abs()
              : -tx.amount.abs();
        }
      }
      running += dayDelta;
      spots.add(FlSpot(i.toDouble(), running));
    }
    return spots;
  }

  String _xLabel(double v) {
    final i = v.toInt();
    if (i % 7 != 0) return '';
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1 - i));
    return '${d.day}/${d.month}';
  }

  String _yLabel(double v) {
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();
    if (bankAccounts.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Add an account to see your trend',
            style: AppFonts.body(fontSize: 12, color: axis),
          ),
        ),
      );
    }
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final pad = ((maxY - minY).abs() * 0.12).clamp(1.0, double.infinity);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (days - 1).toDouble(),
          minY: minY - pad,
          maxY: maxY + pad,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval:
                ((maxY - minY).abs() / 4).clamp(1, double.infinity),
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
                interval: 1,
                getTitlesWidget: (v, meta) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_xLabel(v),
                      style: AppFonts.body(fontSize: 10, color: axis)),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (v, meta) => Text(_yLabel(v),
                    style: AppFonts.body(fontSize: 10, color: axis)),
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => tooltipBg,
              tooltipRoundedRadius: 8,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(2)} $currency',
                        AppFonts.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tooltipFg,
                        ),
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.32,
              preventCurveOverShooting: true,
              barWidth: 2.5,
              color: line,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: line.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
