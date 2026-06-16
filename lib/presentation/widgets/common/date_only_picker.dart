import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';

/// Shared native date-only picker presented in an app bottom sheet.
///
/// Returns a [DateOnlyResult]: `null` when dismissed, `cleared` when the user
/// taps Clear, or a [DateTime] (date-only, no time) when confirmed. Callers
/// that store the value as a backdated unix timestamp should apply
/// `DateTimeExt.atNoon` before `toUnix`.
class DateOnlyResult {
  final DateTime? date;
  final bool cleared;
  const DateOnlyResult._(this.date, this.cleared);
  static const DateOnlyResult clear = DateOnlyResult._(null, true);
  const DateOnlyResult.value(DateTime d) : this._(d, false);
}

Future<DateOnlyResult?> pickDateOnly({
  required BuildContext context,
  required String title,
  DateTime? initial,
  DateTime? maximumDate,
  bool allowClear = true,
}) {
  final theme = context.myTheme;
  final fg = hexToColor(theme.onBackgroundColor);
  final accent = hexToColor(theme.primaryColor);
  final l10n = AppLocalizations.of(context);
  var temp = initial ?? DateTime.now();

  return showAppBottomSheet<DateOnlyResult>(
    context: context,
    title: title,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (allowClear)
                AnimatedButton(
                  padding: EdgeInsets.zero,
                  onTap: () => Navigator.pop(context, DateOnlyResult.clear),
                  child: Text(l10n.common_clear,
                      style: AppFonts.body(fontSize: 15, color: fg)),
                )
              else
                const SizedBox.shrink(),
              AnimatedButton(
                padding: EdgeInsets.zero,
                onTap: () =>
                    Navigator.pop(context, DateOnlyResult.value(temp)),
                child: Text(l10n.common_done,
                    style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: accent)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: temp,
            maximumDate: maximumDate,
            onDateTimeChanged: (d) => temp = d,
          ),
        ),
      ],
    ),
  );
}
