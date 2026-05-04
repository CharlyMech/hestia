import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';

enum DateRangePreset { d7, d30, d90, m6, y1, custom }

/// Short label for charts / headings (matches [DateRangeSelector] chips).
String dateRangePresetShortLabel(DateRangePreset p) {
  switch (p) {
    case DateRangePreset.d7:
      return '7d';
    case DateRangePreset.d30:
      return '30d';
    case DateRangePreset.d90:
      return '90d';
    case DateRangePreset.m6:
      return '6m';
    case DateRangePreset.y1:
      return '1y';
    case DateRangePreset.custom:
      return 'custom';
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;
  const DateRange(this.start, this.end);

  static DateRange fromPreset(DateRangePreset p) {
    final now = DateTime.now();
    switch (p) {
      case DateRangePreset.d7:
        return DateRange(now.subtract(const Duration(days: 7)), now);
      case DateRangePreset.d30:
        return DateRange(now.subtract(const Duration(days: 30)), now);
      case DateRangePreset.d90:
        return DateRange(now.subtract(const Duration(days: 90)), now);
      case DateRangePreset.m6:
        return DateRange(DateTime(now.year, now.month - 6, now.day), now);
      case DateRangePreset.y1:
        return DateRange(DateTime(now.year - 1, now.month, now.day), now);
      case DateRangePreset.custom:
        return DateRange(now.subtract(const Duration(days: 30)), now);
    }
  }
}

class DateRangeSelector extends StatelessWidget {
  final DateRangePreset selected;
  final ValueChanged<DateRangePreset> onChanged;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color activeColor;

  const DateRangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.activeColor,
  });

  static const _labels = {
    DateRangePreset.d7: '7d',
    DateRangePreset.d30: '30d',
    DateRangePreset.d90: '90d',
    DateRangePreset.m6: '6m',
    DateRangePreset.y1: '1y',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        spacing: 2,
        children: _labels.entries.map((e) {
          final active = e.key == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: active ? activeColor : const Color(0x00000000),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                alignment: Alignment.center,
                child: Text(
                  e.value,
                  style: AppFonts.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? CupertinoColors.white : muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
