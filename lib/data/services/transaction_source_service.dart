import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class TransactionSourceService extends SupabaseService {
  TransactionSourceService({super.client});

  Future<List<Map<String, dynamic>>> getAll({
    required String householdId,
    bool activeOnly = true,
  }) async {
    try {
      var query = from(SupabaseTables.transactionSources)
          .select()
          .eq('household_id', householdId);
      if (activeOnly) query = query.eq('is_active', true);
      final res = await query.order('name');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch transaction sources: $e');
    }
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      return await from(SupabaseTables.transactionSources)
          .insert(data)
          .select()
          .single();
    } catch (e) {
      throw ServerException('Failed to create transaction source: $e');
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.transactionSources).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update transaction source: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await from(SupabaseTables.transactionSources).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete transaction source: $e');
    }
  }
}
