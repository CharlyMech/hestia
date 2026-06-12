import 'package:equatable/equatable.dart';
import 'package:hestia/core/constants/enums.dart';

class Transaction extends Equatable {
  final String id;
  final String householdId;
  final String userId;
  final String categoryId;
  final String bankAccountId;
  final String? transactionSourceId;
  final double amount;
  final String currency;
  final TransactionType type;
  final String? note;
  final DateTime date;
  final bool isRecurring;
  final Map<String, dynamic>? recurringRule;
  final DateTime createdAt;
  final DateTime lastUpdate;

  /// Optional GPS coordinates when the user attaches a location.
  final double? latitude;
  final double? longitude;

  /// Optional actor associations — the entity this transaction is "for".
  /// At most one should be set at a time.
  final String? petId;
  final String? carId;
  final String? homeId;

  // Joined fields (populated by repository when needed)
  final String? categoryName;
  final String? categoryColor;
  final String? bankAccountName;
  final String? transactionSourceName;
  final String? userName;

  const Transaction({
    required this.id,
    required this.householdId,
    required this.userId,
    required this.categoryId,
    required this.bankAccountId,
    this.transactionSourceId,
    required this.amount,
    this.currency = 'EUR',
    required this.type,
    this.note,
    required this.date,
    this.isRecurring = false,
    this.recurringRule,
    required this.createdAt,
    required this.lastUpdate,
    this.latitude,
    this.longitude,
    this.petId,
    this.carId,
    this.homeId,
    this.categoryName,
    this.categoryColor,
    this.bankAccountName,
    this.transactionSourceName,
    this.userName,
  });

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isAdjustment => type == TransactionType.adjustment;

  bool get hasLocation => latitude != null && longitude != null;

  Transaction copyWith({
    String? id,
    String? householdId,
    String? userId,
    String? categoryId,
    String? bankAccountId,
    String? transactionSourceId,
    bool clearTransactionSource = false,
    double? amount,
    String? currency,
    TransactionType? type,
    String? note,
    bool clearNote = false,
    DateTime? date,
    bool? isRecurring,
    Map<String, dynamic>? recurringRule,
    bool clearRecurringRule = false,
    DateTime? createdAt,
    DateTime? lastUpdate,
    double? latitude,
    double? longitude,
    bool clearLocation = false,
    String? petId,
    bool clearPetId = false,
    String? carId,
    bool clearCarId = false,
    String? homeId,
    bool clearHomeId = false,
    String? categoryName,
    String? categoryColor,
    String? bankAccountName,
    String? transactionSourceName,
    String? userName,
  }) {
    return Transaction(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      transactionSourceId: clearTransactionSource
          ? null
          : (transactionSourceId ?? this.transactionSourceId),
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      note: clearNote ? null : (note ?? this.note),
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringRule:
          clearRecurringRule ? null : (recurringRule ?? this.recurringRule),
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
      petId: clearPetId ? null : (petId ?? this.petId),
      carId: clearCarId ? null : (carId ?? this.carId),
      homeId: clearHomeId ? null : (homeId ?? this.homeId),
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      transactionSourceName:
          transactionSourceName ?? this.transactionSourceName,
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        currency,
        type,
        date,
        categoryId,
        bankAccountId,
        latitude,
        longitude,
      ];
}
