import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class HomeService extends SupabaseService {
  HomeService({super.client});

  Future<List<Map<String, dynamic>>> getHomes(
    String householdId, {
    bool activeOnly = true,
  }) async {
    try {
      var query = from(SupabaseTables.homes)
          .select()
          .eq('household_id', householdId);
      if (activeOnly) query = query.eq('is_active', true);
      final res = await query.order('name');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch homes: $e');
    }
  }

  Future<Map<String, dynamic>?> getHome(String id) async {
    try {
      return await from(SupabaseTables.homes)
          .select()
          .eq('id', id)
          .maybeSingle();
    } catch (e) {
      throw ServerException('Failed to fetch home: $e');
    }
  }

  Future<Map<String, dynamic>> createHome(Map<String, dynamic> data) async {
    try {
      return await from(SupabaseTables.homes).insert(data).select().single();
    } catch (e) {
      throw ServerException('Failed to create home: $e');
    }
  }

  Future<void> updateHome(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.homes).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update home: $e');
    }
  }

  Future<void> deleteHome(String id) async {
    try {
      await from(SupabaseTables.homes).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete home: $e');
    }
  }
}
