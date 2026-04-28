import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/presentation/pages/auth/login_screen.dart';
import 'package:hestia/presentation/pages/categories/categories_screen.dart';
import 'package:hestia/presentation/pages/dashboard/dashboard_screen.dart';
import 'package:hestia/presentation/pages/goals/add_edit_goals_screen.dart';
import 'package:hestia/presentation/pages/goals/goal_detail_screen.dart';
import 'package:hestia/presentation/pages/goals/goals_screen.dart';
import 'package:hestia/presentation/pages/money_sources/add_edit_money_sources_screen.dart';
import 'package:hestia/presentation/pages/money_sources/money_sources_screen.dart';
import 'package:hestia/presentation/pages/notifications/notifications_screen.dart';
import 'package:hestia/presentation/pages/settings/settings_screen.dart';
import 'package:hestia/presentation/pages/splash/custom_splash_screen.dart';
import 'package:hestia/presentation/pages/transactions/add_edit_transaction_screen.dart';
import 'package:hestia/presentation/pages/transactions/transactions_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const transactions = '/transactions';
  static const addTransaction = '/transactions/add';
  static const editTransaction = '/transactions/edit';
  static const categories = '/categories';
  static const moneySources = '/money-sources';
  static const addMoneySource = '/money-sources/add';
  static const editMoneySource = '/money-sources/edit';
  static const goals = '/goals';
  static const addGoal = '/goals/add';
  static const editGoal = '/goals/edit';
  static const goalDetail = '/goals/detail';
  static const notifications = '/notifications';
  static const settings = '/settings';
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
      path: AppRoutes.dashboard,
      pageBuilder: (context, state) => const CupertinoPage(
        child: DashboardScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.transactions,
      pageBuilder: (context, state) => const CupertinoPage(
        child: TransactionsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addTransaction,
      pageBuilder: (context, state) => const CupertinoPage(
        child: AddEditTransactionScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.editTransaction,
      pageBuilder: (context, state) {
        final transactionId = state.extra as String;
        return CupertinoPage(
          child: AddEditTransactionScreen(transactionId: transactionId),
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
      path: AppRoutes.moneySources,
      pageBuilder: (context, state) => const CupertinoPage(
        child: MoneySourcesScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addMoneySource,
      pageBuilder: (context, state) => const CupertinoPage(
        child: AddEditMoneySourceScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.editMoneySource,
      pageBuilder: (context, state) {
        final sourceId = state.extra as String;
        return CupertinoPage(
          child: AddEditMoneySourceScreen(sourceId: sourceId),
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
      pageBuilder: (context, state) => const CupertinoPage(
        child: AddEditGoalScreen(),
      ),
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
      path: AppRoutes.settings,
      pageBuilder: (context, state) => const CupertinoPage(
        child: SettingsScreen(),
      ),
    ),
  ],
);
