class BankAccountDto {
  final String id;
  final String householdId;
  final String ownerType;
  final String? ownerId;
  final String name;
  final String? institution;
  final String accountType;
  final String currency;
  final num initialBalance;
  final num currentBalance;
  final bool isPrimary;
  final bool isActive;
  final String? color;
  final String? icon;
  final int sortOrder;
  final int createdAt;
  final int lastUpdate;

  const BankAccountDto({
    required this.id,
    required this.householdId,
    required this.ownerType,
    this.ownerId,
    required this.name,
    this.institution,
    required this.accountType,
    this.currency = 'EUR',
    required this.initialBalance,
    required this.currentBalance,
    this.isPrimary = false,
    this.isActive = true,
    this.color,
    this.icon,
    this.sortOrder = 0,
    required this.createdAt,
    required this.lastUpdate,
  });

  factory BankAccountDto.fromJson(Map<String, dynamic> json) {
    return BankAccountDto(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      ownerType: json['owner_type'] as String,
      ownerId: json['owner_id'] as String?,
      name: json['name'] as String,
      institution: json['institution'] as String?,
      accountType: json['account_type'] as String,
      currency: json['currency'] as String? ?? 'EUR',
      initialBalance: json['initial_balance'] as num,
      currentBalance: json['current_balance'] as num,
      isPrimary: json['is_primary'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] as int,
      lastUpdate: json['last_update'] as int,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'household_id': householdId,
        'owner_type': ownerType,
        'owner_id': ownerId,
        'name': name,
        'institution': institution,
        'account_type': accountType,
        'currency': currency,
        'initial_balance': initialBalance,
        'current_balance': initialBalance, // starts at initial
        'is_primary': isPrimary,
        'is_active': isActive,
        'color': color,
        'icon': icon,
        'sort_order': sortOrder,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'institution': institution,
        'is_primary': isPrimary,
        'is_active': isActive,
        'color': color,
        'icon': icon,
        'sort_order': sortOrder,
        'last_update': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
}
