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
}

extension UnixExt on int {
  /// From UNIX seconds to DateTime
  DateTime get fromUnix => DateTime.fromMillisecondsSinceEpoch(this * 1000);
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
