import 'package:home_expenses/data/repositories/auth_repository_impl.dart';
import 'package:home_expenses/data/repositories/category_repository_impl.dart';
import 'package:home_expenses/data/repositories/goal_repository_impl.dart';
import 'package:home_expenses/data/repositories/household_repository_impl.dart';
import 'package:home_expenses/data/repositories/money_source_repository_impl.dart';
import 'package:home_expenses/data/repositories/notification_repository_impl.dart';
import 'package:home_expenses/data/repositories/transaction_repository_impl.dart';

import 'package:home_expenses/data/services/auth_service.dart';
import 'package:home_expenses/data/services/category_service.dart';
import 'package:home_expenses/data/services/goal_service.dart';
import 'package:home_expenses/data/services/money_source_service.dart';
import 'package:home_expenses/data/services/notification_service.dart';
import 'package:home_expenses/data/services/push_notification_service.dart';
import 'package:home_expenses/data/services/supabase_service.dart';
import 'package:home_expenses/data/services/transaction_service.dart';

import 'package:home_expenses/domain/repositories/auth_repository.dart';
import 'package:home_expenses/domain/repositories/category_repository.dart';
import 'package:home_expenses/domain/repositories/goal_repository.dart';
import 'package:home_expenses/domain/repositories/household_repository.dart';
import 'package:home_expenses/domain/repositories/money_source_repository.dart';
import 'package:home_expenses/domain/repositories/notification_repository.dart';
import 'package:home_expenses/domain/repositories/transaction_repository.dart';

/// Lightweight service locator. No external package needed.
/// Initialize once in main.dart, access anywhere via AppDependencies.instance.
class AppDependencies {
  static late final AppDependencies instance;

  // Services
  late final AuthService authService;
  late final TransactionService transactionService;
  late final CategoryService categoryService;
  late final MoneySourceService moneySourceService;
  late final GoalService goalService;
  late final NotificationService notificationService;
  late final PushNotificationService pushNotificationService;

  // Repositories
  late final AuthRepository authRepository;
  late final TransactionRepository transactionRepository;
  late final CategoryRepository categoryRepository;
  late final MoneySourceRepository moneySourceRepository;
  late final GoalRepository goalRepository;
  late final HouseholdRepository householdRepository;
  late final NotificationRepository notificationRepository;

  AppDependencies._();

  static Future<void> initialize() async {
    final deps = AppDependencies._();

    // Services
    deps.authService = AuthService();
    deps.transactionService = TransactionService();
    deps.categoryService = CategoryService();
    deps.moneySourceService = MoneySourceService();
    deps.goalService = GoalService();
    deps.notificationService = NotificationService();
    deps.pushNotificationService = PushNotificationService();

    // Repositories
    deps.authRepository = AuthRepositoryImpl(deps.authService);
    deps.transactionRepository =
        TransactionRepositoryImpl(deps.transactionService);
    deps.categoryRepository = CategoryRepositoryImpl(deps.categoryService);
    deps.moneySourceRepository =
        MoneySourceRepositoryImpl(deps.moneySourceService);
    deps.goalRepository = GoalRepositoryImpl(deps.goalService);
    deps.householdRepository = HouseholdRepositoryImpl(SupabaseService());
    deps.notificationRepository =
        NotificationRepositoryImpl(deps.notificationService);

    instance = deps;
  }
}
