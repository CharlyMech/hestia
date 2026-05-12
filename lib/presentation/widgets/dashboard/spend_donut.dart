import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/transaction.dart';

/// Pie chart showing expense share by category for the given window.
/// Tap a slice to highlight the legend row.
class SpendDonut extends StatefulWidget {
  final List<Transaction> transactions;
  final Color fg;
  final Color muted;
  final Color border;
  final List<Color> palette;
  final String currency;

  const SpendDonut({
    super.key,
    required this.transactions,
    required this.fg,
    required this.muted,
    required this.border,
    required this.palette,
    this.currency = 'EUR',
  });

  @override
  State<SpendDonut> createState() => _SpendDonutState();
}

class _SpendDonutState extends State<SpendDonut> {
  int? _touchedIndex;

  Map<String, double> _aggregate() {
    final out = <String, double>{};
    for (final tx in widget.transactions) {
      if (tx.type != TransactionType.expense) continue;
      final key = tx.categoryName ?? 'Other';
      out[key] = (out[key] ?? 0) + tx.amount.abs();
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final agg = _aggregate();
    if (agg.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'No expenses in this window',
            style: AppFonts.body(fontSize: 12, color: widget.muted),
          ),
        ),
      );
    }
    final entries = agg.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0, (s, e) => s + e.value);

    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 38,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex =
                          response?.touchedSection?.touchedSectionIndex;
                    });
                  },
                ),
                sections: [
                  for (var i = 0; i < entries.length; i++)
                    PieChartSectionData(
                      value: entries[i].value,
                      color: widget.palette[i % widget.palette.length],
                      title: i == _touchedIndex
                          ? '${(entries[i].value / total * 100).toStringAsFixed(0)}%'
                          : '',
                      titleStyle: AppFonts.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                      ),
                      radius: i == _touchedIndex ? 56 : 50,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < entries.length && i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      spacing: 8,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.palette[i % widget.palette.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entries[i].key,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                              fontSize: 12,
                              fontWeight: i == _touchedIndex
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: widget.fg,
                            ),
                          ),
                        ),
                        Text(
                          '${(entries[i].value / total * 100).toStringAsFixed(0)}%',
                          style: AppFonts.numeric(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: widget.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
