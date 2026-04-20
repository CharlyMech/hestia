import 'package:home_expenses/core/constants/supabase_tables.dart';
import 'package:home_expenses/core/error/exceptions.dart';

import 'supabase_service.dart';

class MoneySourceService extends SupabaseService {
  MoneySourceService({super.client});

  Future<List<Map<String, dynamic>>> getMoneySources({
    required String householdId,
    String? userId,
    bool activeOnly = true,
  }) async {
    try {
      var query = from(SupabaseTables.moneySources)
          .select()
          .eq('household_id', householdId);

      if (activeOnly) query = query.eq('is_active', true);

      final response = await query.order('sort_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch money sources: $e');
    }
  }

  Future<Map<String, dynamic>> createMoneySource(
      Map<String, dynamic> data) async {
    try {
      final response = await from(SupabaseTables.moneySources)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      throw ServerException('Failed to create money source: $e');
    }
  }

  Future<void> updateMoneySource(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.moneySources).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update money source: $e');
    }
  }

  Future<void> deleteMoneySource(String id) async {
    try {
      await from(SupabaseTables.moneySources).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete money source: $e');
    }
  }
}
