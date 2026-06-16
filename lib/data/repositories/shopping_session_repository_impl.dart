import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/local/drift/app_database.dart';
import 'package:hestia/data/local/drift/daos/shopping_session_dao.dart';
import 'package:hestia/data/services/shopping_service.dart';
import 'package:hestia/data/services/shopping_session_service.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_session.dart';
import 'package:hestia/domain/entities/shopping_session_item.dart';
import 'package:hestia/domain/repositories/shopping_session_repository.dart';

/// Routes session reads/writes local-first (personal, Drift) vs remote
/// (shared, Supabase) based on the session [ShoppingListScope].
class ShoppingSessionRepositoryImpl implements ShoppingSessionRepository {
  final ShoppingService _listService;
  final ShoppingSessionService _service;
  final ShoppingSessionDao _dao;
  static const _uuid = Uuid();

  ShoppingSessionRepositoryImpl(this._listService, this._service, this._dao);

  int get _now => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  // ── mappers: Drift row ↔ entity ──────────────────────────────────────────
  ShoppingSession _fromLocal(LocalShoppingSession r,
          {List<ShoppingSessionItem>? items}) =>
      ShoppingSession(
        id: r.id,
        householdId: r.householdId,
        ownerId: r.ownerId,
        name: r.name,
        scope: ShoppingListScope.fromString(r.scope),
        status: ShoppingSessionStatus.fromString(r.status),
        templateId: r.templateId,
        bankAccountId: r.bankAccountId,
        transactionSourceId: r.transactionSourceId,
        transactionId: r.transactionId,
        startedAt: r.startedAt,
        endedAt: r.endedAt,
        paidAt: r.paidAt,
        createdAt: r.createdAt,
        lastUpdate: r.lastUpdate,
        items: items,
        isLocal: true,
      );

  ShoppingSessionItem _fromLocalItem(LocalShoppingSessionItem r) =>
      ShoppingSessionItem(
        id: r.id,
        sessionId: r.sessionId,
        name: r.name,
        qty: r.qty,
        sortOrder: r.sortOrder,
        isChecked: r.isChecked,
        checkedAt: r.checkedAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(r.checkedAt! * 1000),
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt * 1000),
        lastUpdate: DateTime.fromMillisecondsSinceEpoch(r.lastUpdate * 1000),
      );

  // ── mappers: Supabase JSON ↔ entity ──────────────────────────────────────
  ShoppingSession _fromJson(Map<String, dynamic> j) => ShoppingSession(
        id: j['id'] as String,
        householdId: j['household_id'] as String,
        ownerId: (j['owner_id'] as String?) ?? '',
        name: (j['name'] as String?) ?? '',
        scope: ShoppingListScope.fromString(j['scope'] as String? ?? 'shared'),
        status:
            ShoppingSessionStatus.fromString(j['status'] as String? ?? 'active'),
        templateId: j['template_id'] as String?,
        bankAccountId: j['bank_account_id'] as String?,
        transactionSourceId: j['transaction_source_id'] as String?,
        transactionId: j['transaction_id'] as String?,
        startedAt: (j['started_at'] as num).toInt(),
        endedAt: (j['ended_at'] as num?)?.toInt(),
        paidAt: (j['paid_at'] as num?)?.toInt(),
        createdAt: (j['created_at'] as num?)?.toInt() ?? _now,
        lastUpdate: (j['last_update'] as num?)?.toInt() ?? _now,
        isLocal: false,
      );

  /// Like [_fromJson] but reads the nested `shopping_session_items(count)`
  /// aggregate PostgREST returns as `[{count: N}]`.
  ShoppingSession _fromJsonWithCount(Map<String, dynamic> j) {
    int? count;
    final nested = j['shopping_session_items'];
    if (nested is List && nested.isNotEmpty) {
      final first = nested.first;
      if (first is Map && first['count'] is num) {
        count = (first['count'] as num).toInt();
      }
    }
    return _fromJson(j).copyWith(itemCount: count);
  }

  ShoppingSessionItem _itemFromJson(Map<String, dynamic> j) =>
      ShoppingSessionItem(
        id: j['id'] as String,
        sessionId: j['session_id'] as String,
        name: j['name'] as String,
        qty: (j['qty'] as num?)?.toInt() ?? 1,
        sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
        isChecked: j['is_checked'] as bool? ?? false,
        checkedAt: (j['checked_at'] as num?) == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                (j['checked_at'] as num).toInt() * 1000),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            ((j['created_at'] as num?)?.toInt() ?? _now) * 1000),
        lastUpdate: DateTime.fromMillisecondsSinceEpoch(
            ((j['last_update'] as num?)?.toInt() ?? _now) * 1000),
      );

  Map<String, dynamic> _sessionToJson(ShoppingSession s) => {
        'id': s.id,
        'household_id': s.householdId,
        'owner_id': s.ownerId,
        'name': s.name,
        'scope': s.scope.name,
        'status': s.status.name,
        'template_id': s.templateId,
        'bank_account_id': s.bankAccountId,
        'transaction_source_id': s.transactionSourceId,
        'transaction_id': s.transactionId,
        'started_at': s.startedAt,
        'ended_at': s.endedAt,
        'paid_at': s.paidAt,
      };

  Map<String, dynamic> _itemToJson(ShoppingSessionItem i) => {
        'session_id': i.sessionId,
        'name': i.name,
        'qty': i.qty,
        'sort_order': i.sortOrder,
        'is_checked': i.isChecked,
        'checked_at': i.checkedAt?.millisecondsSinceEpoch != null
            ? i.checkedAt!.millisecondsSinceEpoch ~/ 1000
            : null,
      };

  // ── start ────────────────────────────────────────────────────────────────
  @override
  Future<(ShoppingSession?, Failure?)> startSession({
    required String householdId,
    required String userId,
    required String name,
    required ShoppingListScope scope,
    String? bankAccountId,
    String? transactionSourceId,
    String? templateId,
    List<String> sharedWithUserIds = const [],
  }) async {
    try {
      final now = _now;
      final id = _uuid.v4();
      final session = ShoppingSession(
        id: id,
        householdId: householdId,
        ownerId: userId,
        name: name,
        scope: scope,
        status: ShoppingSessionStatus.active,
        templateId: templateId,
        bankAccountId: bankAccountId,
        transactionSourceId: transactionSourceId,
        startedAt: now,
        createdAt: now,
        lastUpdate: now,
        isLocal: scope == ShoppingListScope.personal,
      );

      // Template items are always read from the remote shopping_list_items.
      final templateRows = templateId == null
          ? const <Map<String, dynamic>>[]
          : await _listService.getItems(templateId);

      if (scope == ShoppingListScope.personal) {
        await _dao.upsertSession(LocalShoppingSessionsCompanion.insert(
          id: id,
          householdId: householdId,
          ownerId: userId,
          name: name,
          scope: scope.name,
          status: ShoppingSessionStatus.active.name,
          templateId: Value(templateId),
          bankAccountId: Value(bankAccountId),
          transactionSourceId: Value(transactionSourceId),
          startedAt: now,
          createdAt: now,
          lastUpdate: now,
          isSynced: const Value(false),
        ));
        if (templateRows.isNotEmpty) {
          var order = 0;
          await _dao.upsertItems([
            for (final r in templateRows)
              LocalShoppingSessionItemsCompanion.insert(
                id: _uuid.v4(),
                sessionId: id,
                name: r['name'] as String,
                qty: Value((r['qty'] as num?)?.toInt() ?? 1),
                sortOrder: Value(order++),
                createdAt: now,
                lastUpdate: now,
              ),
          ]);
        }
        return (session, null);
      }

      // Shared → persist remotely + notify via start-shopping-session.
      final created = await _service.create(_sessionToJson(session));
      final remote = _fromJson(created);
      // Per-member share list (empty = whole household).
      await _service.setMembers(
          sessionId: remote.id, userIds: sharedWithUserIds);
      if (templateRows.isNotEmpty) {
        var order = 0;
        for (final r in templateRows) {
          await _service.createItem({
            'session_id': remote.id,
            'name': r['name'],
            'qty': (r['qty'] as num?)?.toInt() ?? 1,
            'sort_order': order++,
            'is_checked': false,
          });
        }
      }
      // Fire-and-forget notification (non-fatal). The edge fn reads the
      // session's member list (or the whole household when empty).
      try {
        await _service.notifySessionStarted(
            sessionId: remote.id, userId: userId);
      } catch (_) {/* notification is best-effort */}
      return (remote, null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'startSession'));
    }
  }

  // ── list active ───────────────────────────────────────────────────────────
  @override
  Future<(List<ShoppingSession>, Failure?)> getActiveSessions({
    required String householdId,
    required String userId,
  }) async {
    try {
      final localRows = await _dao.getActiveSessions();
      final local = <ShoppingSession>[
        for (final r in localRows)
          _fromLocal(r).copyWith(
            itemCount: (await _dao.getItems(r.id)).length,
          ),
      ];

      List<ShoppingSession> shared = const [];
      if (householdId.isNotEmpty) {
        final remoteRows = await _service.getSessionsWithCounts(
            householdId: householdId, status: 'active');
        shared = remoteRows
            .map(_fromJsonWithCount)
            .where((s) => s.scope == ShoppingListScope.shared)
            .toList();
      }

      final merged = [...local, ...shared]
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return (merged, null);
    } catch (e, st) {
      return (<ShoppingSession>[], reportError(e, st, reason: 'getActiveSessions'));
    }
  }

  @override
  Stream<List<ShoppingSession>> watchLocalActiveSessions() =>
      _dao.watchActiveSessions().map((rows) =>
          rows.map((r) => _fromLocal(r)).toList());

  @override
  Future<(ShoppingSession?, Failure?)> getSession({
    required String sessionId,
    required ShoppingListScope scope,
  }) async {
    try {
      if (scope == ShoppingListScope.personal) {
        final row = await _dao.getSession(sessionId);
        return (row == null ? null : _fromLocal(row), null);
      }
      final data = await _service.getSession(sessionId);
      return (data == null ? null : _fromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'getSession'));
    }
  }

  // ── items ──────────────────────────────────────────────────────────────
  @override
  Future<(List<ShoppingSessionItem>, Failure?)> getItems({
    required String sessionId,
    required ShoppingListScope scope,
  }) async {
    try {
      if (scope == ShoppingListScope.personal) {
        final rows = await _dao.getItems(sessionId);
        return (rows.map(_fromLocalItem).toList(), null);
      }
      final rows = await _service.getItems(sessionId);
      return (rows.map(_itemFromJson).toList(), null);
    } catch (e, st) {
      return (<ShoppingSessionItem>[], reportError(e, st, reason: 'getItems'));
    }
  }

  @override
  Future<(ShoppingSessionItem?, Failure?)> addItem(
    ShoppingSessionItem item, {
    required ShoppingListScope scope,
  }) async {
    try {
      final now = _now;
      if (scope == ShoppingListScope.personal) {
        final id = item.id.isEmpty ? _uuid.v4() : item.id;
        await _dao.upsertItem(LocalShoppingSessionItemsCompanion.insert(
          id: id,
          sessionId: item.sessionId,
          name: item.name,
          qty: Value(item.qty),
          sortOrder: Value(item.sortOrder),
          isChecked: Value(item.isChecked),
          createdAt: now,
          lastUpdate: now,
        ));
        await _touchLocalSession(item.sessionId);
        return (item.copyWith(id: id), null);
      }
      final created = await _service.createItem(_itemToJson(item));
      return (_itemFromJson(created), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'addItem'));
    }
  }

  @override
  Future<Failure?> updateItem(
    ShoppingSessionItem item, {
    required ShoppingListScope scope,
  }) async {
    try {
      if (scope == ShoppingListScope.personal) {
        await _dao.updateItem(LocalShoppingSessionItemsCompanion(
          id: Value(item.id),
          name: Value(item.name),
          qty: Value(item.qty),
          sortOrder: Value(item.sortOrder),
          isChecked: Value(item.isChecked),
          checkedAt: Value(item.checkedAt == null
              ? null
              : item.checkedAt!.millisecondsSinceEpoch ~/ 1000),
          lastUpdate: Value(_now),
        ));
        await _touchLocalSession(item.sessionId);
        return null;
      }
      await _service.updateItem(item.id, _itemToJson(item));
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'updateItem');
    }
  }

  @override
  Future<Failure?> deleteItem({
    required String itemId,
    required String sessionId,
    required ShoppingListScope scope,
  }) async {
    try {
      if (scope == ShoppingListScope.personal) {
        await _dao.deleteItem(itemId);
        await _touchLocalSession(sessionId);
        return null;
      }
      await _service.deleteItem(itemId);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'deleteItem');
    }
  }

  @override
  Future<Failure?> reorderItems({
    required String sessionId,
    required List<String> orderedItemIds,
    required ShoppingListScope scope,
  }) async {
    try {
      if (scope == ShoppingListScope.personal) {
        await _dao.reorderItems(orderedItemIds);
        await _touchLocalSession(sessionId);
        return null;
      }
      for (var i = 0; i < orderedItemIds.length; i++) {
        await _service.updateItem(orderedItemIds[i], {'sort_order': i});
      }
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'reorderItems');
    }
  }

  Future<void> _touchLocalSession(String sessionId) => _dao.updateSession(
        LocalShoppingSessionsCompanion(
          id: Value(sessionId),
          lastUpdate: Value(_now),
        ),
      );

  // ── finish / cancel ───────────────────────────────────────────────────────
  @override
  Future<(ShoppingSession?, Failure?)> finishSession({
    required ShoppingSession session,
    required String userId,
    Map<String, dynamic>? transactionJson,
  }) async {
    try {
      if (session.scope == ShoppingListScope.shared) {
        final res = await _service.finishSharedSession(
          sessionId: session.id,
          userId: userId,
          transaction: transactionJson,
        );
        return (_fromJson(res), null);
      }

      // Personal: push the full local session + items to Supabase, then clear.
      final itemRows = await _dao.getItems(session.id);
      final payload = _sessionToJson(session.copyWith(
        status: ShoppingSessionStatus.completed,
        endedAt: _now,
      ));
      final items = [
        for (final r in itemRows)
          {
            'name': r.name,
            'qty': r.qty,
            'sort_order': r.sortOrder,
            'is_checked': r.isChecked,
            'checked_at': r.checkedAt,
          }
      ];
      final res = await _service.pushLocalSession(
        session: payload,
        items: items,
        transaction: transactionJson,
      );
      await _dao.deleteSession(session.id);
      return (_fromJson(res), null);
    } catch (e, st) {
      // Offline / failed push for a personal session → keep local, flag dirty
      // for retry-on-launch so the trip is not lost.
      if (session.scope == ShoppingListScope.personal) {
        await _dao.updateSession(LocalShoppingSessionsCompanion(
          id: Value(session.id),
          status: Value(ShoppingSessionStatus.completed.name),
          endedAt: Value(_now),
          isDirty: const Value(true),
          lastUpdate: Value(_now),
        ));
      }
      return (null, reportError(e, st, reason: 'finishSession'));
    }
  }

  @override
  Future<Failure?> cancelSession({
    required ShoppingSession session,
    required String userId,
  }) async {
    try {
      if (session.scope == ShoppingListScope.shared) {
        await _service.finishSharedSession(
          sessionId: session.id,
          userId: userId,
          cancelled: true,
        );
        return null;
      }
      await _dao.deleteSession(session.id);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'cancelSession');
    }
  }

  // ── save as template ──────────────────────────────────────────────────────
  @override
  Future<(ShoppingList?, Failure?)> saveAsTemplate({
    required ShoppingSession session,
    required String name,
  }) async {
    try {
      final now = _now;
      final template = await _listService.createList({
        'household_id': session.householdId,
        'owner_id': session.ownerId,
        'scope': session.scope.name,
        'name': name,
        'status': ShoppingListStatus.active.name,
        'kind': ShoppingListKind.template.name,
        'transaction_source_id': session.transactionSourceId,
        'created_at': now,
        'last_update': now,
      });
      final templateId = template['id'] as String;

      final (items, _) =
          await getItems(sessionId: session.id, scope: session.scope);
      var order = 0;
      for (final it in items) {
        await _listService.createItem({
          'list_id': templateId,
          'name': it.name,
          'qty': it.qty,
          'sort_order': order++,
          'is_checked': false,
        });
      }
      return (_templateFromJson(template), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'saveAsTemplate'));
    }
  }

  @override
  Future<int> retryDirtySessions() async {
    try {
      final dirty = await _dao.getDirtySessions();
      var flushed = 0;
      for (final row in dirty) {
        final session = _fromLocal(row);
        final cancelled = session.status == ShoppingSessionStatus.cancelled;
        final itemRows = await _dao.getItems(session.id);
        try {
          await _service.pushLocalSession(
            session: _sessionToJson(session),
            items: [
              for (final r in itemRows)
                {
                  'name': r.name,
                  'qty': r.qty,
                  'sort_order': r.sortOrder,
                  'is_checked': r.isChecked,
                  'checked_at': r.checkedAt,
                }
            ],
            cancelled: cancelled,
          );
          await _dao.deleteSession(session.id);
          flushed++;
        } catch (_) {
          // Still offline — leave it dirty for the next attempt.
        }
      }
      return flushed;
    } catch (e, st) {
      reportError(e, st, reason: 'retryDirtySessions');
      return 0;
    }
  }

  ShoppingList _templateFromJson(Map<String, dynamic> j) => ShoppingList(
        id: j['id'] as String,
        householdId: j['household_id'] as String,
        ownerId: (j['owner_id'] as String?) ?? '',
        scope: ShoppingListScope.fromString(j['scope'] as String? ?? 'personal'),
        name: j['name'] as String,
        status: ShoppingListStatus.active,
        kind: ShoppingListKind.template,
        transactionSourceId: j['transaction_source_id'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            ((j['created_at'] as num?)?.toInt() ?? _now) * 1000),
        lastUpdate: DateTime.fromMillisecondsSinceEpoch(
            ((j['last_update'] as num?)?.toInt() ?? _now) * 1000),
      );
}
