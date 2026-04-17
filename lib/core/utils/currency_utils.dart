import 'package:intl/intl.dart';

extension CurrencyExt on num {
  /// Format as currency. Defaults to EUR.
  String toCurrency({String symbol = '€', int decimals = 2}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
      locale: 'es_ES',
    );
    return formatter.format(this);
  }

  /// Compact format for charts (1.2k, 3.5M)
  String toCompact({String symbol = '€'}) {
    final formatter = NumberFormat.compactCurrency(
      symbol: symbol,
      locale: 'es_ES',
    );
    return formatter.format(this);
  }
}
