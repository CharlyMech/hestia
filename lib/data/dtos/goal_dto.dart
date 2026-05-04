class GoalDto {
  final String id;
  final String householdId;
  final String scope;
  final String? ownerId;
  final String? bankAccountId;
  final String name;
  final String goalType;
  final num? targetAmount;
  final num? monthlyTarget;
  final num currentAmount;
  final String currency;
  final int startDate;
  final int? endDate;
  final bool isActive;
  final String? color;
  final String? icon;
  final int createdAt;
  final int lastUpdate;

  const GoalDto({
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

  factory GoalDto.fromJson(Map<String, dynamic> json) {
    return GoalDto(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      scope: json['scope'] as String,
      ownerId: json['owner_id'] as String?,
      bankAccountId: json['money_source_id'] as String?,
      name: json['name'] as String,
      goalType: json['goal_type'] as String,
      targetAmount: json['target_amount'] as num?,
      monthlyTarget: json['monthly_target'] as num?,
      currentAmount: json['current_amount'] as num? ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
      startDate: json['start_date'] as int,
      endDate: json['end_date'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      createdAt: json['created_at'] as int,
      lastUpdate: json['last_update'] as int,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'household_id': householdId,
        'scope': scope,
        'owner_id': ownerId,
        'money_source_id': bankAccountId,
        'name': name,
        'goal_type': goalType,
        'target_amount': targetAmount,
        'monthly_target': monthlyTarget,
        'currency': currency,
        'start_date': startDate,
        'end_date': endDate,
        'is_active': isActive,
        'color': color,
        'icon': icon,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'target_amount': targetAmount,
        'monthly_target': monthlyTarget,
        'money_source_id': bankAccountId,
        'end_date': endDate,
        'is_active': isActive,
        'color': color,
        'icon': icon,
        'last_update': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
}
