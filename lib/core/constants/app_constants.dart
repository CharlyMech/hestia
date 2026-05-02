abstract final class AppConstants {
  /// Default currency
  static const defaultCurrency = 'EUR';

  /// Sync: how many recent days to fetch on startup
  static const initialSyncDays = 90;

  /// Goal projections: default months to project
  static const defaultProjectionMonths = 12;

  /// Notifications: large expense threshold (€)
  static const largeExpenseThreshold = 200.0;

  /// Pagination
  static const pageSize = 50;

  /// Biometric prompt
  static const biometricReason = 'Authenticate to access your finances';

  /// Date format
  static const dateFormat = 'dd MMM yyyy';
  static const monthYearFormat = 'MMM yyyy';
}

/// Border-radius scale. Max 12 — keeps UI tight.
abstract final class AppRadii {
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
}
