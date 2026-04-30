import 'package:hestia/core/config/flavor.dart';
import 'package:hestia/core/services/user_preferences_service.dart';
import 'package:hestia/data/mock/mock_appointment_repository.dart';
import 'package:hestia/data/mock/mock_auth_repository.dart';
import 'package:hestia/data/mock/mock_category_repository.dart';
import 'package:hestia/data/mock/mock_goal_repository.dart';
import 'package:hestia/data/mock/mock_household_repository.dart';
import 'package:hestia/data/mock/mock_money_source_repository.dart';
import 'package:hestia/data/mock/mock_notification_repository.dart';
import 'package:hestia/data/mock/mock_seed.dart';
import 'package:hestia/data/mock/mock_transaction_repository.dart';
import 'package:hestia/data/repositories/appointment_repository_impl.dart';
import 'package:hestia/data/repositories/auth_repository_impl.dart';
import 'package:hestia/data/repositories/category_repository_impl.dart';
import 'package:hestia/data/repositories/goal_repository_impl.dart';
import 'package:hestia/data/repositories/household_repository_impl.dart';
import 'package:hestia/data/repositories/money_source_repository_impl.dart';
import 'package:hestia/data/repositories/notification_repository_impl.dart';
import 'package:hestia/data/repositories/transaction_repository_impl.dart';

import 'package:hestia/data/services/appointment_service.dart';
import 'package:hestia/data/services/auth_service.dart';
import 'package:hestia/data/services/category_service.dart';
import 'package:hestia/data/services/goal_service.dart';
import 'package:hestia/data/services/google_calendar_service.dart';
import 'package:hestia/data/services/money_source_service.dart';
import 'package:hestia/data/services/notification_service.dart';
// TODO: uncomment after Firebase project is configured
// import 'package:hestia/data/services/push_notification_service.dart';
import 'package:hestia/data/services/supabase_service.dart';
import 'package:hestia/data/services/transaction_service.dart';

import 'package:hestia/domain/repositories/appointment_repository.dart';
import 'package:hestia/domain/repositories/auth_repository.dart';
import 'package:hestia/domain/repositories/category_repository.dart';
import 'package:hestia/domain/repositories/goal_repository.dart';
import 'package:hestia/domain/repositories/household_repository.dart';
import 'package:hestia/domain/repositories/money_source_repository.dart';
import 'package:hestia/domain/repositories/notification_repository.dart';
import 'package:hestia/domain/repositories/transaction_repository.dart';

/// Lightweight service locator. No external package needed.
/// Initialize once in main.dart, access anywhere via AppDependencies.instance.
/// Branches between mock and supabase repository implementations based on
/// the active [AppFlavor].
class AppDependencies {
  static late final AppDependencies instance;

  // Services (only wired in supabase flavor)
  AuthService? authService;
  TransactionService? transactionService;
  CategoryService? categoryService;
  MoneySourceService? moneySourceService;
  GoalService? goalService;
  NotificationService? notificationService;
  AppointmentService? appointmentService;
  GoogleCalendarService? googleCalendarService;
  // TODO: initialize PushNotificationService after Firebase project is set up
  // late final PushNotificationService pushNotificationService;

  // Preferences
  late final UserPreferencesService userPreferencesService;

  // Repositories
  late final AuthRepository authRepository;
  late final TransactionRepository transactionRepository;
  late final CategoryRepository categoryRepository;
  late final MoneySourceRepository moneySourceRepository;
  late final GoalRepository goalRepository;
  late final HouseholdRepository householdRepository;
  late final NotificationRepository notificationRepository;
  late final AppointmentRepository appointmentRepository;

  AppDependencies._();

  static Future<void> initialize(AppFlavor flavor) async {
    final deps = AppDependencies._();

    deps.userPreferencesService = await UserPreferencesService.create();

    if (flavor == AppFlavor.mock) {
      MockSeed.load();
      deps.authRepository = MockAuthRepository();
      deps.transactionRepository = MockTransactionRepository();
      deps.categoryRepository = MockCategoryRepository();
      deps.moneySourceRepository = MockMoneySourceRepository();
      deps.goalRepository = MockGoalRepository();
      deps.householdRepository = MockHouseholdRepository();
      deps.notificationRepository = MockNotificationRepository();
      deps.appointmentRepository = MockAppointmentRepository();
    } else {
      // Services
      deps.authService = AuthService();
      deps.transactionService = TransactionService();
      deps.categoryService = CategoryService();
      deps.moneySourceService = MoneySourceService();
      deps.goalService = GoalService();
      deps.notificationService = NotificationService();
      deps.appointmentService = AppointmentService();
      deps.googleCalendarService = GoogleCalendarService();
      // TODO: uncomment after Firebase project is configured (flutterfire configure)
      // deps.pushNotificationService = PushNotificationService();

      // Repositories
      deps.authRepository = AuthRepositoryImpl(deps.authService!);
      deps.transactionRepository =
          TransactionRepositoryImpl(deps.transactionService!);
      deps.categoryRepository = CategoryRepositoryImpl(deps.categoryService!);
      deps.moneySourceRepository =
          MoneySourceRepositoryImpl(deps.moneySourceService!);
      deps.goalRepository = GoalRepositoryImpl(deps.goalService!);
      deps.householdRepository = HouseholdRepositoryImpl(SupabaseService());
      deps.notificationRepository =
          NotificationRepositoryImpl(deps.notificationService!);
      deps.appointmentRepository = AppointmentRepositoryImpl(
        deps.appointmentService!,
        deps.googleCalendarService!,
      );
    }

    instance = deps;
  }
}
