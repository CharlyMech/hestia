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

/// Reusable blueprint vs an in-progress shopping run.
enum ShoppingListKind {
  /// Saved layout / default source — not an active trip to the store.
  template,

  /// Active or finished shopping session (may have been started from a template).
  session,
}

/// A grocery / shopping list. Once status flips to [ShoppingListStatus.paid]
/// or [ShoppingListStatus.cancelled] the session is immutable in history.
class ShoppingList extends Equatable {
  final String id;
  final String householdId;
  final String ownerId;
  final ShoppingListScope scope;
  final String name;
  final ShoppingListStatus status;

  final ShoppingListKind kind;

  /// When [kind] is [ShoppingListKind.session] and this was started from a template.
  final String? templateId;

  /// Start of an active shopping session (wall clock). Null for templates.
  final DateTime? sessionStartedAt;

  /// When the session was finished or auto-closed.
  final DateTime? sessionEndedAt;

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
    this.kind = ShoppingListKind.session,
    this.templateId,
    this.sessionStartedAt,
    this.sessionEndedAt,
    this.bankAccountId,
    this.transactionId,
    this.transactionSourceId,
    this.paidAt,
    required this.createdAt,
    required this.lastUpdate,
  });

  bool get isActive => status == ShoppingListStatus.active;
  bool get isTemplate => kind == ShoppingListKind.template;

  /// Templates stay editable while active. Sessions lock once not active.
  bool get isImmutable =>
      kind == ShoppingListKind.session && status != ShoppingListStatus.active;

  /// Active session older than [maxDuration] should auto-close.
  bool shouldAutoExpireSession(
      {Duration maxDuration = const Duration(hours: 24)}) {
    if (kind != ShoppingListKind.session ||
        status != ShoppingListStatus.active) {
      return false;
    }
    final start = sessionStartedAt;
    if (start == null) return false;
    return DateTime.now().difference(start) > maxDuration;
  }

  ShoppingList copyWith({
    String? id,
    String? householdId,
    String? ownerId,
    ShoppingListScope? scope,
    String? name,
    ShoppingListStatus? status,
    ShoppingListKind? kind,
    String? templateId,
    bool clearTemplateId = false,
    DateTime? sessionStartedAt,
    bool clearSessionStartedAt = false,
    DateTime? sessionEndedAt,
    bool clearSessionEndedAt = false,
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
        kind: kind ?? this.kind,
        templateId: clearTemplateId ? null : (templateId ?? this.templateId),
        sessionStartedAt: clearSessionStartedAt
            ? null
            : (sessionStartedAt ?? this.sessionStartedAt),
        sessionEndedAt: clearSessionEndedAt
            ? null
            : (sessionEndedAt ?? this.sessionEndedAt),
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
  List<Object?> get props =>
      [id, name, status, scope, transactionId, kind, templateId];
}
