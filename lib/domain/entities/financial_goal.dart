import 'package:equatable/equatable.dart';
import 'package:hestia/core/constants/enums.dart';

class FinancialGoal extends Equatable {
  final String id;
  final String householdId;
  final GoalScope scope;
  final String? ownerId;
  final String? moneySourceId;
  final String name;
  final GoalType goalType;
  final double? targetAmount;
  final double? monthlyTarget;
  final double currentAmount;
  final String currency;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? color;
  final String? icon;
  final DateTime createdAt;
  final DateTime lastUpdate;

  const FinancialGoal({
    required this.id,
    required this.householdId,
    required this.scope,
    this.ownerId,
    this.moneySourceId,
    required this.name,
    required this.goalType,
    this.targetAmount,
    this.monthlyTarget,
    this.currentAmount = 0,
    this.currency = 'EUR',
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.color,
    this.icon,
    required this.createdAt,
    required this.lastUpdate,
  });

  bool get isPersonal => scope == GoalScope.personal;
  bool get isHousehold => scope == GoalScope.household;
  bool get hasDeadline => endDate != null;
  bool get hasTarget => targetAmount != null && targetAmount! > 0;

  double get progressPercent {
    if (!hasTarget) return 0;
    return (currentAmount / targetAmount!).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [id, name, goalType, scope, currentAmount];
}
