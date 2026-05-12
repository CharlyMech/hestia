import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/transaction.dart';

/// Running-balance line chart for the last [days] days ending today, or for
/// an inclusive [windowStart]–[windowEnd] date range (calendar days) when both
/// are set.
class BalanceLineChart extends StatelessWidget {
  final List<Transaction> transactions;
  final double currentBalance;
  final Color line;
  final Color grid;
  final Color axis;
  final Color tooltipBg;
  final Color tooltipFg;
  final int days;
  final String currency;

  /// When both are non-null, [days] is ignored and the chart spans these
  /// inclusive calendar dates.
  final DateTime? windowStart;
  final DateTime? windowEnd;

  const BalanceLineChart({
    super.key,
    required this.transactions,
    required this.currentBalance,
    required this.line,
    required this.grid,
    required this.axis,
    required this.tooltipBg,
    required this.tooltipFg,
    this.days = 30,
    this.currency = 'EUR',
    this.windowStart,
    this.windowEnd,
  });

  ({DateTime start, DateTime end, int dayCount}) _window() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (windowStart != null && windowEnd != null) {
      final s = DateTime(
        windowStart!.year,
        windowStart!.month,
        windowStart!.day,
      );
      final e = DateTime(
        windowEnd!.year,
        windowEnd!.month,
        windowEnd!.day,
      );
      final dc = e.difference(s).inDays + 1;
      return (start: s, end: e, dayCount: dc < 1 ? 1 : dc);
    }
    final end = today;
    final start = end.subtract(Duration(days: days - 1));
    return (start: start, end: end, dayCount: days);
  }

  bool _dayInWindow(DateTime d, DateTime start, DateTime end) {
    final n = DateTime(d.year, d.month, d.day);
    return !n.isBefore(start) && !n.isAfter(end);
  }

  /// Build daily running-balance points by walking transactions forward from
  /// the inferred starting balance (current - net since window start).
  List<FlSpot> _buildSpots() {
    final w = _window();
    final start = w.start;
    final end = w.end;
    final dayCount = w.dayCount;

    // Net change inside the window so we can derive starting balance.
    double netInWindow = 0;
    for (final tx in transactions) {
      if (_dayInWindow(tx.date, start, end)) {
        netInWindow += tx.type == TransactionType.income
            ? tx.amount.abs()
            : -tx.amount.abs();
      }
    }
    double running = currentBalance - netInWindow;

    final byDay = <DateTime, double>{};
    for (var i = 0; i < dayCount; i++) {
      final d = start.add(Duration(days: i));
      double dayDelta = 0;
      for (final tx in transactions) {
        if (_sameDay(tx.date, d)) {
          dayDelta += tx.type == TransactionType.income
              ? tx.amount.abs()
              : -tx.amount.abs();
        }
      }
      running += dayDelta;
      byDay[d] = running;
    }

    return [
      for (var i = 0; i < dayCount; i++)
        FlSpot(
          i.toDouble(),
          byDay[start.add(Duration(days: i))] ?? running,
        ),
    ];
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _xLabel(double v, DateTime chartStart, int dayCount) {
    final i = v.toInt();
    if (i < 0 || i >= dayCount) return '';
    if (dayCount <= 14) {
      if (i != 0 && i != dayCount - 1 && i != dayCount ~/ 2) return '';
    } else {
      if (i % 7 != 0) return '';
    }
    final d = chartStart.add(Duration(days: i));
    return '${d.day}/${d.month}';
  }

  String _yLabel(double v) {
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final w = _window();
    final spots = _buildSpots();
    if (spots.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No balance history yet',
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
          maxX: (w.dayCount - 1).toDouble(),
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
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (v, meta) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _xLabel(v, w.start, w.dayCount),
                    style: AppFonts.body(fontSize: 10, color: axis),
                  ),
                ),
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
            getTouchedSpotIndicator: (_, indices) => indices
                .map((_) => TouchedSpotIndicatorData(
                      FlLine(color: line, strokeWidth: 1),
                      FlDotData(
                        getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                          radius: 4,
                          color: line,
                          strokeColor: tooltipBg,
                          strokeWidth: 2,
                        ),
                      ),
                    ))
                .toList(),
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
