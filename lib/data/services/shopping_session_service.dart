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
