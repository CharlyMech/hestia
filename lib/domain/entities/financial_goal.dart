import 'package:equatable/equatable.dart';
import 'package:hestia/core/constants/enums.dart';

class FinancialGoal extends Equatable {
  final String id;
  final String householdId;
  final GoalScope scope;
  final String? ownerId;
  final String? bankAccountId;
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
    this.bankAccountId,
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

  FinancialGoal copyWith({
    String? id,
    String? householdId,
    GoalScope? scope,
    String? ownerId,
    String? bankAccountId,
    bool clearMoneySource = false,
    String? name,
    GoalType? goalType,
    double? targetAmount,
    bool clearTargetAmount = false,
    double? monthlyTarget,
    bool clearMonthlyTarget = false,
    double? currentAmount,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    bool? isActive,
    String? color,
    bool clearColor = false,
    String? icon,
    DateTime? createdAt,
    DateTime? lastUpdate,
  }) =>
      FinancialGoal(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        scope: scope ?? this.scope,
        ownerId: ownerId ?? this.ownerId,
        bankAccountId:
            clearMoneySource ? null : (bankAccountId ?? this.bankAccountId),
        name: name ?? this.name,
        goalType: goalType ?? this.goalType,
        targetAmount:
            clearTargetAmount ? null : (targetAmount ?? this.targetAmount),
        monthlyTarget:
            clearMonthlyTarget ? null : (monthlyTarget ?? this.monthlyTarget),
        currentAmount: currentAmount ?? this.currentAmount,
        currency: currency ?? this.currency,
        startDate: startDate ?? this.startDate,
        endDate: clearEndDate ? null : (endDate ?? this.endDate),
        isActive: isActive ?? this.isActive,
        color: clearColor ? null : (color ?? this.color),
        icon: icon ?? this.icon,
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );

  @override
  List<Object?> get props => [id, name, goalType, scope, currentAmount];
}
