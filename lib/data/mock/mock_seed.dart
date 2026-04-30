import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/domain/entities/category.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/domain/entities/household.dart';
import 'package:hestia/domain/entities/money_source.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';

abstract final class MockSeed {
  static const _uuid = Uuid();

  /// IDs are generated once on first seed and exposed as static fields so the
  /// auth path and other consumers can reference them.
  static late String householdId;
  static late String anaId;
  static late String lucaId;

  static void load() {
    final store = MockStore.instance;
    if (store.profiles.isNotEmpty) return;

    final now = DateTime.now();

    householdId = _uuid.v4();
    anaId = _uuid.v4();
    lucaId = _uuid.v4();

    final ana = Profile(
      id: anaId,
      email: 'ana@hestia.local',
      displayName: 'Ana Ruiz',
      preferredCurrency: 'EUR',
      isSuperuser: true,
      createdAt: now,
      lastUpdate: now,
    );
    final luca = Profile(
      id: lucaId,
      email: 'luca@hestia.local',
      displayName: 'Luca Marín',
      preferredCurrency: 'USD',
      createdAt: now,
      lastUpdate: now,
    );
    store.profiles.addAll([ana, luca]);
    store.currentProfile = ana;

    store.household = Household(
      id: householdId,
      name: 'Ruiz · Marín',
      createdBy: anaId,
      createdAt: now,
      lastUpdate: now,
    );
    store.members.addAll([
      HouseholdMember(
        id: _uuid.v4(),
        userId: anaId,
        householdId: householdId,
        role: MemberRole.owner.value,
        createdAt: now,
      ),
      HouseholdMember(
        id: _uuid.v4(),
        userId: lucaId,
        householdId: householdId,
        role: MemberRole.member.value,
        createdAt: now,
      ),
    ]);

    final dining = _cat('Dining', TransactionType.expense, now);
    final groceries = _cat('Groceries', TransactionType.expense, now);
    final transport = _cat('Transport', TransactionType.expense, now);
    final utilities = _cat('Utilities', TransactionType.expense, now);
    final leisure = _cat('Leisure', TransactionType.expense, now);
    final salary = _cat('Salary', TransactionType.income, now);
    store.categories.addAll([dining, groceries, transport, utilities, leisure, salary]);

    final anaRevolut = MoneySource(
      id: _uuid.v4(),
      householdId: householdId,
      ownerType: OwnerType.personal,
      ownerId: anaId,
      name: 'Ana · Revolut',
      institution: 'Revolut',
      accountType: AccountType.checking,
      currency: 'EUR',
      initialBalance: 1500,
      currentBalance: 1284.50,
      isPrimary: true,
      createdAt: now,
      lastUpdate: now,
    );
    final lucaBbva = MoneySource(
      id: _uuid.v4(),
      householdId: householdId,
      ownerType: OwnerType.personal,
      ownerId: lucaId,
      name: 'Luca · BBVA',
      institution: 'BBVA',
      accountType: AccountType.checking,
      currency: 'USD',
      initialBalance: 2000,
      currentBalance: 1820.00,
      createdAt: now,
      lastUpdate: now,
    );
    final sharedSavings = MoneySource(
      id: _uuid.v4(),
      householdId: householdId,
      ownerType: OwnerType.shared,
      name: 'Shared · Savings',
      institution: 'N26',
      accountType: AccountType.savings,
      currency: 'EUR',
      initialBalance: 5000,
      currentBalance: 5420.00,
      createdAt: now,
      lastUpdate: now,
    );
    store.moneySources.addAll([anaRevolut, lucaBbva, sharedSavings]);

    final samples = <(double, Category, MoneySource, String, int, TransactionType, String)>[
      (24.50, dining, anaRevolut, anaId, 2, TransactionType.expense, 'Dinner at Ramen Bar'),
      (87.30, groceries, sharedSavings, anaId, 4, TransactionType.expense, 'Mercadona'),
      (12.00, transport, anaRevolut, anaId, 5, TransactionType.expense, 'Metro card'),
      (2400.00, salary, anaRevolut, anaId, 7, TransactionType.income, 'April salary'),
      (45.99, leisure, lucaBbva, lucaId, 9, TransactionType.expense, 'Cinema'),
      (62.10, utilities, sharedSavings, anaId, 11, TransactionType.expense, 'Electricity'),
      (18.40, dining, lucaBbva, lucaId, 13, TransactionType.expense, 'Lunch'),
      (110.00, groceries, sharedSavings, anaId, 16, TransactionType.expense, 'Big shop'),
      (35.00, transport, lucaBbva, lucaId, 18, TransactionType.expense, 'Gas'),
      (2200.00, salary, lucaBbva, lucaId, 20, TransactionType.income, 'April salary'),
      (29.90, leisure, anaRevolut, anaId, 22, TransactionType.expense, 'Concert tickets'),
      (54.20, groceries, sharedSavings, lucaId, 25, TransactionType.expense, 'Weekly shop'),
      (8.00, dining, anaRevolut, anaId, 27, TransactionType.expense, 'Coffee'),
      (210.00, utilities, sharedSavings, anaId, 30, TransactionType.expense, 'Internet + phone'),
      (40.00, transport, anaRevolut, anaId, 33, TransactionType.expense, 'Taxi'),
      (16.50, dining, lucaBbva, lucaId, 36, TransactionType.expense, 'Brunch'),
      (74.00, groceries, sharedSavings, anaId, 40, TransactionType.expense, 'Groceries'),
      (22.00, leisure, lucaBbva, lucaId, 43, TransactionType.expense, 'Books'),
      (95.00, utilities, sharedSavings, anaId, 47, TransactionType.expense, 'Water'),
      (11.20, transport, anaRevolut, anaId, 50, TransactionType.expense, 'Metro top-up'),
      (33.40, dining, anaRevolut, anaId, 54, TransactionType.expense, 'Tapas'),
      (68.90, groceries, sharedSavings, lucaId, 58, TransactionType.expense, 'Groceries'),
    ];

    for (final (amt, cat, ms, uid, daysAgo, type, note) in samples) {
      final date = now.subtract(Duration(days: daysAgo));
      store.transactions.add(Transaction(
        id: _uuid.v4(),
        householdId: householdId,
        userId: uid,
        categoryId: cat.id,
        moneySourceId: ms.id,
        amount: amt,
        type: type,
        note: note,
        date: date,
        createdAt: date,
        lastUpdate: date,
        categoryName: cat.name,
        categoryColor: cat.color,
        moneySourceName: ms.name,
        userName: store.profiles.firstWhere((p) => p.id == uid).displayName,
      ));
    }

    store.goals.addAll([
      FinancialGoal(
        id: _uuid.v4(),
        householdId: householdId,
        scope: GoalScope.household,
        name: 'Summer trip',
        goalType: GoalType.reachTarget,
        targetAmount: 3000,
        currentAmount: 1450,
        startDate: now.subtract(const Duration(days: 90)),
        endDate: now.add(const Duration(days: 120)),
        createdAt: now,
        lastUpdate: now,
      ),
      FinancialGoal(
        id: _uuid.v4(),
        householdId: householdId,
        scope: GoalScope.personal,
        ownerId: anaId,
        name: 'Monthly savings',
        goalType: GoalType.saveMonthly,
        monthlyTarget: 400,
        currentAmount: 280,
        startDate: now.subtract(const Duration(days: 30)),
        createdAt: now,
        lastUpdate: now,
      ),
    ]);

    store.notifications.addAll([
      AppNotification(
        id: _uuid.v4(),
        userId: anaId,
        householdId: householdId,
        title: 'Salary received',
        body: '€2,400.00 added to Revolut',
        type: NotificationType.transaction,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: anaId,
        householdId: householdId,
        title: 'Goal milestone',
        body: 'Summer trip reached 48%',
        type: NotificationType.goal,
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: anaId,
        householdId: householdId,
        title: 'Budget alert',
        body: 'Dining at 90% of monthly budget',
        type: NotificationType.alert,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: anaId,
        householdId: householdId,
        title: 'Welcome to Hestia',
        body: 'Tap + to log your first transaction',
        type: NotificationType.system,
        createdAt: now.subtract(const Duration(days: 14)),
        isRead: true,
      ),
    ]);

    final today = DateTime(now.year, now.month, now.day);
    store.appointments.addAll([
      Appointment(
        id: _uuid.v4(),
        userId: anaId,
        householdId: householdId,
        title: 'Dentist · Dr. Marín',
        notes: 'Yearly cleaning',
        location: 'Calle Mayor 12, Madrid',
        startsAt: today.add(const Duration(hours: 10)),
        duration: const Duration(minutes: 45),
        category: AppointmentCategory.health,
        reminderOffsets: const [Duration(hours: 1), Duration(hours: 24)],
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Appointment(
        id: _uuid.v4(),
        userId: anaId,
        householdId: householdId,
        title: 'Mechanic · Wheel alignment',
        location: 'Talleres López',
        startsAt: today.add(const Duration(days: 2, hours: 16)),
        duration: const Duration(hours: 1),
        category: AppointmentCategory.vehicle,
        reminderOffsets: const [Duration(hours: 8)],
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Appointment(
        id: _uuid.v4(),
        userId: anaId,
        householdId: householdId,
        title: 'Hairstylist',
        startsAt: today.add(const Duration(days: 5, hours: 11, minutes: 30)),
        duration: const Duration(minutes: 90),
        category: AppointmentCategory.beauty,
        reminderOffsets: const [Duration(hours: 24)],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  static Category _cat(String name, TransactionType type, DateTime now) {
    return Category(
      id: _uuid.v4(),
      householdId: householdId,
      name: name,
      type: type,
      createdAt: now,
      lastUpdate: now,
    );
  }
}
