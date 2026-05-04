import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/presentation/pages/auth/login_screen.dart';
import 'package:hestia/presentation/pages/categories/categories_screen.dart';
import 'package:hestia/presentation/pages/goals/add_edit_goals_screen.dart';
import 'package:hestia/presentation/pages/goals/goal_detail_screen.dart';
import 'package:hestia/presentation/pages/goals/goals_screen.dart';
import 'package:hestia/presentation/pages/main_tab_shell.dart';
import 'package:hestia/presentation/pages/bank_accounts/add_edit_bank_account_screen.dart';
import 'package:hestia/presentation/pages/bank_accounts/bank_account_detail_screen.dart';
import 'package:hestia/presentation/pages/bank_accounts/bank_accounts_screen.dart';
import 'package:hestia/presentation/pages/bank_accounts/recurring_transactions_screen.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/presentation/pages/appointments/add_edit_appointment_screen.dart';
import 'package:hestia/presentation/pages/appointments/appointment_detail_screen.dart';
import 'package:hestia/presentation/pages/notifications/notification_detail_screen.dart';
import 'package:hestia/presentation/pages/notifications/notifications_screen.dart';
import 'package:hestia/presentation/pages/profile/profile_screen.dart';
import 'package:hestia/presentation/pages/settings/settings_screen.dart';
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
  static const login = '/login';

  /// Persistent tab shell — Dashboard / Calendar / Shopping / Accounts.
  /// Use `?tab=N` (0..3) to land on a specific tab.
  static const main = '/main';

  /// Tab indices for [main] deep-links.
  static const tabHome = 0;
  static const tabCalendar = 1;
  static const tabShopping = 2;
  static const tabAccounts = 3;

  // Convenience aliases — push goes to /main with tab query.
  static const dashboard = '$main?tab=$tabHome';
  static const calendar = '$main?tab=$tabCalendar';
  static const shopping = '$main?tab=$tabShopping';
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
  static const addGoal = '/goals/add';
  static const editGoal = '/goals/edit';
  static const goalDetail = '/goals/detail';
  static const notifications = '/notifications';
  static const notificationDetail = '/notifications/detail';
  static const profile = '/profile';
  static const settings = '/settings';
  static const addAppointment = '/appointments/add';
  static const editAppointment = '/appointments/edit';
  static const appointmentDetail = '/appointments/detail';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => const CupertinoPage(
        child: CustomSplashScreen(),
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
        final sourceId = state.extra as String;
        return CupertinoPage(
          child: AddEditBankAccountScreen(sourceId: sourceId),
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
      path: AppRoutes.appointmentDetail,
      pageBuilder: (context, state) {
        final appointment = state.extra as Appointment;
        return CupertinoPage(
          child: AppointmentDetailScreen(appointment: appointment),
        );
      },
    ),
  ],
);
