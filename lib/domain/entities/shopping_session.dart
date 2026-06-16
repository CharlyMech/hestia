import 'package:equatable/equatable.dart';

import 'shopping_list.dart';
import 'shopping_session_item.dart';

enum ShoppingSessionStatus {
  active,
  completed,
  cancelled;

  static ShoppingSessionStatus fromString(String v) =>
      ShoppingSessionStatus.values.firstWhere(
        (s) => s.name == v,
        orElse: () => ShoppingSessionStatus.active,
      );
}

/// A first-class shopping trip — active (on-going) or ended (completed /
/// cancelled), optionally started from a template and optionally linked to a
/// transaction once finished.
///
/// Personal sessions live ONLY in the local Drift DB while active and are
/// pushed to Supabase on finish. Shared sessions sync live to Supabase.
///
/// All timestamps are unix **seconds** (matching the rest of the schema).
class ShoppingSession extends Equatable {
  final String id;
  final String householdId;
  final String ownerId;
  final String name;
  final ShoppingListScope scope;
  final ShoppingSessionStatus status;

  /// Source template this session was started from (null = from scratch).
  final String? templateId;

  final String? bankAccountId;
  final String? transactionSourceId;

  /// Linked expense, set once finished with a payment.
  final String? transactionId;

  /// Unix seconds.
  final int startedAt;
  final int? endedAt;
  final int? paidAt;
  final int createdAt;
  final int lastUpdate;

  /// Eager-loaded items (optional — populated by the detail load).
  final List<ShoppingSessionItem>? items;

  /// Cheap count of items, populated by list queries (avoids loading [items]).
  final int? itemCount;

  /// True when this session lives only in the local Drift DB (personal + not
  /// yet synced). Transient; derived at mapping time.
  final bool isLocal;

  const ShoppingSession({
    required this.id,
    required this.householdId,
    required this.ownerId,
    required this.name,
    this.scope = ShoppingListScope.personal,
    this.status = ShoppingSessionStatus.active,
    this.templateId,
    this.bankAccountId,
    this.transactionSourceId,
    this.transactionId,
    required this.startedAt,
    this.endedAt,
    this.paidAt,
    required this.createdAt,
    required this.lastUpdate,
    this.items,
    this.itemCount,
    this.isLocal = false,
  });

  bool get isActive => status == ShoppingSessionStatus.active;
  bool get isShared => scope == ShoppingListScope.shared;
  bool get isFromTemplate => templateId != null;

  Duration? get duration {
    if (endedAt == null) return null;
    return Duration(seconds: endedAt! - startedAt);
  }

  ShoppingSession copyWith({
    String? id,
    String? householdId,
    String? ownerId,
    String? name,
    ShoppingListScope? scope,
    ShoppingSessionStatus? status,
    String? templateId,
    bool clearTemplateId = false,
    String? bankAccountId,
    bool clearBankAccountId = false,
    String? transactionSourceId,
    bool clearTransactionSourceId = false,
    String? transactionId,
    bool clearTransactionId = false,
    int? startedAt,
    int? endedAt,
    bool clearEndedAt = false,
    int? paidAt,
    bool clearPaidAt = false,
    int? createdAt,
    int? lastUpdate,
    List<ShoppingSessionItem>? items,
    int? itemCount,
    bool? isLocal,
  }) =>
      ShoppingSession(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        ownerId: ownerId ?? this.ownerId,
        name: name ?? this.name,
        scope: scope ?? this.scope,
        status: status ?? this.status,
        templateId: clearTemplateId ? null : (templateId ?? this.templateId),
        bankAccountId:
            clearBankAccountId ? null : (bankAccountId ?? this.bankAccountId),
        transactionSourceId: clearTransactionSourceId
            ? null
            : (transactionSourceId ?? this.transactionSourceId),
        transactionId:
            clearTransactionId ? null : (transactionId ?? this.transactionId),
        startedAt: startedAt ?? this.startedAt,
        endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
        paidAt: clearPaidAt ? null : (paidAt ?? this.paidAt),
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        items: items ?? this.items,
        itemCount: itemCount ?? this.itemCount,
        isLocal: isLocal ?? this.isLocal,
      );

  /// View as a [ShoppingList] (kind=session) so existing `ShoppingList`-typed
  /// UI/flows keep working during the migration.
  ShoppingList toShoppingList() => ShoppingList(
        id: id,
        householdId: householdId,
        ownerId: ownerId,
        scope: scope,
        name: name,
        status: switch (status) {
          ShoppingSessionStatus.active => ShoppingListStatus.active,
          ShoppingSessionStatus.completed => ShoppingListStatus.paid,
          ShoppingSessionStatus.cancelled => ShoppingListStatus.cancelled,
        },
        kind: ShoppingListKind.session,
        templateId: templateId,
        sessionStartedAt: DateTime.fromMillisecondsSinceEpoch(startedAt * 1000),
        sessionEndedAt: endedAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(endedAt! * 1000),
        bankAccountId: bankAccountId,
        transactionId: transactionId,
        transactionSourceId: transactionSourceId,
        paidAt: paidAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(paidAt! * 1000),
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt * 1000),
        lastUpdate: DateTime.fromMillisecondsSinceEpoch(lastUpdate * 1000),
      );

  @override
  List<Object?> get props =>
      [id, name, status, scope, templateId, transactionId, startedAt, endedAt];
}
