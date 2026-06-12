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

  /// Start a shared shopping session via `start-shopping-session` edge fn.
  /// Pushes FCM notification to other household members server-side.
  Future<Map<String, dynamic>> startSession({
    required String listId,
    required String userId,
  }) async {
    try {
      final res = await client.functions.invoke(
        'start-shopping-session',
        body: {'list_id': listId, 'user_id': userId},
      );
      final body = res.data as Map<String, dynamic>;
      if (body['error'] != null) {
        throw ServerException('Failed to start session: ${body['error']}');
      }
      return Map<String, dynamic>.from(body['list'] as Map);
    } catch (e) {
      throw ServerException('Failed to start session: $e');
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
}
