class TransactionDto {
  final String id;
  final String householdId;
  final String userId;
  final String categoryId;
  final String bankAccountId;
  final String? transactionSourceId;
  final num amount;
  final String type;
  final String? note;
  final int date;
  final bool isRecurring;
  final Map<String, dynamic>? recurringRule;
  final int createdAt;
  final int lastUpdate;
  final double? latitude;
  final double? longitude;

  // Joined relations (nullable — only present on select with joins)
  final Map<String, dynamic>? categories;
  final Map<String, dynamic>? bankAccounts;
  final Map<String, dynamic>? transactionSources;
  final Map<String, dynamic>? profiles;

  const TransactionDto({
    required this.id,
    required this.householdId,
    required this.userId,
    required this.categoryId,
    required this.bankAccountId,
    this.transactionSourceId,
    required this.amount,
    required this.type,
    this.note,
    required this.date,
    this.isRecurring = false,
    this.recurringRule,
    required this.createdAt,
    required this.lastUpdate,
    this.latitude,
    this.longitude,
    this.categories,
    this.bankAccounts,
    this.transactionSources,
    this.profiles,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      bankAccountId: json['money_source_id'] as String,
      transactionSourceId: json['transaction_source_id'] as String?,
      amount: json['amount'] as num,
      type: json['type'] as String,
      note: json['note'] as String?,
      date: json['date'] as int,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringRule: json['recurring_rule'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as int,
      lastUpdate: json['last_update'] as int,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      categories: json['categories'] as Map<String, dynamic>?,
      bankAccounts: json['money_sources'] as Map<String, dynamic>?,
      transactionSources: json['transaction_sources'] as Map<String, dynamic>?,
      profiles: json['profiles'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toInsertJson() {
    final m = <String, dynamic>{
      'household_id': householdId,
      'user_id': userId,
      'category_id': categoryId,
      'money_source_id': bankAccountId,
      'transaction_source_id': transactionSourceId,
      'amount': amount,
      'type': type,
      'note': note,
      'date': date,
      'is_recurring': isRecurring,
      'recurring_rule': recurringRule,
    };
    if (latitude != null) m['latitude'] = latitude;
    if (longitude != null) m['longitude'] = longitude;
    return m;
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'category_id': categoryId,
      'money_source_id': bankAccountId,
      'transaction_source_id': transactionSourceId,
      'amount': amount,
      'type': type,
      'note': note,
      'date': date,
      'is_recurring': isRecurring,
      'recurring_rule': recurringRule,
      'last_update': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
