import 'package:home_expenses/core/constants/enums.dart';
import 'package:home_expenses/core/error/error_handler.dart';
import 'package:home_expenses/core/error/failures.dart';
import 'package:home_expenses/core/utils/date_utils.dart';
import 'package:home_expenses/data/mappers/goal_mapper.dart';
import 'package:home_expenses/data/services/goal_service.dart';
import 'package:home_expenses/domain/entities/financial_goal.dart';
import 'package:home_expenses/domain/entities/goal_progress.dart';
import 'package:home_expenses/domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalService _service;

  GoalRepositoryImpl(this._service);

  @override
  Future<(List<FinancialGoal>, Failure?)> getGoals({
    required String householdId,
    required ViewMode viewMode,
    String? userId,
    bool activeOnly = true,
  }) async {
    try {
      final data = await _service.getGoals(
        householdId: householdId,
        activeOnly: activeOnly,
      );

      var goals = data.map(GoalMapper.fromJson).toList();

      if (viewMode == ViewMode.personal && userId != null) {
        goals = goals
            .where((g) => g.scope == GoalScope.household || g.ownerId == userId)
            .toList();
      }

      return (goals, null);
    } catch (e) {
      return (<FinancialGoal>[], mapExceptionToFailure(e));
    }
  }

  @override
  Future<(FinancialGoal?, Failure?)> createGoal(FinancialGoal goal) async {
    try {
      final dto = GoalMapper.toDto(goal);
      final data = await _service.createGoal(dto.toInsertJson());
      final created = GoalMapper.fromJson(data);
      return (created, null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }

  @override
  Future<Failure?> updateGoal(FinancialGoal goal) async {
    try {
      final dto = GoalMapper.toDto(goal);
      await _service.updateGoal(goal.id, dto.toUpdateJson());
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> deleteGoal(String id) async {
    try {
      await _service.deleteGoal(id);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> addContribution({
    required String goalId,
    required String userId,
    required double amount,
    required DateTime date,
    String? transactionId,
    String? note,
  }) async {
    try {
      await _service.addContribution({
        'goal_id': goalId,
        'user_id': userId,
        'amount': amount,
        'date': date.toUnix,
        'transaction_id': transactionId,
        'note': note,
      });
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<(GoalProjection?, Failure?)> getProjection(String goalId) async {
    try {
      // Fetch goal
      final goalData = await _service
          .from('financial_goals')
          .select()
          .eq('id', goalId)
          .single();
      final goal = GoalMapper.fromJson(goalData);

      // Fetch contributions for average calculation
      final contributions = await _service.getContributions(goalId);

      // Calculate monthly average from contributions
      double monthlyAverage = 0;
      if (contributions.isNotEmpty) {
        final amounts =
            contributions.map((c) => (c['amount'] as num).toDouble()).toList();
        final totalContributed = amounts.fold(0.0, (a, b) => a + b);

        // Months since start
        final monthsSinceStart = _monthsBetween(goal.startDate, DateTime.now());
        if (monthsSinceStart > 0) {
          monthlyAverage = totalContributed / monthsSinceStart;
        } else {
          monthlyAverage = totalContributed;
        }
      }

      final projection = GoalProjection(
        currentAmount: goal.currentAmount,
        targetAmount: goal.targetAmount,
        monthlyAverage: monthlyAverage,
        startDate: goal.startDate,
        endDate: goal.endDate,
      );

      return (projection, null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }

  int _monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }
}
