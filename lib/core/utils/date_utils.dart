import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

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
