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

/// Predefined color palette for appointment color picker.
abstract final class AppointmentColors {
  static const List<String> palette = [
    '#EF5350', // red
    '#EC407A', // pink
    '#AB47BC', // purple
    '#7E57C2', // deep purple
    '#42A5F5', // blue
    '#26A69A', // teal
    '#66BB6A', // green
    '#FFA726', // orange
    '#FF7043', // deep orange
    '#78909C', // blue grey
  ];
}

/// Border-radius scale. Max 12 — keeps UI tight.
abstract final class AppRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double full = 9999;
}
