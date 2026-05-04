import 'package:equatable/equatable.dart';

/// Lifecycle status of a shopping list.
enum ShoppingListStatus {
  /// User can add/check/edit items. Default state for fresh lists.
  active,

  /// Finished via the Finish & Pay flow → linked to a [Transaction].
  /// List becomes immutable.
  paid,

  /// User cancelled the list (Cancel button + native confirm). Immutable.
  cancelled;

  String get value => name;

  static ShoppingListStatus fromString(String v) =>
      ShoppingListStatus.values.firstWhere(
        (s) => s.name == v,
        orElse: () => ShoppingListStatus.active,
      );
}

/// Visibility scope of a shopping list inside the household.
enum ShoppingListScope {
  personal,
  shared;

  String get value => name;

  static ShoppingListScope fromString(String v) =>
      ShoppingListScope.values.firstWhere(
        (s) => s.name == v,
        orElse: () => ShoppingListScope.personal,
      );
}

/// A grocery / shopping list. Once status flips to [ShoppingListStatus.paid]
/// or [ShoppingListStatus.cancelled] the list is immutable in history.
class ShoppingList extends Equatable {
  final String id;
  final String householdId;
  final String ownerId;
  final ShoppingListScope scope;
  final String name;
  final ShoppingListStatus status;

  /// Bank account chosen for the eventual payment. Optional until Finish&Pay.
  final String? bankAccountId;

  /// Linked transaction once the list is paid. Null until then.
  final String? transactionId;

  /// Optional default merchant/source for items in the list (Mercadona, Lidl).
  final String? transactionSourceId;

  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime lastUpdate;

  const ShoppingList({
    required this.id,
    required this.householdId,
    required this.ownerId,
    this.scope = ShoppingListScope.personal,
    required this.name,
    this.status = ShoppingListStatus.active,
    this.bankAccountId,
    this.transactionId,
    this.transactionSourceId,
    this.paidAt,
    required this.createdAt,
    required this.lastUpdate,
  });

  bool get isActive => status == ShoppingListStatus.active;
  bool get isImmutable => status != ShoppingListStatus.active;

  ShoppingList copyWith({
    String? id,
    String? householdId,
    String? ownerId,
    ShoppingListScope? scope,
    String? name,
    ShoppingListStatus? status,
    String? bankAccountId,
    bool clearBankAccount = false,
    String? transactionId,
    bool clearTransaction = false,
    String? transactionSourceId,
    bool clearTransactionSource = false,
    DateTime? paidAt,
    bool clearPaidAt = false,
    DateTime? createdAt,
    DateTime? lastUpdate,
  }) =>
      ShoppingList(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        ownerId: ownerId ?? this.ownerId,
        scope: scope ?? this.scope,
        name: name ?? this.name,
        status: status ?? this.status,
        bankAccountId:
            clearBankAccount ? null : (bankAccountId ?? this.bankAccountId),
        transactionId:
            clearTransaction ? null : (transactionId ?? this.transactionId),
        transactionSourceId: clearTransactionSource
            ? null
            : (transactionSourceId ?? this.transactionSourceId),
        paidAt: clearPaidAt ? null : (paidAt ?? this.paidAt),
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );

  @override
  List<Object?> get props => [id, name, status, scope, transactionId];
}
