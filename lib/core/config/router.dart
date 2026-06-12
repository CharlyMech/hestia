import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/presentation/pages/auth/login_screen.dart';
import 'package:hestia/presentation/pages/fuel/add_edit_car_screen.dart';
import 'package:hestia/presentation/pages/pets/add_edit_health_record_screen.dart';
import 'package:hestia/presentation/pages/pets/add_edit_pet_screen.dart';
import 'package:hestia/presentation/pages/pets/pet_detail_screen.dart';
import 'package:hestia/presentation/pages/transactions/transaction_map_picker_screen.dart';
import 'package:hestia/domain/entities/pet_health_record.dart';
import 'package:hestia/presentation/pages/fuel/add_edit_fuel_entry_screen.dart';
import 'package:hestia/presentation/pages/fuel/car_detail_screen.dart';
import 'package:hestia/presentation/pages/fuel/cars_standalone_screen.dart';
import 'package:hestia/presentation/pages/fuel/fuel_analytics_screen.dart';
import 'package:hestia/domain/entities/fuel_entry.dart';
import 'package:hestia/presentation/pages/categories/categories_screen.dart';
import 'package:hestia/presentation/pages/goals/add_edit_goals_screen.dart';
import 'package:hestia/presentation/pages/goals/goal_detail_screen.dart';
import 'package:hestia/presentation/pages/goals/goals_screen.dart';
import 'package:hestia/presentation/pages/main_tab_shell.dart';
import 'package:hestia/domain/entities/account_member.dart';
import 'package:hestia/domain/entities/bank_account.dart' show BankAccount;
import 'package:hestia/domain/entities/payment_card.dart';
import 'package:hestia/presentation/blocs/cards/cards_bloc.dart';
import 'package:hestia/presentation/pages/cards/add_edit_card_screen.dart';
import 'package:hestia/presentation/pages/bank_accounts/add_edit_bank_account_screen.dart';
import 'package:hestia/presentation/pages/bank_accounts/bank_account_detail_screen.dart';
import 'package:hestia/presentation/pages/bank_accounts/bank_accounts_screen.dart';
import 'package:hestia/presentation/pages/bank_accounts/recurring_transactions_screen.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/presentation/pages/appointments/add_edit_appointment_screen.dart';
import 'package:hestia/presentation/pages/appointments/appointment_detail_screen.dart';
import 'package:hestia/presentation/pages/calendar/calendar_screen.dart';
import 'package:hestia/presentation/pages/notifications/notification_detail_screen.dart';
import 'package:hestia/presentation/pages/notifications/notifications_screen.dart';
import 'package:hestia/presentation/pages/profile/profile_screen.dart';
import 'package:hestia/presentation/pages/settings/settings_screen.dart';
import 'package:hestia/presentation/pages/settings/data_management_screen.dart';
import 'package:hestia/presentation/pages/homes/homes_screen.dart';
import 'package:hestia/presentation/pages/map/global_map_screen.dart';
import 'package:hestia/presentation/pages/onboarding/onboarding_screen.dart';
import 'package:hestia/presentation/pages/splash/custom_splash_screen.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/pages/shopping/add_edit_shopping_list_screen.dart';
import 'package:hestia/presentation/pages/shopping/shopping_list_detail_screen.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/presentation/pages/transaction_sources/transaction_sources_screen.dart';
import 'package:hestia/presentation/pages/transactions/add_edit_transaction_screen.dart';
import 'package:hestia/presentation/pages/transactions/transaction_detail_screen.dart';
import 'package:hestia/presentation/pages/transactions/transactions_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';

  /// Persistent tab shell — Home · Accounts · Pets · [Cars] · Shopping.
  /// Use `?tab=N` with a [PageView] index (see constants below).
  static const main = '/main';

  static const tabHome = 0;
  static const tabAccounts = 1;
  static const tabPets = 2;

  /// Page index when the cars module is enabled (between Pets and Shopping).
  static const tabCars = 3;

  /// Shopping is always the last page: index 3 without cars, 4 with cars.
  static const tabShoppingNoCars = 3;
  static const tabShoppingWithCars = 4;

  static const dashboard = '$main?tab=$tabHome';
  static const accounts = '$main?tab=$tabAccounts';

  /// Goals is now a pushed route, not a tab.
  static const goals = '/goals';

  static const transactions = '/transactions';
  static const editTransaction = '/transactions/edit';
  static const transactionDetail = '/transactions/detail';
  static const transactionSources = '/transaction-sources';
  static const addShoppingList = '/shopping/list/add';
  static const shoppingListDetail = '/shopping/list';
  static const categories = '/categories';
  static const bankAccounts = '/bank-accounts';
  static const addBankAccount = '/bank-accounts/add';
  static const editBankAccount = '/bank-accounts/edit';
  static const bankAccountDetail = '/bank-accounts/detail';
  static const recurringTransactions = '/bank-accounts/recurring';
  static const addCard = '/bank-accounts/cards/add';
  static const editCard = '/bank-accounts/cards/edit';
  static const addGoal = '/goals/add';
  static const editGoal = '/goals/edit';
  static const goalDetail = '/goals/detail';
  static const notifications = '/notifications';
  static const notificationDetail = '/notifications/detail';
  static const profile = '/profile';
  static const settings = '/settings';
  static const dataManagement = '/data-management';
  static const addAppointment = '/appointments/add';
  static const editAppointment = '/appointments/edit';
  static const appointmentDetail = '/appointments/detail';

  // Pets module
  static const pets = '/pets';
  static const addPet = '/pets/add';
  static const editPet = '/pets/edit';
  static const petDetail = '/pets/detail';
  static const addHealthRecord = '/pets/health/add';
  static const editHealthRecord = '/pets/health/edit';

  // Calendar (pushed route — not a tab)
  static const calendarScreen = '/calendar';

  // Cars module
  static const cars = '/cars';
  static const addCar = '/cars/add';
  static const editCar = '/cars/edit';
  static const carDetail = '/cars/detail';
  static const addCarEntry = '/cars/entries/add';
  static const editCarEntry = '/cars/entries/edit';
  static const carAnalytics = '/cars/analytics';

  /// Pick GPS coordinates for a transaction (returns (lat,lng) record via `pop`).
  static const transactionMapPicker = '/transactions/map-picker';
  static const globalMap = '/map';
  static const homes = '/homes';
}

/// Root navigator for [appRouter] — use for push notification routing / toasts.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Drives router redirects on auth changes. AuthBloc updates this via the
/// BlocListener in app.dart. `null` = unknown (still on splash / checking).
final authStatusListenable = ValueNotifier<bool?>(null);

/// Whether the user has completed onboarding (set from prefs at startup).
bool routerOnboardingSeen = false;

const _authRoutes = {AppRoutes.splash, AppRoutes.login, AppRoutes.onboarding};

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  refreshListenable: authStatusListenable,
  redirect: (context, state) {
    final isAuth = authStatusListenable.value;
    final loc = state.matchedLocation;

    // Unknown auth state → let the splash screen resolve it.
    if (isAuth == null) return null;

    final onAuthRoute = _authRoutes.contains(loc);

    if (!isAuth) {
      // Signed out → always land on onboarding (its Skip/finish routes to
      // login). Re-showing onboarding after logout is cheap and intentional.
      if (onAuthRoute) return null;
      return AppRoutes.onboarding;
    }

    // Signed in but sitting on splash/login → go to the app.
    if (loc == AppRoutes.splash || loc == AppRoutes.login) {
      return AppRoutes.dashboard;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => const CupertinoPage(
        child: CustomSplashScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (context, state) => const CupertinoPage(
        child: OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => const CupertinoPage(
        child: LoginScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.main,
      pageBuilder: (context, state) {
        final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
        return CupertinoPage(child: MainTabShell(initialTab: tab));
      },
    ),
    GoRoute(
      path: AppRoutes.editTransaction,
      pageBuilder: (context, state) {
        final transaction = state.extra as Transaction;
        return CupertinoPage(
          child: AddEditTransactionScreen(transaction: transaction),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.transactionDetail,
      pageBuilder: (context, state) {
        final transaction = state.extra as Transaction;
        return CupertinoPage(
          child: TransactionDetailScreen(transaction: transaction),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.categories,
      pageBuilder: (context, state) => const CupertinoPage(
        child: CategoriesScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.bankAccounts,
      pageBuilder: (context, state) => const CupertinoPage(
        child: BankAccountsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addBankAccount,
      pageBuilder: (context, state) => const CupertinoPage(
        child: AddEditBankAccountScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.editBankAccount,
      pageBuilder: (context, state) {
        final existing = state.extra as BankAccount?;
        return CupertinoPage(
          child: AddEditBankAccountScreen(existing: existing),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bankAccountDetail,
      pageBuilder: (context, state) {
        final sourceId = state.extra as String;
        return CupertinoPage(
          child: BankAccountDetailScreen(sourceId: sourceId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.recurringTransactions,
      pageBuilder: (context, state) {
        final sourceId = state.extra as String;
        return CupertinoPage(
          child: RecurringTransactionsScreen(sourceId: sourceId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.goals,
      pageBuilder: (context, state) => const CupertinoPage(
        child: GoalsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addGoal,
      pageBuilder: (context, state) {
        final sourceId = state.extra as String?;
        return CupertinoPage(
          child: AddEditGoalScreen(prefilledBankAccountId: sourceId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.editGoal,
      pageBuilder: (context, state) {
        final goalId = state.extra as String;
        return CupertinoPage(
          child: AddEditGoalScreen(goalId: goalId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.goalDetail,
      pageBuilder: (context, state) {
        final goalId = state.extra as String;
        return CupertinoPage(
          child: GoalDetailScreen(goalId: goalId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.notifications,
      pageBuilder: (context, state) => const CupertinoPage(
        child: NotificationsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.notificationDetail,
      pageBuilder: (context, state) {
        final n = state.extra as AppNotification;
        return CupertinoPage(child: NotificationDetailScreen(notification: n));
      },
    ),
    GoRoute(
      path: AppRoutes.transactions,
      pageBuilder: (context, state) => const CupertinoPage(
        child: TransactionsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.transactionSources,
      pageBuilder: (context, state) => const CupertinoPage(
        child: TransactionSourcesScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addShoppingList,
      pageBuilder: (context, state) {
        final args = state.extra as (String, String);
        return CupertinoPage(
          child: AddEditShoppingListScreen(
            householdId: args.$1,
            userId: args.$2,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.shoppingListDetail,
      pageBuilder: (context, state) {
        final list = state.extra as ShoppingList;
        return CupertinoPage(
          child: ShoppingListDetailScreen(list: list),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      pageBuilder: (context, state) => const CupertinoPage(
        child: ProfileScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) => const CupertinoPage(
        child: SettingsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.dataManagement,
      pageBuilder: (context, state) => const CupertinoPage(
        child: DataManagementScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addAppointment,
      pageBuilder: (context, state) {
        final defaultDate = state.extra as DateTime?;
        return CupertinoPage(
          child: AddEditAppointmentScreen(defaultDate: defaultDate),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.editAppointment,
      pageBuilder: (context, state) {
        final appointment = state.extra as Appointment;
        return CupertinoPage(
          child: AddEditAppointmentScreen(existing: appointment),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.pets,
      redirect: (context, state) =>
          '${AppRoutes.main}?tab=${AppRoutes.tabPets}',
    ),
    GoRoute(
      path: AppRoutes.addPet,
      pageBuilder: (context, state) => const CupertinoPage(
        child: AddEditPetScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.editPet,
      pageBuilder: (context, state) {
        final id = state.extra as String;
        return CupertinoPage(child: AddEditPetScreen(petId: id));
      },
    ),
    GoRoute(
      path: AppRoutes.petDetail,
      pageBuilder: (context, state) {
        final id = state.extra as String;
        return CupertinoPage(child: PetDetailScreen(petId: id));
      },
    ),
    GoRoute(
      path: AppRoutes.addHealthRecord,
      pageBuilder: (context, state) {
        final petId = state.extra as String;
        return CupertinoPage(child: AddEditHealthRecordScreen(petId: petId));
      },
    ),
    GoRoute(
      path: AppRoutes.editHealthRecord,
      pageBuilder: (context, state) {
        final record = state.extra as PetHealthRecord;
        return CupertinoPage(
            child: AddEditHealthRecordScreen(existing: record));
      },
    ),
    GoRoute(
      path: AppRoutes.cars,
      pageBuilder: (context, state) => const CupertinoPage(
        child: CarsStandaloneScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addCar,
      pageBuilder: (context, state) => const CupertinoPage(
        child: AddEditCarScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.editCar,
      pageBuilder: (context, state) {
        final id = state.extra as String;
        return CupertinoPage(child: AddEditCarScreen(carId: id));
      },
    ),
    GoRoute(
      path: AppRoutes.carDetail,
      pageBuilder: (context, state) {
        final id = state.extra as String;
        return CupertinoPage(child: CarDetailScreen(carId: id));
      },
    ),
    GoRoute(
      path: AppRoutes.addCarEntry,
      pageBuilder: (context, state) {
        final carId = state.extra as String;
        return CupertinoPage(child: AddEditFuelEntryScreen(carId: carId));
      },
    ),
    GoRoute(
      path: AppRoutes.editCarEntry,
      pageBuilder: (context, state) {
        final entry = state.extra as FuelEntry;
        return CupertinoPage(child: AddEditFuelEntryScreen(entry: entry));
      },
    ),
    GoRoute(
      path: AppRoutes.carAnalytics,
      pageBuilder: (context, state) {
        final id = state.extra as String;
        return CupertinoPage(child: FuelAnalyticsScreen(carId: id));
      },
    ),
    GoRoute(
      path: AppRoutes.transactionMapPicker,
      pageBuilder: (context, state) {
        final extra = state.extra;
        double? lat;
        double? lng;
        if (extra is (double, double)) {
          lat = extra.$1;
          lng = extra.$2;
        }
        return CupertinoPage(
          child: TransactionMapPickerScreen(
            initialLatitude: lat,
            initialLongitude: lng,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.globalMap,
      pageBuilder: (context, state) => const CupertinoPage(
        child: GlobalMapScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.homes,
      pageBuilder: (context, state) => const CupertinoPage(
        child: HomesScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.calendarScreen,
      pageBuilder: (context, state) => const CupertinoPage(
        child: CalendarScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.appointmentDetail,
      pageBuilder: (context, state) {
        final appointment = state.extra as Appointment;
        return CupertinoPage(
          child: AppointmentDetailScreen(appointment: appointment),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.addCard,
      pageBuilder: (context, state) {
        final extra = state.extra as ({
          BankAccount account,
          List<AccountMember> accountMembers,
          CardsBloc cardsBloc,
        });
        return CupertinoPage(
          child: BlocProvider.value(
            value: extra.cardsBloc,
            child: AddEditCardScreen(
              account: extra.account,
              accountMembers: extra.accountMembers,
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.editCard,
      pageBuilder: (context, state) {
        final extra = state.extra as ({
          BankAccount account,
          List<AccountMember> accountMembers,
          PaymentCard card,
          CardsBloc cardsBloc,
        });
        return CupertinoPage(
          child: BlocProvider.value(
            value: extra.cardsBloc,
            child: AddEditCardScreen(
              account: extra.account,
              accountMembers: extra.accountMembers,
              existing: extra.card,
            ),
          ),
        );
      },
    ),
  ],
);
