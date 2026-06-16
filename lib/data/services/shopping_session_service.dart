import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class ShoppingSessionService extends SupabaseService {
  ShoppingSessionService({super.client});

  Future<List<Map<String, dynamic>>> getSessions({
    required String householdId,
    String? status,
    int limit = 50,
  }) async {
    try {
      var query = from(SupabaseTables.shoppingSessions)
          .select()
          .eq('household_id', householdId);
      if (status != null) query = query.eq('status', status);
      final res =
          await query.order('started_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch shopping sessions: $e');
    }
  }

  /// Active sessions for a household with a cheap item count
  /// (`shopping_session_items(count)`).
  Future<List<Map<String, dynamic>>> getSessionsWithCounts({
    required String householdId,
    String? status,
    int limit = 50,
  }) async {
    try {
      var query = from(SupabaseTables.shoppingSessions)
          .select('*, ${SupabaseTables.shoppingSessionItems}(count)')
          .eq('household_id', householdId);
      if (status != null) query = query.eq('status', status);
      final res =
          await query.order('started_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch shopping sessions: $e');
    }
  }

  Future<Map<String, dynamic>?> getSession(String id) async {
    try {
      return await from(SupabaseTables.shoppingSessions)
          .select()
          .eq('id', id)
          .maybeSingle();
    } catch (e) {
      throw ServerException('Failed to fetch shopping session: $e');
    }
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      return await from(SupabaseTables.shoppingSessions)
          .insert(data)
          .select()
          .single();
    } catch (e) {
      throw ServerException('Failed to create shopping session: $e');
    }
  }

  /// Legacy: start a session from a `shopping_lists` row (list-based model).
  /// Retained while the old `ShoppingRepository.startShoppingSession` path is
  /// migrated to the new session model. Best-effort notification.
  Future<void> startSession({
    required String listId,
    required String userId,
  }) async {
    final res = await client.functions.invoke(
      'start-shopping-session',
      body: {'list_id': listId, 'user_id': userId},
    );
    final body = res.data as Map<String, dynamic>?;
    if (body != null && body['error'] != null) {
      throw ServerException('Failed to start session: ${body['error']}');
    }
  }

  /// Notify household members that a shared session started, via the
  /// `start-shopping-session` edge fn (new session-id model).
  Future<void> notifySessionStarted({
    required String sessionId,
    required String userId,
  }) async {
    final res = await client.functions.invoke(
      'start-shopping-session',
      body: {'session_id': sessionId, 'user_id': userId},
    );
    final body = res.data as Map<String, dynamic>?;
    if (body != null && body['error'] != null) {
      throw ServerException('Failed to notify session start: ${body['error']}');
    }
  }

  /// Complete (or cancel) a session via `complete-shopping-session` edge fn.
  /// Pass [transaction] to atomically create the expense.
  Future<Map<String, dynamic>> completeSession({
    required String listId,
    Map<String, dynamic>? transaction,
    bool cancelled = false,
  }) async {
    try {
      final res = await client.functions.invoke(
        'complete-shopping-session',
        body: {
          'list_id': listId,
          if (transaction != null) 'transaction': transaction,
          if (cancelled) 'cancelled': true,
        },
      );
      final body = res.data as Map<String, dynamic>;
      if (body['error'] != null) {
        throw ServerException('Failed to complete session: ${body['error']}');
      }
      return Map<String, dynamic>.from(body['list'] as Map);
    } catch (e) {
      throw ServerException('Failed to complete session: $e');
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.shoppingSessions).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update shopping session: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await from(SupabaseTables.shoppingSessions).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete shopping session: $e');
    }
  }

  // ── per-member sharing ───────────────────────────────────────────────────
  /// Replaces the member share-list for a session. Empty [userIds] = whole
  /// household ("All").
  Future<void> setMembers({
    required String sessionId,
    required List<String> userIds,
  }) async {
    try {
      await from(SupabaseTables.shoppingSessionMembers)
          .delete()
          .eq('session_id', sessionId);
      if (userIds.isEmpty) return;
      await from(SupabaseTables.shoppingSessionMembers).insert([
        for (final uid in userIds) {'session_id': sessionId, 'user_id': uid},
      ]);
    } catch (e) {
      throw ServerException('Failed to set session members: $e');
    }
  }

  Future<List<String>> getMembers(String sessionId) async {
    try {
      final res = await from(SupabaseTables.shoppingSessionMembers)
          .select('user_id')
          .eq('session_id', sessionId);
      return [for (final r in res) r['user_id'] as String];
    } catch (e) {
      throw ServerException('Failed to fetch session members: $e');
    }
  }

  // ── session items (shared sessions, live) ────────────────────────────────
  Future<List<Map<String, dynamic>>> getItems(String sessionId) async {
    try {
      final res = await from(SupabaseTables.shoppingSessionItems)
          .select()
          .eq('session_id', sessionId)
          .order('sort_order');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch session items: $e');
    }
  }

  Future<Map<String, dynamic>> createItem(Map<String, dynamic> data) async {
    try {
      return await from(SupabaseTables.shoppingSessionItems)
          .insert(data)
          .select()
          .single();
    } catch (e) {
      throw ServerException('Failed to create session item: $e');
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.shoppingSessionItems)
          .update(data)
          .eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update session item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await from(SupabaseTables.shoppingSessionItems).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete session item: $e');
    }
  }

  // ── edge functions (new session model) ───────────────────────────────────

  /// Finishes a SHARED session for everyone + notifies other members.
  /// Returns the updated session row.
  Future<Map<String, dynamic>> finishSharedSession({
    required String sessionId,
    required String userId,
    Map<String, dynamic>? transaction,
    bool cancelled = false,
  }) async {
    try {
      final res = await client.functions.invoke(
        'finish-shopping-session',
        body: {
          'session_id': sessionId,
          'user_id': userId,
          if (transaction != null) 'transaction': transaction,
          if (cancelled) 'cancelled': true,
        },
      );
      final body = res.data as Map<String, dynamic>;
      if (body['error'] != null) {
        throw ServerException('Failed to finish session: ${body['error']}');
      }
      return Map<String, dynamic>.from(body['session'] as Map);
    } catch (e) {
      throw ServerException('Failed to finish session: $e');
    }
  }

  /// Pushes a finished PERSONAL (local-first) session + its items to Supabase.
  /// Returns the persisted session row.
  Future<Map<String, dynamic>> pushLocalSession({
    required Map<String, dynamic> session,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? transaction,
    bool cancelled = false,
  }) async {
    try {
      final res = await client.functions.invoke(
        'push-local-session',
        body: {
          'session': session,
          'items': items,
          if (transaction != null) 'transaction': transaction,
          if (cancelled) 'cancelled': true,
        },
      );
      final body = res.data as Map<String, dynamic>;
      if (body['error'] != null) {
        throw ServerException('Failed to push session: ${body['error']}');
      }
      return Map<String, dynamic>.from(body['session'] as Map);
    } catch (e) {
      throw ServerException('Failed to push session: $e');
    }
  }
}
