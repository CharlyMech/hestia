import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/presentation/pages/auth/login_screen.dart';
import 'package:hestia/presentation/pages/categories/categories_screen.dart';
import 'package:hestia/presentation/pages/goals/add_edit_goals_screen.dart';
import 'package:hestia/presentation/pages/goals/goal_detail_screen.dart';
import 'package:hestia/presentation/pages/main_tab_shell.dart';
import 'package:hestia/presentation/pages/money_sources/add_edit_money_sources_screen.dart';
import 'package:hestia/presentation/pages/money_sources/money_sources_screen.dart';
import 'package:hestia/presentation/pages/notifications/notifications_screen.dart';
import 'package:hestia/presentation/pages/splash/custom_splash_screen.dart';
import 'package:hestia/presentation/pages/transactions/add_edit_transaction_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';

  /// Persistent tab shell — Home / Activity / Goals / More live here.
  /// Use `?tab=N` (0..3) to land on a specific tab.
  static const main = '/main';

  /// Tab indices for [main] deep-links.
  static const tabHome = 0;
  static const tabActivity = 1;
  static const tabGoals = 2;
  static const tabMore = 3;

  // Convenience aliases — push goes to /main with tab query.
  static const dashboard = '$main?tab=$tabHome';
  static const transactions = '$main?tab=$tabActivity';
  static const goals = '$main?tab=$tabGoals';
  static const settings = '$main?tab=$tabMore';

  static const addTransaction = '/transactions/add';
  static const editTransaction = '/transactions/edit';
  static const categories = '/categories';
  static const moneySources = '/money-sources';
  static const addMoneySource = '/money-sources/add';
  static const editMoneySource = '/money-sources/edit';
  static const addGoal = '/goals/add';
  static const editGoal = '/goals/edit';
  static const goalDetail = '/goals/detail';
  static const notifications = '/notifications';
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
  ],
);
