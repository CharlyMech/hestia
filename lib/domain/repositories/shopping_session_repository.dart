import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_session.dart';
import 'package:hestia/domain/entities/shopping_session_item.dart';

/// Shopping sessions are local-first for personal scope (Drift only while
/// active, pushed on finish) and live-synced for shared scope (Supabase).
///
/// Every method takes the session [ShoppingListScope] so the impl can route to
/// local vs remote without re-reading the session.
abstract class ShoppingSessionRepository {
  /// Creates an active session. Personal → local Drift; shared → Supabase +
  /// `start-shopping-session` notification. Copies template items when
  /// [templateId] is set.
  Future<(ShoppingSession?, Failure?)> startSession({
    required String householdId,
    required String userId,
    required String name,
    required ShoppingListScope scope,
    String? bankAccountId,
    String? transactionSourceId,
    String? templateId,

    /// Members to share a shared session with. Empty = whole household ("All").
    List<String> sharedWithUserIds,
  });

  /// All active sessions visible to [userId]: local personal + remote shared,
  /// merged and sorted by start time descending.
  Future<(List<ShoppingSession>, Failure?)> getActiveSessions({
    required String householdId,
    required String userId,
  });

  /// Watches active personal (local) sessions for live UI updates.
  Stream<List<ShoppingSession>> watchLocalActiveSessions();

  Future<(ShoppingSession?, Failure?)> getSession({
    required String sessionId,
    required ShoppingListScope scope,
  });

  Future<(List<ShoppingSessionItem>, Failure?)> getItems({
    required String sessionId,
    required ShoppingListScope scope,
  });

  Future<(ShoppingSessionItem?, Failure?)> addItem(
    ShoppingSessionItem item, {
    required ShoppingListScope scope,
  });

  Future<Failure?> updateItem(
    ShoppingSessionItem item, {
    required ShoppingListScope scope,
  });

  Future<Failure?> deleteItem({
    required String itemId,
    required String sessionId,
    required ShoppingListScope scope,
  });

  Future<Failure?> reorderItems({
    required String sessionId,
    required List<String> orderedItemIds,
    required ShoppingListScope scope,
  });

  /// Finishes the session. Personal → `push-local-session` (persist + optional
  /// tx) then clear local rows; shared → `finish-shopping-session` (fan-out +
  /// notify). Pass [transactionJson] to create the linked expense.
  Future<(ShoppingSession?, Failure?)> finishSession({
    required ShoppingSession session,
    required String userId,
    Map<String, dynamic>? transactionJson,
  });

  /// Cancels the session (no payment). Personal → drop local; shared →
  /// `finish-shopping-session` with cancelled=true.
  Future<Failure?> cancelSession({
    required ShoppingSession session,
    required String userId,
  });

  /// Creates a new template (shopping_lists kind=template) from this session's
  /// current items.
  Future<(ShoppingList?, Failure?)> saveAsTemplate({
    required ShoppingSession session,
    required String name,
  });

  /// Retries pushing personal sessions that were finished offline (flagged
  /// dirty). Best-effort: called on launch. Returns the number flushed.
  Future<int> retryDirtySessions();
}
