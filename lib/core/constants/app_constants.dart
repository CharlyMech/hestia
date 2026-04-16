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
