import 'package:hestia/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  /// To UNIX seconds (what Supabase stores)
  int get toUnix => millisecondsSinceEpoch ~/ 1000;

  /// Formatted display
  String get formatted => DateFormat(AppConstants.dateFormat).format(this);

  String get monthYear => DateFormat(AppConstants.monthYearFormat).format(this);

  /// Start of month
  DateTime get startOfMonth => DateTime(year, month);

  /// End of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);

  /// ISO `YYYY-MM-DD` — the storage form for date-only (string) columns
  /// (birth dates, car acquisition). Storage is always ISO regardless of the
  /// user's display preference.
  String get toDateOnlyIso =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// Collapse a date-only pick to noon (12:00:00) local time before storing as
  /// unix. Noon avoids midnight/DST day-shift bugs when only the date matters
  /// (backdated transactions, fuel fills, vet visits, …).
  DateTime get atNoon => DateTime(year, month, day, 12);
}

extension UnixExt on int {
  /// From UNIX seconds to DateTime
  DateTime get fromUnix => DateTime.fromMillisecondsSinceEpoch(this * 1000);
}

// ── Preference-driven formatting ────────────────────────────────────────────
// `dateFormat` is the user pref string: 'mdy' | 'dmy' | 'ymd' (see
// UserPreferencesService). `use24h` toggles 24-hour vs AM/PM. Times always
// include seconds (HH:mm:ss).

/// intl pattern for the numeric date-only display preference.
String dateOnlyPattern(String dateFormat) => switch (dateFormat) {
      'dmy' => 'dd/MM/yyyy',
      'ymd' => 'yyyy-MM-dd',
      _ => 'MM/dd/yyyy', // 'mdy' default
    };

/// intl time pattern; always seconds, AM/PM vs 24-hour per [use24h].
String timePattern(bool use24h) => use24h ? 'HH:mm:ss' : 'hh:mm:ss a';

/// Formats a date-only value (birth date, acquisition) per the user's
/// [dateFormat] preference.
String formatDateOnly(DateTime date, {required String dateFormat}) =>
    DateFormat(dateOnlyPattern(dateFormat)).format(date);

/// Formats a full timestamp as `<date> <time>` honoring both prefs.
String formatDateTime(
  DateTime date, {
  required String dateFormat,
  required bool use24h,
}) =>
    DateFormat('${dateOnlyPattern(dateFormat)} ${timePattern(use24h)}')
        .format(date);

/// Parses an ISO `YYYY-MM-DD` (or full ISO) date-only string column to a
/// [DateTime], or null when empty/invalid.
DateTime? parseDateOnly(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return DateTime.tryParse(trimmed);
}

/// Parses Supabase timestamp columns (unix int, ISO string, or numeric).
/// Uses [orElse] when the column is null or empty (legacy rows).
DateTime parseSupabaseTimestamp(
  dynamic value, {
  DateTime? orElse,
}) {
  if (value == null) {
    return orElse ?? (throw FormatException('Timestamp value is null'));
  }
  if (value is int) return value.fromUnix;
  if (value is num) return value.toInt().fromUnix;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return orElse ?? (throw FormatException('Timestamp value is empty'));
    }
    final asInt = int.tryParse(trimmed);
    if (asInt != null) return asInt.fromUnix;
    return DateTime.parse(trimmed);
  }
  throw FormatException('Unsupported timestamp type: ${value.runtimeType}');
}
