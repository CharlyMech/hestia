import 'package:equatable/equatable.dart';
import 'package:hestia/core/constants/enums.dart';

class Transaction extends Equatable {
  final String id;
  final String householdId;
  final String userId;
  final String categoryId;
  final String moneySourceId;
  final double amount;
  final TransactionType type;
  final String? note;
  final DateTime date;
  final bool isRecurring;
  final Map<String, dynamic>? recurringRule;
  final DateTime createdAt;
  final DateTime lastUpdate;

  // Joined fields (populated by repository when needed)
  final String? categoryName;
  final String? categoryColor;
  final String? moneySourceName;
  final String? userName;

  const Transaction({
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
    this.categoryName,
    this.categoryColor,
    this.moneySourceName,
    this.userName,
  });

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  @override
  List<Object?> get props =>
      [id, amount, type, date, categoryId, moneySourceId];
}
