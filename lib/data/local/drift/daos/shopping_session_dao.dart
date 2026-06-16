import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/local_shopping_sessions.dart';
import '../tables/local_shopping_session_items.dart';

part 'shopping_session_dao.g.dart';

/// Local (Drift) persistence for personal shopping sessions — the source of
/// truth while a personal session is active (no Supabase writes until finish).
@DriftAccessor(tables: [LocalShoppingSessions, LocalShoppingSessionItems])
class ShoppingSessionDao extends DatabaseAccessor<AppDatabase>
    with _$ShoppingSessionDaoMixin {
  ShoppingSessionDao(super.db);

  // ── sessions ───────────────────────────────────────────────────────────
  Future<List<LocalShoppingSession>> getActiveSessions() =>
      (select(localShoppingSessions)
            ..where((s) => s.status.equals('active'))
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
          .get();

  Stream<List<LocalShoppingSession>> watchActiveSessions() =>
      (select(localShoppingSessions)
            ..where((s) => s.status.equals('active'))
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
          .watch();

  /// Sessions finished locally but not yet pushed (offline finish retry).
  Future<List<LocalShoppingSession>> getDirtySessions() =>
      (select(localShoppingSessions)..where((s) => s.isDirty.equals(true)))
          .get();

  Future<LocalShoppingSession?> getSession(String id) =>
      (select(localShoppingSessions)..where((s) => s.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsertSession(LocalShoppingSessionsCompanion session) =>
      into(localShoppingSessions).insertOnConflictUpdate(session);

  Future<void> updateSession(LocalShoppingSessionsCompanion session) =>
      (update(localShoppingSessions)
            ..where((s) => s.id.equals(session.id.value)))
          .write(session);

  Future<void> deleteSession(String id) async {
    await (delete(localShoppingSessionItems)
          ..where((i) => i.sessionId.equals(id)))
        .go();
    await (delete(localShoppingSessions)..where((s) => s.id.equals(id))).go();
  }

  // ── items ──────────────────────────────────────────────────────────────
  Future<List<LocalShoppingSessionItem>> getItems(String sessionId) =>
      (select(localShoppingSessionItems)
            ..where((i) => i.sessionId.equals(sessionId))
            ..orderBy([(i) => OrderingTerm.asc(i.sortOrder)]))
          .get();

  Stream<List<LocalShoppingSessionItem>> watchItems(String sessionId) =>
      (select(localShoppingSessionItems)
            ..where((i) => i.sessionId.equals(sessionId))
            ..orderBy([(i) => OrderingTerm.asc(i.sortOrder)]))
          .watch();

  Future<void> upsertItem(LocalShoppingSessionItemsCompanion item) =>
      into(localShoppingSessionItems).insertOnConflictUpdate(item);

  Future<void> upsertItems(List<LocalShoppingSessionItemsCompanion> items) =>
      batch((b) => b.insertAllOnConflictUpdate(localShoppingSessionItems, items));

  Future<void> updateItem(LocalShoppingSessionItemsCompanion item) =>
      (update(localShoppingSessionItems)
            ..where((i) => i.id.equals(item.id.value)))
          .write(item);

  Future<void> deleteItem(String id) =>
      (delete(localShoppingSessionItems)..where((i) => i.id.equals(id))).go();

  /// Persists a new ordering: each id's `sort_order` becomes its index.
  Future<void> reorderItems(List<String> orderedItemIds) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await batch((b) {
      for (var i = 0; i < orderedItemIds.length; i++) {
        b.update(
          localShoppingSessionItems,
          LocalShoppingSessionItemsCompanion(
            sortOrder: Value(i),
            lastUpdate: Value(now),
          ),
          where: (t) => t.id.equals(orderedItemIds[i]),
        );
      }
    });
  }
}
