/// Supported currencies with their ISO 4217 code and symbol.
class AppCurrency {
  final String code;
  final String symbol;

  const AppCurrency({required this.code, required this.symbol});

  @override
  String toString() => code;
}

abstract final class AppCurrencies {
  // European
  static const eur = AppCurrency(code: 'EUR', symbol: '€');
  static const gbp = AppCurrency(code: 'GBP', symbol: '£');
  static const chf = AppCurrency(code: 'CHF', symbol: 'CHF');
  static const sek = AppCurrency(code: 'SEK', symbol: 'kr');
  static const nok = AppCurrency(code: 'NOK', symbol: 'kr');
  static const dkk = AppCurrency(code: 'DKK', symbol: 'kr');
  static const pln = AppCurrency(code: 'PLN', symbol: 'zł');
  static const czk = AppCurrency(code: 'CZK', symbol: 'Kč');
  static const huf = AppCurrency(code: 'HUF', symbol: 'Ft');
  static const ron = AppCurrency(code: 'RON', symbol: 'lei');
  static const bgn = AppCurrency(code: 'BGN', symbol: 'лв');

  // Americas
  static const usd = AppCurrency(code: 'USD', symbol: '\$');
  static const cad = AppCurrency(code: 'CAD', symbol: 'CA\$');

  // Asia-Pacific
  static const jpy = AppCurrency(code: 'JPY', symbol: '¥');
  static const cny = AppCurrency(code: 'CNY', symbol: '¥');
  static const aud = AppCurrency(code: 'AUD', symbol: 'A\$');

  static const List<AppCurrency> all = [
    eur, usd, gbp, chf,
    sek, nok, dkk, pln, czk, huf, ron, bgn,
    jpy, cad, aud, cny,
  ];

  /// Returns the [AppCurrency] matching [code], or null if not found.
  static AppCurrency? fromCode(String code) {
    for (final c in all) {
      if (c.code == code) return c;
    }
    return null;
  }
}
