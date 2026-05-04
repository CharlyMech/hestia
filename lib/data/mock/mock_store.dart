import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/domain/entities/category.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/domain/entities/household.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
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
  final List<BankAccount> bankAccounts = [];
  final List<TransactionSource> transactionSources = [];
  final List<Transaction> transactions = [];
  final List<Transfer> transfers = [];
  final List<FinancialGoal> goals = [];
  final List<AppNotification> notifications = [];
  final List<Appointment> appointments = [];
  final List<ShoppingList> shoppingLists = [];
  final List<ShoppingListItem> shoppingListItems = [];

  void clear() {
    currentProfile = null;
    authenticated = false;
    household = null;
    members.clear();
    profiles.clear();
    categories.clear();
    bankAccounts.clear();
    transactionSources.clear();
    transactions.clear();
    transfers.clear();
    goals.clear();
    notifications.clear();
    appointments.clear();
    shoppingLists.clear();
    shoppingListItems.clear();
  }
}
