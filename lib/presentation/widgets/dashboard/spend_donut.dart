import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';

/// Pie chart showing expense share by category for the given window.
/// Tap a slice to highlight the legend row.
///
/// When there are no expenses, renders a muted placeholder chart with a blurred
/// overlay and [emptyLabel].
class SpendDonut extends StatefulWidget {
  final List<Transaction> transactions;
  final Color fg;
  final Color muted;
  final Color border;
  final Color surface;
  final List<Color> palette;
  final String currency;

  const SpendDonut({
    super.key,
    required this.transactions,
    required this.fg,
    required this.muted,
    required this.border,
    required this.surface,
    required this.palette,
    this.currency = 'EUR',
  });

  @override
  State<SpendDonut> createState() => _SpendDonutState();
}

class _SpendDonutState extends State<SpendDonut> {
  int? _touchedIndex;

  static const _placeholderSliceCount = 4;

  Map<String, double> _aggregate() {
    final out = <String, double>{};
    for (final tx in widget.transactions) {
      if (tx.type != TransactionType.expense) continue;
      final key = tx.categoryName ?? 'Other';
      out[key] = (out[key] ?? 0) + tx.amount.abs();
    }
    return out;
  }

  List<MapEntry<String, double>> _placeholderEntries() {
    return List.generate(
      _placeholderSliceCount,
      (i) => MapEntry('—', 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agg = _aggregate();
    final hasData = agg.isNotEmpty;
    final entries = hasData
        ? (agg.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        : _placeholderEntries();
    final total = entries.fold<double>(0, (s, e) => s + e.value);
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 38,
                    pieTouchData: PieTouchData(
                      enabled: hasData,
                      touchCallback: (event, response) {
                        if (!hasData) return;
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
                          color: hasData
                              ? widget.palette[i % widget.palette.length]
                              : widget.palette[i % widget.palette.length]
                                  .withValues(alpha: 0.22),
                          title: hasData && i == _touchedIndex
                              ? '${(entries[i].value / total * 100).toStringAsFixed(0)}%'
                              : '',
                          titleStyle: AppFonts.body(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.white,
                          ),
                          radius: hasData && i == _touchedIndex ? 56 : 50,
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
                                color: hasData
                                    ? widget.palette[i % widget.palette.length]
                                    : widget.muted.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                hasData ? entries[i].key : '—',
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.body(
                                  fontSize: 12,
                                  fontWeight: hasData && i == _touchedIndex
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: hasData
                                      ? widget.fg
                                      : widget.muted.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            if (hasData)
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
          if (!hasData)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                  child: Container(
                    alignment: Alignment.center,
                    color: widget.surface.withValues(alpha: 0.65),
                    child: Text(
                      l10n.dashboard_noExpensesInWindow,
                      style: AppFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: widget.fg,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
