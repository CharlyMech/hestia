import 'package:equatable/equatable.dart';

enum ShoppingSessionStatus { active, completed, cancelled }

/// Represents an active or completed shopping trip.
/// Created from a [ShoppingList] (via [listId]) or from scratch.
/// Tracks start/end unix timestamps for duration reporting.
class ShoppingSession extends Equatable {
  final String id;
  final String householdId;

  /// Unix ms timestamp when the session was started.
  final int startedAt;

  /// Unix ms timestamp when the session ended (null while active).
  final int? endedAt;

  /// Optional source list this session was started from.
  final String? listId;

  /// Optional bank account to charge when session is completed.
  final String? bankAccountId;

  /// Transaction created when session is completed.
  final String? transactionId;

  final ShoppingSessionStatus status;

  const ShoppingSession({
    required this.id,
    required this.householdId,
    required this.startedAt,
    this.endedAt,
    this.listId,
    this.bankAccountId,
    this.transactionId,
    this.status = ShoppingSessionStatus.active,
  });

  bool get isActive => status == ShoppingSessionStatus.active;

  Duration? get duration {
    if (endedAt == null) return null;
    return Duration(milliseconds: endedAt! - startedAt);
  }

  ShoppingSession copyWith({
    String? id,
    String? householdId,
    int? startedAt,
    int? endedAt,
    bool clearEndedAt = false,
    String? listId,
    bool clearListId = false,
    String? bankAccountId,
    bool clearBankAccountId = false,
    String? transactionId,
    bool clearTransactionId = false,
    ShoppingSessionStatus? status,
  }) =>
      ShoppingSession(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        startedAt: startedAt ?? this.startedAt,
        endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
        listId: clearListId ? null : (listId ?? this.listId),
        bankAccountId:
            clearBankAccountId ? null : (bankAccountId ?? this.bankAccountId),
        transactionId:
            clearTransactionId ? null : (transactionId ?? this.transactionId),
        status: status ?? this.status,
      );

  @override
  List<Object?> get props =>
      [id, householdId, startedAt, endedAt, status, listId];
}
