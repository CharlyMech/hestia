/// Centralized table name references. Avoids typos scattered across services.
abstract final class SupabaseTables {
  static const profiles = 'profiles';
  static const households = 'households';
  static const householdMembers = 'household_members';
  static const categories = 'categories';
  static const transactions = 'transactions';
  static const transfers = 'transfers';
  static const bankAccounts = 'bank_accounts';
  static const financialInstitutions = 'financial_institutions';
  static const accountMembers = 'account_members';
  static const transactionSources = 'transaction_sources';
  static const financialGoals = 'financial_goals';
  static const goalContributions = 'goal_contributions';
  static const notifications = 'notifications';
  static const scheduledNotifications = 'scheduled_notifications';
  static const notificationSettings = 'notification_settings';
  static const deviceTokens = 'device_tokens';
  static const appVersions = 'app_versions';
  static const appointments = 'appointments';
  static const appointmentReminders = 'appointment_reminders';
  static const appointmentPets = 'appointment_pets';

  // ── Newly wired in supabase flavor (Part B) ──────────────────────────────
  static const cars = 'cars';
  static const carMembers = 'car_members';
  static const fuelEntries = 'fuel_entries';
  static const pets = 'pets';
  static const petHealthRecords = 'pet_health_records';
  static const petMeasurements = 'pet_measurements';
  static const shoppingLists = 'shopping_lists';
  static const shoppingListItems = 'shopping_list_items';
  static const shoppingSessions = 'shopping_sessions';
  static const homes = 'homes';
}
