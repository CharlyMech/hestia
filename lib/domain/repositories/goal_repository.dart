import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/domain/entities/goal_progress.dart';

abstract class GoalRepository {
  Future<(List<FinancialGoal>, Failure?)> getGoals({
    required String householdId,
    required ViewMode viewMode,
    String? userId,
    bool activeOnly = true,
  });

  Future<(FinancialGoal?, Failure?)> createGoal(FinancialGoal goal);

  Future<Failure?> updateGoal(FinancialGoal goal);

  Future<Failure?> deleteGoal(String id);

  Future<Failure?> addContribution({
    required String goalId,
    required String userId,
    required double amount,
    required DateTime date,
    String? transactionId,
    String? note,
  });

  Future<(GoalProjection?, Failure?)> getProjection(String goalId);
}
