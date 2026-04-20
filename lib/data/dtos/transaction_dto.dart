class TransactionDto {
  final String id;
  final String householdId;
  final String userId;
  final String categoryId;
  final String moneySourceId;
  final num amount;
  final String type;
  final String? note;
  final int date;
  final bool isRecurring;
  final Map<String, dynamic>? recurringRule;
  final int createdAt;
  final int lastUpdate;

  // Joined relations (nullable — only present on select with joins)
  final Map<String, dynamic>? categories;
  final Map<String, dynamic>? moneySources;
  final Map<String, dynamic>? profiles;

  const TransactionDto({
    required this.id,
    required this.householdId,
    required this.userId,
    required this.categoryId,
    required this.moneySourceId,
    required this.amount,
    required this.type,
    this.note,
    required this.date,
    this.isRecurring = false,
    this.recurringRule,
    required this.createdAt,
    required this.lastUpdate,
    this.categories,
    this.moneySources,
    this.profiles,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      moneySourceId: json['money_source_id'] as String,
      amount: json['amount'] as num,
      type: json['type'] as String,
      note: json['note'] as String?,
      date: json['date'] as int,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringRule: json['recurring_rule'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as int,
      lastUpdate: json['last_update'] as int,
      categories: json['categories'] as Map<String, dynamic>?,
      moneySources: json['money_sources'] as Map<String, dynamic>?,
      profiles: json['profiles'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'household_id': householdId,
        'user_id': userId,
        'category_id': categoryId,
        'money_source_id': moneySourceId,
        'amount': amount,
        'type': type,
        'note': note,
        'date': date,
        'is_recurring': isRecurring,
        'recurring_rule': recurringRule,
      };

  Map<String, dynamic> toUpdateJson() => {
        'category_id': categoryId,
        'money_source_id': moneySourceId,
        'amount': amount,
        'type': type,
        'note': note,
        'date': date,
        'is_recurring': isRecurring,
        'recurring_rule': recurringRule,
        'last_update': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
}
