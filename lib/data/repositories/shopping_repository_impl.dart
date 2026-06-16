import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/services/shopping_service.dart';
import 'package:hestia/data/services/shopping_session_service.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';
import 'package:hestia/domain/repositories/shopping_repository.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final ShoppingService _service;
  final ShoppingSessionService _sessionService;
  ShoppingRepositoryImpl(this._service, this._sessionService);

  DateTime? _ts(dynamic v) => v == null ? null : parseSupabaseTimestamp(v);

  ShoppingList _listFromJson(Map<String, dynamic> j) => ShoppingList(
        id: j['id'] as String,
        householdId: j['household_id'] as String,
        ownerId: j['owner_id'] as String,
        scope:
            ShoppingListScope.fromString(j['scope'] as String? ?? 'personal'),
        name: j['name'] as String,
        status:
            ShoppingListStatus.fromString(j['status'] as String? ?? 'active'),
        kind: (j['kind'] as String?) == 'template'
            ? ShoppingListKind.template
            : ShoppingListKind.session,
        templateId: j['template_id'] as String?,
        sessionStartedAt: _ts(j['session_started_at']),
        sessionEndedAt: _ts(j['session_ended_at']),
        bankAccountId: j['bank_account_id'] as String?,
        transactionId: j['transaction_id'] as String?,
        transactionSourceId: j['transaction_source_id'] as String?,
        paidAt: _ts(j['paid_at']),
        createdAt:
            parseSupabaseTimestamp(j['created_at'], orElse: DateTime.now()),
        lastUpdate:
            parseSupabaseTimestamp(j['last_update'], orElse: DateTime.now()),
      );

  Map<String, dynamic> _listToJson(ShoppingList l) => {
        'household_id': l.householdId,
        'owner_id': l.ownerId,
        'scope': l.scope.name,
        'name': l.name,
        'status': l.status.name,
        'kind': l.kind.name,
        'template_id': l.templateId,
        'session_started_at': l.sessionStartedAt?.toUnix,
        'session_ended_at': l.sessionEndedAt?.toUnix,
        'bank_account_id': l.bankAccountId,
        'transaction_id': l.transactionId,
        'transaction_source_id': l.transactionSourceId,
        'paid_at': l.paidAt?.toUnix,
      };

  ShoppingListItem _itemFromJson(Map<String, dynamic> j) => ShoppingListItem(
        id: j['id'] as String,
        listId: j['list_id'] as String,
        name: j['name'] as String,
        qty: (j['qty'] as num?)?.toInt() ?? 1,
        sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
        isChecked: j['is_checked'] as bool? ?? false,
        checkedAt: _ts(j['checked_at']),
        createdAt:
            parseSupabaseTimestamp(j['created_at'], orElse: DateTime.now()),
        lastUpdate:
            parseSupabaseTimestamp(j['last_update'], orElse: DateTime.now()),
      );

  Map<String, dynamic> _itemToJson(ShoppingListItem i) => {
        'list_id': i.listId,
        'name': i.name,
        'qty': i.qty,
        'sort_order': i.sortOrder,
        'is_checked': i.isChecked,
        'checked_at': i.checkedAt?.toUnix,
      };

  @override
  Future<(List<ShoppingList>, Failure?)> getLists({
    required String householdId,
    required String userId,
    ShoppingListStatus? status,
    ShoppingListKind? kind,
  }) async {
    if (householdId.isEmpty) return (const <ShoppingList>[], null);
    try {
      final data = await _service.getLists(
        householdId: householdId,
        status: status?.name,
        kind: kind?.name,
      );
      final lists = data
          .map(_listFromJson)
          // personal lists only visible to the owner; shared to everyone
          .where(
              (l) => l.scope == ShoppingListScope.shared || l.ownerId == userId)
          .toList();
      return (lists, null);
    } catch (e, st) {
      return (<ShoppingList>[], reportError(e, st, reason: 'getLists'));
    }
  }

  @override
  Future<(Map<String, int>, Failure?)> getListItemCounts({
    required String householdId,
  }) async {
    if (householdId.isEmpty) return (const <String, int>{}, null);
    try {
      final rows = await _service.getListsWithCounts(householdId: householdId);
      final counts = <String, int>{};
      for (final r in rows) {
        final nested = r['shopping_list_items'];
        if (nested is List && nested.isNotEmpty) {
          final first = nested.first;
          if (first is Map && first['count'] is num) {
            counts[r['id'] as String] = (first['count'] as num).toInt();
          }
        }
      }
      return (counts, null);
    } catch (e, st) {
      return (<String, int>{}, reportError(e, st, reason: 'getListItemCounts'));
    }
  }

  @override
  Future<Failure?> setListMembers({
    required String listId,
    required List<String> userIds,
  }) async {
    try {
      await _service.setMembers(listId: listId, userIds: userIds);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'setListMembers');
    }
  }

  @override
  Future<(List<String>, Failure?)> getListMembers(String listId) async {
    try {
      return (await _service.getMembers(listId), null);
    } catch (e, st) {
      return (<String>[], reportError(e, st, reason: 'getListMembers'));
    }
  }

  @override
  Future<(ShoppingList?, Failure?)> createList(ShoppingList list) async {
    try {
      final data = await _service.createList(_listToJson(list));
      return (_listFromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'createList'));
    }
  }

  @override
  Future<(ShoppingList?, Failure?)> startShoppingSession({
    required String householdId,
    required String userId,
    required String name,
    required ShoppingListScope scope,
    String? bankAccountId,
    String? transactionSourceId,
    String? templateListId,
  }) async {
    try {
      final now = DateTime.now();
      final session = ShoppingList(
        id: '',
        householdId: householdId,
        ownerId: userId,
        scope: scope,
        name: name,
        status: ShoppingListStatus.active,
        kind: ShoppingListKind.session,
        templateId: templateListId,
        sessionStartedAt: now,
        bankAccountId: bankAccountId,
        transactionSourceId: transactionSourceId,
        createdAt: now,
        lastUpdate: now,
      );
      final created =
          _listFromJson(await _service.createList(_listToJson(session)));

      // Copy template items into the new session.
      if (templateListId != null) {
        final srcItems = await _service.getItems(templateListId);
        var order = 0;
        final rows = srcItems
            .map(_itemFromJson)
            .map((it) => {
                  'list_id': created.id,
                  'name': it.name,
                  'qty': it.qty,
                  'sort_order': order++,
                  'is_checked': false,
                })
            .toList();
        await _service.createItems(rows);
      }

      // Best-effort: notify the household (shared sessions) via edge fn. The
      // list already exists; a push failure must not fail session creation.
      try {
        await _sessionService.startSession(
          listId: created.id,
          userId: userId,
        );
      } catch (_) {/* push is non-fatal */}

      return (created, null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'startShoppingSession'));
    }
  }

  @override
  Future<(ShoppingList?, Failure?)> completeSession({
    required String listId,
    Map<String, dynamic>? transactionJson,
    bool cancelled = false,
  }) async {
    try {
      final listJson = await _sessionService.completeSession(
        listId: listId,
        transaction: transactionJson,
        cancelled: cancelled,
      );
      return (_listFromJson(listJson), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'completeSession'));
    }
  }

  @override
  Future<Failure?> reorderItems(List<String> orderedItemIds) async {
    try {
      for (var i = 0; i < orderedItemIds.length; i++) {
        await _service.updateItem(orderedItemIds[i], {'sort_order': i});
      }
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'reorderItems');
    }
  }

  @override
  Future<Failure?> updateList(ShoppingList list) async {
    try {
      await _service.updateList(list.id, _listToJson(list));
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'updateList');
    }
  }

  @override
  Future<Failure?> deleteList(String listId) async {
    try {
      await _service.deleteList(listId);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'deleteList');
    }
  }

  @override
  Future<(List<ShoppingListItem>, Failure?)> getItems(String listId) async {
    try {
      final data = await _service.getItems(listId);
      final items = data.map(_itemFromJson).toList()
        ..sort((a, b) {
          if (a.isChecked != b.isChecked) return a.isChecked ? 1 : -1;
          return a.sortOrder.compareTo(b.sortOrder);
        });
      return (items, null);
    } catch (e, st) {
      return (<ShoppingListItem>[], reportError(e, st, reason: 'getItems'));
    }
  }

  @override
  Future<(ShoppingListItem?, Failure?)> createItem(
      ShoppingListItem item) async {
    try {
      final data = await _service.createItem(_itemToJson(item));
      return (_itemFromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'createItem'));
    }
  }

  @override
  Future<Failure?> updateItem(ShoppingListItem item) async {
    try {
      await _service.updateItem(item.id, _itemToJson(item));
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'updateItem');
    }
  }

  @override
  Future<Failure?> deleteItem(String itemId) async {
    try {
      await _service.deleteItem(itemId);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'deleteItem');
    }
  }
}
