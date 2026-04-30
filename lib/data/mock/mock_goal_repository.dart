import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/domain/entities/goal_progress.dart';
import 'package:hestia/domain/repositories/goal_repository.dart';
import 'package:uuid/uuid.dart';

class MockGoalRepository implements GoalRepository {
  static const _uuid = Uuid();

  @override
  Future<(List<FinancialGoal>, Failure?)> getGoals({
    required String householdId,
    required ViewMode viewMode,
    String? userId,
    bool activeOnly = true,
  }) async {
    final list = MockStore.instance.goals
        .where((g) => g.householdId == householdId)
        .where((g) => !activeOnly || g.isActive)
        .where((g) {
      if (viewMode == ViewMode.household) return true;
      if (g.scope == GoalScope.household) return true;
      return userId == null || g.ownerId == userId;
    }).toList();
    return (list, null);
  }

  @override
  Future<(FinancialGoal?, Failure?)> createGoal(FinancialGoal goal) async {
    final created = _copy(goal, id: _uuid.v4(), createdAt: DateTime.now(), lastUpdate: DateTime.now());
    MockStore.instance.goals.add(created);
    return (created, null);
  }

  @override
  Future<Failure?> updateGoal(FinancialGoal goal) async {
    final list = MockStore.instance.goals;
    final i = list.indexWhere((g) => g.id == goal.id);
    if (i < 0) return const ServerFailure('Goal not found');
    list[i] = _copy(goal, lastUpdate: DateTime.now());
    return null;
  }

  @override
  Future<Failure?> deleteGoal(String id) async {
    MockStore.instance.goals.removeWhere((g) => g.id == id);
    return null;
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
    final list = MockStore.instance.goals;
    final i = list.indexWhere((g) => g.id == goalId);
    if (i < 0) return const ServerFailure('Goal not found');
    final g = list[i];
    list[i] = _copy(g, currentAmount: g.currentAmount + amount, lastUpdate: DateTime.now());
    return null;
  }

  @override
  Future<(GoalProjection?, Failure?)> getProjection(String goalId) async {
    final g = MockStore.instance.goals.where((x) => x.id == goalId).firstOrNull;
    if (g == null) return (null, const ServerFailure('Goal not found'));
    final monthly = g.monthlyTarget ?? 0;
    return (
      GoalProjection(
        currentAmount: g.currentAmount,
        targetAmount: g.targetAmount,
        monthlyAverage: monthly,
        startDate: g.startDate,
        endDate: g.endDate,
      ),
      null,
    );
  }

  FinancialGoal _copy(
    FinancialGoal g, {
    String? id,
    double? currentAmount,
    DateTime? createdAt,
    DateTime? lastUpdate,
  }) =>
      FinancialGoal(
        id: id ?? g.id,
        householdId: g.householdId,
        scope: g.scope,
        ownerId: g.ownerId,
        moneySourceId: g.moneySourceId,
        name: g.name,
        goalType: g.goalType,
        targetAmount: g.targetAmount,
        monthlyTarget: g.monthlyTarget,
        currentAmount: currentAmount ?? g.currentAmount,
        currency: g.currency,
        startDate: g.startDate,
        endDate: g.endDate,
        isActive: g.isActive,
        color: g.color,
        icon: g.icon,
        createdAt: createdAt ?? g.createdAt,
        lastUpdate: lastUpdate ?? g.lastUpdate,
      );
}
