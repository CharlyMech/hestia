import 'package:home_expenses/core/constants/enums.dart';
import 'package:home_expenses/core/utils/date_utils.dart';
import 'package:home_expenses/data/dtos/goal_dto.dart';
import 'package:home_expenses/domain/entities/financial_goal.dart';

abstract final class GoalMapper {
  static FinancialGoal toDomain(GoalDto dto) {
    return FinancialGoal(
      id: dto.id,
      householdId: dto.householdId,
      scope: GoalScope.fromString(dto.scope),
      ownerId: dto.ownerId,
      moneySourceId: dto.moneySourceId,
      name: dto.name,
      goalType: GoalType.fromString(dto.goalType),
      targetAmount: dto.targetAmount?.toDouble(),
      monthlyTarget: dto.monthlyTarget?.toDouble(),
      currentAmount: dto.currentAmount.toDouble(),
      currency: dto.currency,
      startDate: dto.startDate.fromUnix,
      endDate: dto.endDate?.fromUnix,
      isActive: dto.isActive,
      color: dto.color,
      icon: dto.icon,
      createdAt: dto.createdAt.fromUnix,
      lastUpdate: dto.lastUpdate.fromUnix,
    );
  }

  static GoalDto toDto(FinancialGoal entity) {
    return GoalDto(
      id: entity.id,
      householdId: entity.householdId,
      scope: entity.scope.value,
      ownerId: entity.ownerId,
      moneySourceId: entity.moneySourceId,
      name: entity.name,
      goalType: entity.goalType.value,
      targetAmount: entity.targetAmount,
      monthlyTarget: entity.monthlyTarget,
      currentAmount: entity.currentAmount,
      currency: entity.currency,
      startDate: entity.startDate.toUnix,
      endDate: entity.endDate?.toUnix,
      isActive: entity.isActive,
      color: entity.color,
      icon: entity.icon,
      createdAt: entity.createdAt.toUnix,
      lastUpdate: entity.lastUpdate.toUnix,
    );
  }

  static FinancialGoal fromJson(Map<String, dynamic> json) {
    return toDomain(GoalDto.fromJson(json));
  }
}
