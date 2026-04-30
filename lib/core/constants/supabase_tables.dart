/// Centralized table name references. Avoids typos scattered across services.
abstract final class SupabaseTables {
  static const profiles = 'profiles';
  static const households = 'households';
  static const householdMembers = 'household_members';
  static const categories = 'categories';
  static const transactions = 'transactions';
  static const transfers = 'transfers';
  static const moneySources = 'money_sources';
  static const financialGoals = 'financial_goals';
  static const goalContributions = 'goal_contributions';
  static const notifications = 'notifications';
  static const scheduledNotifications = 'scheduled_notifications';
  static const notificationSettings = 'notification_settings';
  static const deviceTokens = 'device_tokens';
  static const appointments = 'appointments';
  static const appointmentReminders = 'appointment_reminders';
}
