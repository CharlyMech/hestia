import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/domain/entities/category.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/domain/entities/household.dart';
import 'package:hestia/domain/entities/money_source.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transfer.dart';

/// Singleton in-memory store for the mock flavor. Survives app lifecycle
/// but resets on cold start.
class MockStore {
  MockStore._();
  static final MockStore instance = MockStore._();

  Profile? currentProfile;
  bool authenticated = false;

  Household? household;
  final List<HouseholdMember> members = [];
  final List<Profile> profiles = [];

  final List<Category> categories = [];
  final List<MoneySource> moneySources = [];
  final List<Transaction> transactions = [];
  final List<Transfer> transfers = [];
  final List<FinancialGoal> goals = [];
  final List<AppNotification> notifications = [];
  final List<Appointment> appointments = [];

  void clear() {
    currentProfile = null;
    authenticated = false;
    household = null;
    members.clear();
    profiles.clear();
    categories.clear();
    moneySources.clear();
    transactions.clear();
    transfers.clear();
    goals.clear();
    notifications.clear();
    appointments.clear();
  }
}
