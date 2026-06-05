import 'package:hestia/core/config/flavor.dart';
import 'package:hestia/core/services/location_service.dart';
import 'package:hestia/core/services/user_preferences_service.dart';
import 'package:hestia/data/repositories/account_member_repository_impl.dart';
import 'package:hestia/data/repositories/app_version_repository_impl.dart';
import 'package:hestia/data/repositories/appointment_repository_impl.dart';
import 'package:hestia/data/repositories/auth_repository_impl.dart';
import 'package:hestia/data/repositories/card_repository_impl.dart';
import 'package:hestia/data/repositories/category_repository_impl.dart';
import 'package:hestia/data/repositories/financial_institution_repository_impl.dart';
import 'package:hestia/data/repositories/goal_repository_impl.dart';
import 'package:hestia/data/repositories/household_repository_impl.dart';
import 'package:hestia/data/repositories/bank_account_repository_impl.dart';
import 'package:hestia/data/repositories/car_repository_impl.dart';
import 'package:hestia/data/repositories/fuel_entry_repository_impl.dart';
import 'package:hestia/data/repositories/pet_repository_impl.dart';
import 'package:hestia/data/repositories/pet_measurement_repository_impl.dart';
import 'package:hestia/data/repositories/transaction_source_repository_impl.dart';
import 'package:hestia/data/repositories/shopping_repository_impl.dart';
import 'package:hestia/data/repositories/shopping_session_repository_impl.dart';
import 'package:hestia/data/repositories/home_repository_impl.dart';
import 'package:hestia/data/repositories/notification_repository_impl.dart';
import 'package:hestia/data/repositories/transaction_repository_impl.dart';

import 'package:hestia/data/services/account_member_service.dart';
import 'package:hestia/data/services/app_version_service.dart';
import 'package:hestia/data/services/appointment_service.dart';
import 'package:hestia/data/services/auth_service.dart';
import 'package:hestia/data/services/card_service.dart';
import 'package:hestia/data/services/category_service.dart';
import 'package:hestia/data/services/financial_institution_service.dart';
import 'package:hestia/data/services/image_upload_service.dart';
import 'package:hestia/data/services/goal_service.dart';
import 'package:hestia/data/services/google_calendar_service.dart';
import 'package:hestia/data/services/bank_account_service.dart';
import 'package:hestia/data/services/car_service.dart';
import 'package:hestia/data/services/fuel_entry_service.dart';
import 'package:hestia/data/services/pet_service.dart';
import 'package:hestia/data/services/pet_measurement_service.dart';
import 'package:hestia/data/services/transaction_source_service.dart';
import 'package:hestia/data/services/shopping_service.dart';
import 'package:hestia/data/services/shopping_session_service.dart';
import 'package:hestia/data/services/home_service.dart';
import 'package:hestia/data/services/notification_service.dart';
import 'package:hestia/data/services/push_notification_service.dart';
import 'package:hestia/data/services/shopping_realtime_service.dart';
import 'package:hestia/data/services/supabase_service.dart';
import 'package:hestia/data/services/transaction_service.dart';

import 'package:hestia/domain/repositories/account_member_repository.dart';
import 'package:hestia/domain/repositories/app_version_repository.dart';
import 'package:hestia/domain/repositories/appointment_repository.dart';
import 'package:hestia/domain/repositories/auth_repository.dart';
import 'package:hestia/domain/repositories/card_repository.dart';
import 'package:hestia/domain/repositories/category_repository.dart';
import 'package:hestia/domain/repositories/financial_institution_repository.dart';
import 'package:hestia/domain/repositories/goal_repository.dart';
import 'package:hestia/domain/repositories/household_repository.dart';
import 'package:hestia/domain/repositories/bank_account_repository.dart';
import 'package:hestia/domain/repositories/car_repository.dart';
import 'package:hestia/domain/repositories/fuel_entry_repository.dart';
import 'package:hestia/domain/repositories/pet_repository.dart';
import 'package:hestia/domain/repositories/notification_repository.dart';
import 'package:hestia/domain/repositories/home_repository.dart';
import 'package:hestia/domain/repositories/pet_measurement_repository.dart';
import 'package:hestia/domain/repositories/shopping_repository.dart';
import 'package:hestia/domain/repositories/shopping_session_repository.dart';
import 'package:hestia/domain/repositories/transaction_repository.dart';
import 'package:hestia/domain/repositories/transaction_source_repository.dart';

/// Lightweight service locator. Initialize once in main.dart,
/// access anywhere via AppDependencies.instance.
class AppDependencies {
  static late final AppDependencies instance;

  // Services
  AuthService? authService;
  TransactionService? transactionService;
  CategoryService? categoryService;
  BankAccountService? bankAccountService;
  GoalService? goalService;
  NotificationService? notificationService;
  AppVersionService? appVersionService;
  AppointmentService? appointmentService;
  GoogleCalendarService? googleCalendarService;
  FinancialInstitutionService? financialInstitutionService;
  CardService? cardService;
  AccountMemberService? accountMemberService;
  late final PushNotificationService pushNotificationService;

  // Preferences & platform services
  late final UserPreferencesService userPreferencesService;
  late final ImageUploadService imageUploadService;
  late final LocationService locationService;
  late final ShoppingRealtimeService shoppingRealtimeService;

  // Repositories
  late final AuthRepository authRepository;
  late final TransactionRepository transactionRepository;
  late final CategoryRepository categoryRepository;
  late final BankAccountRepository bankAccountRepository;
  late final FinancialInstitutionRepository financialInstitutionRepository;
  late final CardRepository cardRepository;
  late final AccountMemberRepository accountMemberRepository;
  late final CarRepository carRepository;
  late final FuelEntryRepository fuelEntryRepository;
  late final PetRepository petRepository;
  late final PetMeasurementRepository petMeasurementRepository;
  late final TransactionSourceRepository transactionSourceRepository;
  late final ShoppingRepository shoppingRepository;
  late final ShoppingSessionRepository shoppingSessionRepository;
  late final HomeRepository homeRepository;
  late final GoalRepository goalRepository;
  late final HouseholdRepository householdRepository;
  late final NotificationRepository notificationRepository;
  late final AppointmentRepository appointmentRepository;
  late final AppVersionRepository appVersionRepository;

  AppDependencies._();

  static Future<void> initialize(AppFlavor flavor) async {
    final deps = AppDependencies._();

    deps.userPreferencesService = await UserPreferencesService.create();
    deps.imageUploadService = SupabaseImageUploadService();
    deps.locationService = LocationService();
    deps.shoppingRealtimeService = ShoppingRealtimeService();
    deps.pushNotificationService =
        PushNotificationService(NotificationService());

    // Services
    deps.authService = AuthService();
    deps.transactionService = TransactionService();
    deps.categoryService = CategoryService();
    deps.bankAccountService = BankAccountService();
    deps.goalService = GoalService();
    deps.notificationService = NotificationService();
    deps.appVersionService = AppVersionService();
    deps.appointmentService = AppointmentService();
    deps.googleCalendarService = GoogleCalendarService();
    deps.financialInstitutionService = FinancialInstitutionService();
    deps.cardService = CardService();
    deps.accountMemberService = AccountMemberService();

    // Repositories
    deps.authRepository = AuthRepositoryImpl(deps.authService!);
    deps.transactionRepository =
        TransactionRepositoryImpl(deps.transactionService!);
    deps.categoryRepository = CategoryRepositoryImpl(deps.categoryService!);
    deps.bankAccountRepository =
        BankAccountRepositoryImpl(deps.bankAccountService!);
    deps.financialInstitutionRepository =
        FinancialInstitutionRepositoryImpl(deps.financialInstitutionService!);
    deps.cardRepository = CardRepositoryImpl(deps.cardService!);
    deps.accountMemberRepository =
        AccountMemberRepositoryImpl(deps.accountMemberService!);
    deps.carRepository = CarRepositoryImpl(CarService());
    deps.fuelEntryRepository = FuelEntryRepositoryImpl(FuelEntryService());
    deps.petRepository = PetRepositoryImpl(PetService());
    deps.petMeasurementRepository =
        PetMeasurementRepositoryImpl(PetMeasurementService());
    deps.transactionSourceRepository =
        TransactionSourceRepositoryImpl(TransactionSourceService());
    deps.shoppingRepository = ShoppingRepositoryImpl(ShoppingService());
    deps.shoppingSessionRepository =
        ShoppingSessionRepositoryImpl(ShoppingSessionService());
    deps.homeRepository = HomeRepositoryImpl(HomeService());
    deps.goalRepository = GoalRepositoryImpl(deps.goalService!);
    deps.householdRepository = HouseholdRepositoryImpl(SupabaseService());
    deps.notificationRepository =
        NotificationRepositoryImpl(deps.notificationService!);
    deps.appointmentRepository = AppointmentRepositoryImpl(
      deps.appointmentService!,
      deps.googleCalendarService!,
    );
    deps.appVersionRepository =
        AppVersionRepositoryImpl(deps.appVersionService!);

    instance = deps;
  }
}
