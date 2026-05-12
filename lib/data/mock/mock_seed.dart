import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/domain/entities/category.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/domain/entities/household.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/car.dart';
import 'package:hestia/domain/entities/car_member.dart';
import 'package:hestia/domain/entities/fuel_entry.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/domain/entities/pet.dart';
import 'package:hestia/domain/entities/pet_health_record.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
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
      calendarColor: '#8B7AE6',
      isSuperuser: true,
      createdAt: now,
      lastUpdate: now,
    );
    final luca = Profile(
      id: lucaId,
      email: 'luca@hestia.local',
      displayName: 'Luca Marín',
      preferredCurrency: 'USD',
      calendarColor: '#7AAFE6',
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
    store.categories
        .addAll([dining, groceries, transport, utilities, leisure, salary]);

    final anaRevolut = BankAccount(
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
    final lucaBbva = BankAccount(
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
    final sharedSavings = BankAccount(
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
    store.bankAccounts.addAll([anaRevolut, lucaBbva, sharedSavings]);

    final samples =
        <(double, Category, BankAccount, String, int, TransactionType, String)>[
      (
        24.50,
        dining,
        anaRevolut,
        anaId,
        2,
        TransactionType.expense,
        'Dinner at Ramen Bar'
      ),
      (
        87.30,
        groceries,
        sharedSavings,
        anaId,
        4,
        TransactionType.expense,
        'Mercadona'
      ),
      (
        12.00,
        transport,
        anaRevolut,
        anaId,
        5,
        TransactionType.expense,
        'Metro card'
      ),
      (
        2400.00,
        salary,
        anaRevolut,
        anaId,
        7,
        TransactionType.income,
        'April salary'
      ),
      (45.99, leisure, lucaBbva, lucaId, 9, TransactionType.expense, 'Cinema'),
      (
        62.10,
        utilities,
        sharedSavings,
        anaId,
        11,
        TransactionType.expense,
        'Electricity'
      ),
      (18.40, dining, lucaBbva, lucaId, 13, TransactionType.expense, 'Lunch'),
      (
        110.00,
        groceries,
        sharedSavings,
        anaId,
        16,
        TransactionType.expense,
        'Big shop'
      ),
      (35.00, transport, lucaBbva, lucaId, 18, TransactionType.expense, 'Gas'),
      (
        2200.00,
        salary,
        lucaBbva,
        lucaId,
        20,
        TransactionType.income,
        'April salary'
      ),
      (
        29.90,
        leisure,
        anaRevolut,
        anaId,
        22,
        TransactionType.expense,
        'Concert tickets'
      ),
      (
        54.20,
        groceries,
        sharedSavings,
        lucaId,
        25,
        TransactionType.expense,
        'Weekly shop'
      ),
      (8.00, dining, anaRevolut, anaId, 27, TransactionType.expense, 'Coffee'),
      (
        210.00,
        utilities,
        sharedSavings,
        anaId,
        30,
        TransactionType.expense,
        'Internet + phone'
      ),
      (
        40.00,
        transport,
        anaRevolut,
        anaId,
        33,
        TransactionType.expense,
        'Taxi'
      ),
      (16.50, dining, lucaBbva, lucaId, 36, TransactionType.expense, 'Brunch'),
      (
        74.00,
        groceries,
        sharedSavings,
        anaId,
        40,
        TransactionType.expense,
        'Groceries'
      ),
      (22.00, leisure, lucaBbva, lucaId, 43, TransactionType.expense, 'Books'),
      (
        95.00,
        utilities,
        sharedSavings,
        anaId,
        47,
        TransactionType.expense,
        'Water'
      ),
      (
        11.20,
        transport,
        anaRevolut,
        anaId,
        50,
        TransactionType.expense,
        'Metro top-up'
      ),
      (33.40, dining, anaRevolut, anaId, 54, TransactionType.expense, 'Tapas'),
      (
        68.90,
        groceries,
        sharedSavings,
        lucaId,
        58,
        TransactionType.expense,
        'Groceries'
      ),
    ];

    for (final (amt, cat, ms, uid, daysAgo, type, note) in samples) {
      final date = now.subtract(Duration(days: daysAgo));
      store.transactions.add(Transaction(
        id: _uuid.v4(),
        householdId: householdId,
        userId: uid,
        categoryId: cat.id,
        bankAccountId: ms.id,
        amount: amt,
        type: type,
        note: note,
        date: date,
        createdAt: date,
        lastUpdate: date,
        categoryName: cat.name,
        categoryColor: cat.color,
        bankAccountName: ms.name,
        userName: store.profiles.firstWhere((p) => p.id == uid).displayName,
      ));
    }

    // Geo-tagged sample (transaction location map / stats).
    store.transactions.add(Transaction(
      id: _uuid.v4(),
      householdId: householdId,
      userId: anaId,
      categoryId: dining.id,
      bankAccountId: anaRevolut.id,
      amount: 6.4,
      type: TransactionType.expense,
      note: 'Bocadillo (demo GPS)',
      date: now.subtract(const Duration(days: 2)),
      createdAt: now.subtract(const Duration(days: 2)),
      lastUpdate: now.subtract(const Duration(days: 2)),
      latitude: 40.4168,
      longitude: -3.7038,
      categoryName: dining.name,
      categoryColor: dining.color,
      bankAccountName: anaRevolut.name,
      userName: ana.displayName,
    ));

    // Transaction sources — counterparties (merchants, employers, services).
    // Visible household-wide; reusable across transactions and shopping lists.
    TransactionSource src(String name, TransactionSourceKind kind, String hex) {
      final s = TransactionSource(
        id: _uuid.v4(),
        householdId: householdId,
        name: name,
        kind: kind,
        color: hex,
        createdBy: anaId,
        createdAt: now,
        lastUpdate: now,
      );
      store.transactionSources.add(s);
      return s;
    }

    final netflix = src('Netflix', TransactionSourceKind.service, '#E50914');
    final spotify = src('Spotify', TransactionSourceKind.service, '#1DB954');
    final movistar = src('Movistar', TransactionSourceKind.service, '#0066CC');
    final esloogan = src('Esloogan', TransactionSourceKind.employer, '#22C55E');
    final mapfre = src('Mapfre', TransactionSourceKind.service, '#E11D48');
    final mercadona =
        src('Mercadona', TransactionSourceKind.merchant, '#00A551');
    src('Lidl', TransactionSourceKind.merchant, '#0050AA');
    src('Stripe', TransactionSourceKind.platform, '#635BFF');
    src('Vinted', TransactionSourceKind.platform, '#09B1BA');
    src('Anthropic', TransactionSourceKind.platform, '#D97706');

    // Recurring scheduled transactions — visible on per-account "Recurring"
    // sub-screen. Mix of subscriptions, salaries, bills.
    final recurringSamples = <(
      double,
      Category,
      BankAccount,
      String,
      int,
      TransactionType,
      String,
      String,
      TransactionSource
    )>[
      (
        12.99,
        leisure,
        anaRevolut,
        anaId,
        8,
        TransactionType.expense,
        'Netflix',
        'monthly',
        netflix
      ),
      (
        9.99,
        leisure,
        anaRevolut,
        anaId,
        5,
        TransactionType.expense,
        'Spotify Family',
        'monthly',
        spotify
      ),
      (
        29.00,
        utilities,
        sharedSavings,
        anaId,
        3,
        TransactionType.expense,
        'Internet · Movistar',
        'monthly',
        movistar
      ),
      (
        2400.00,
        salary,
        anaRevolut,
        anaId,
        7,
        TransactionType.income,
        'Salary · Esloogan',
        'monthly',
        esloogan
      ),
      (
        199.00,
        utilities,
        sharedSavings,
        lucaId,
        12,
        TransactionType.expense,
        'Annual insurance',
        'yearly',
        mapfre
      ),
    ];
    for (final (amt, cat, ms, uid, daysAgo, type, note, freq, txSrc)
        in recurringSamples) {
      final date = now.subtract(Duration(days: daysAgo));
      store.transactions.add(Transaction(
        id: _uuid.v4(),
        householdId: householdId,
        userId: uid,
        categoryId: cat.id,
        bankAccountId: ms.id,
        transactionSourceId: txSrc.id,
        amount: amt,
        type: type,
        note: note,
        date: date,
        isRecurring: true,
        recurringRule: {'frequency': freq},
        createdAt: date,
        lastUpdate: date,
        categoryName: cat.name,
        categoryColor: cat.color,
        bankAccountName: ms.name,
        transactionSourceName: txSrc.name,
        userName: store.profiles.firstWhere((p) => p.id == uid).displayName,
      ));
    }

    store.goals.addAll([
      FinancialGoal(
        id: _uuid.v4(),
        householdId: householdId,
        scope: GoalScope.household,
        bankAccountId: sharedSavings.id,
        name: 'Summer trip · Sicily',
        goalType: GoalType.reachTarget,
        targetAmount: 3000,
        currentAmount: 1450,
        color: '#8B7AE6',
        startDate: now.subtract(const Duration(days: 90)),
        endDate: now.add(const Duration(days: 120)),
        createdAt: now,
        lastUpdate: now,
      ),
      FinancialGoal(
        id: _uuid.v4(),
        householdId: householdId,
        scope: GoalScope.household,
        bankAccountId: sharedSavings.id,
        name: 'Emergency fund',
        goalType: GoalType.reachTarget,
        targetAmount: 10000,
        currentAmount: 3400,
        color: '#7AAFE6',
        startDate: now.subtract(const Duration(days: 180)),
        createdAt: now,
        lastUpdate: now,
      ),
      FinancialGoal(
        id: _uuid.v4(),
        householdId: householdId,
        scope: GoalScope.personal,
        ownerId: anaId,
        bankAccountId: anaRevolut.id,
        name: 'Monthly savings',
        goalType: GoalType.saveMonthly,
        monthlyTarget: 400,
        currentAmount: 280,
        color: '#22C55E',
        startDate: now.subtract(const Duration(days: 30)),
        createdAt: now,
        lastUpdate: now,
      ),
      FinancialGoal(
        id: _uuid.v4(),
        householdId: householdId,
        scope: GoalScope.personal,
        ownerId: anaId,
        bankAccountId: anaRevolut.id,
        name: 'New laptop',
        goalType: GoalType.reachTarget,
        targetAmount: 2000,
        currentAmount: 1560,
        color: '#E6B87A',
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.add(const Duration(days: 60)),
        createdAt: now,
        lastUpdate: now,
      ),
      FinancialGoal(
        id: _uuid.v4(),
        householdId: householdId,
        scope: GoalScope.personal,
        ownerId: lucaId,
        bankAccountId: lucaBbva.id,
        name: 'Photography course',
        goalType: GoalType.reachTarget,
        targetAmount: 600,
        currentAmount: 90,
        color: '#E67AB8',
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.add(const Duration(days: 150)),
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

    // Shopping — template, active session, paid session in history.
    final mercadonaTemplateId = _uuid.v4();
    store.shoppingLists.add(ShoppingList(
      id: mercadonaTemplateId,
      householdId: householdId,
      ownerId: anaId,
      scope: ShoppingListScope.shared,
      name: 'Mercadona · staples',
      status: ShoppingListStatus.active,
      kind: ShoppingListKind.template,
      transactionSourceId: mercadona.id,
      createdAt: now.subtract(const Duration(days: 14)),
      lastUpdate: now,
    ));
    for (final pair in const [('Milk', 2), ('Bread', 1), ('Eggs', 12)]) {
      store.shoppingListItems.add(ShoppingListItem(
        id: _uuid.v4(),
        listId: mercadonaTemplateId,
        name: pair.$1,
        qty: pair.$2,
        sortOrder: store.shoppingListItems
            .where((i) => i.listId == mercadonaTemplateId)
            .length,
        createdAt: now.subtract(const Duration(days: 14)),
        lastUpdate: now,
      ));
    }

    final activeListId = _uuid.v4();
    store.shoppingLists.add(ShoppingList(
      id: activeListId,
      householdId: householdId,
      ownerId: anaId,
      scope: ShoppingListScope.shared,
      name: 'Weekly groceries',
      status: ShoppingListStatus.active,
      kind: ShoppingListKind.session,
      sessionStartedAt: now.subtract(const Duration(hours: 1)),
      bankAccountId: sharedSavings.id,
      createdAt: now.subtract(const Duration(days: 1)),
      lastUpdate: now,
    ));
    final groceryItems = <(String, int, bool)>[
      ('Milk', 2, false),
      ('Bread', 1, false),
      ('Eggs', 12, true),
      ('Olive oil', 1, false),
      ('Tomatoes', 6, true),
      ('Coffee beans', 1, false),
    ];
    for (var i = 0; i < groceryItems.length; i++) {
      final (name, qty, checked) = groceryItems[i];
      store.shoppingListItems.add(ShoppingListItem(
        id: _uuid.v4(),
        listId: activeListId,
        name: name,
        qty: qty,
        sortOrder: i,
        isChecked: checked,
        checkedAt: checked ? now.subtract(const Duration(hours: 2)) : null,
        createdAt: now.subtract(const Duration(days: 1)),
        lastUpdate: now,
      ));
    }

    final paidListId = _uuid.v4();
    store.shoppingLists.add(ShoppingList(
      id: paidListId,
      householdId: householdId,
      ownerId: lucaId,
      scope: ShoppingListScope.personal,
      name: 'Hardware store',
      status: ShoppingListStatus.paid,
      kind: ShoppingListKind.session,
      sessionStartedAt: now.subtract(const Duration(days: 7)),
      sessionEndedAt: now.subtract(const Duration(days: 6)),
      bankAccountId: lucaBbva.id,
      paidAt: now.subtract(const Duration(days: 6)),
      createdAt: now.subtract(const Duration(days: 7)),
      lastUpdate: now.subtract(const Duration(days: 6)),
    ));
    for (final pair in const [('Drill bits', 1), ('Wood glue', 2)]) {
      store.shoppingListItems.add(ShoppingListItem(
        id: _uuid.v4(),
        listId: paidListId,
        name: pair.$1,
        qty: pair.$2,
        sortOrder: 0,
        isChecked: true,
        checkedAt: now.subtract(const Duration(days: 6)),
        createdAt: now.subtract(const Duration(days: 7)),
        lastUpdate: now.subtract(const Duration(days: 6)),
      ));
    }

    // Cars + fuel entries.
    final anaCar = Car(
      id: _uuid.v4(),
      householdId: householdId,
      name: 'Ana · Golf',
      make: 'Volkswagen',
      model: 'Golf',
      year: 2019,
      licensePlate: '1234 ABC',
      fuelType: FuelType.diesel,
      tankCapacityLiters: 50,
      currentOdometerKm: 78420,
      status: CarStatus.active,
      createdBy: anaId,
      createdAt: now,
      lastUpdate: now,
    );
    final sharedCar = Car(
      id: _uuid.v4(),
      householdId: householdId,
      name: 'Family · Tesla',
      make: 'Tesla',
      model: 'Model 3',
      year: 2022,
      licensePlate: '5678 EV',
      fuelType: FuelType.electric,
      tankCapacityLiters: null,
      currentOdometerKm: 32100,
      status: CarStatus.active,
      createdBy: anaId,
      createdAt: now,
      lastUpdate: now,
    );
    store.cars.addAll([anaCar, sharedCar]);
    store.carMembers.addAll([
      CarMember(
          id: _uuid.v4(), carId: anaCar.id, userId: anaId, createdAt: now),
      CarMember(
          id: _uuid.v4(), carId: sharedCar.id, userId: anaId, createdAt: now),
      CarMember(
          id: _uuid.v4(), carId: sharedCar.id, userId: lucaId, createdAt: now),
    ]);

    // Recent fill-ups for Ana's diesel Golf — realistic ~50L full tanks at
    // ~1.6 EUR/L. Odometer climbs ~600km between fills.
    final fuelSamples = <(int, double, double, double, bool)>[
      (60, 76200.0, 49.2, 1.58, true),
      (45, 76830.0, 48.1, 1.61, true),
      (32, 77460.0, 50.3, 1.62, true),
      (18, 78050.0, 47.8, 1.59, true),
      (4, 78380.0, 32.0, 1.64, false),
    ];
    for (final (d, odo, l, p, full) in fuelSamples) {
      final t = now.subtract(Duration(days: d));
      store.fuelEntries.add(FuelEntry(
        id: _uuid.v4(),
        carId: anaCar.id,
        odometerKm: odo,
        liters: l,
        pricePerLiter: p,
        totalAmount: double.parse((l * p).toStringAsFixed(2)),
        isFullTank: full,
        filledAt: t,
        createdBy: anaId,
        createdAt: t,
      ));
    }

    // Pets.
    final dog = Pet(
      id: _uuid.v4(),
      householdId: householdId,
      name: 'Max',
      species: PetSpecies.dog,
      breed: 'Labrador Retriever',
      gender: PetGender.male,
      birthDate: DateTime(2020, 3, 15),
      weightKg: 28.5,
      isActive: true,
      createdBy: anaId,
      createdAt: now,
      lastUpdate: now,
    );
    final cat = Pet(
      id: _uuid.v4(),
      householdId: householdId,
      name: 'Luna',
      species: PetSpecies.cat,
      breed: 'British Shorthair',
      gender: PetGender.female,
      birthDate: DateTime(2021, 7, 22),
      weightKg: 4.2,
      isActive: true,
      createdBy: lucaId,
      createdAt: now,
      lastUpdate: now,
    );
    store.pets.addAll([dog, cat]);

    // Health records for Max.
    store.petHealthRecords.addAll([
      PetHealthRecord(
        id: _uuid.v4(),
        petId: dog.id,
        type: HealthRecordType.vaccine,
        title: 'Annual vaccination',
        notes: 'Rabies, distemper, parvovirus',
        recordedAt: now.subtract(const Duration(days: 30)),
        nextDueAt: now.add(const Duration(days: 335)),
        cost: 65.0,
        vetName: 'Dr. García',
        createdBy: anaId,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      PetHealthRecord(
        id: _uuid.v4(),
        petId: dog.id,
        type: HealthRecordType.deworming,
        title: 'Deworming',
        recordedAt: now.subtract(const Duration(days: 14)),
        nextDueAt: now.add(const Duration(days: 76)),
        cost: 18.5,
        vetName: 'Dr. García',
        createdBy: anaId,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      PetHealthRecord(
        id: _uuid.v4(),
        petId: dog.id,
        type: HealthRecordType.vet,
        title: 'Routine check-up',
        notes: 'All good, slight tartar build-up',
        recordedAt: now.subtract(const Duration(days: 90)),
        cost: 45.0,
        vetName: 'Dr. García',
        createdBy: anaId,
        createdAt: now.subtract(const Duration(days: 90)),
      ),
    ]);

    // Health records for Luna.
    store.petHealthRecords.addAll([
      PetHealthRecord(
        id: _uuid.v4(),
        petId: cat.id,
        type: HealthRecordType.vaccine,
        title: 'Feline vaccination',
        notes: 'FVRCP booster',
        recordedAt: now.subtract(const Duration(days: 60)),
        nextDueAt: now.add(const Duration(days: 305)),
        cost: 55.0,
        vetName: 'Clínica Felina',
        createdBy: lucaId,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      PetHealthRecord(
        id: _uuid.v4(),
        petId: cat.id,
        type: HealthRecordType.grooming,
        title: 'Grooming session',
        recordedAt: now.subtract(const Duration(days: 7)),
        cost: 30.0,
        createdBy: lucaId,
        createdAt: now.subtract(const Duration(days: 7)),
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
