import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class TransactionService extends SupabaseService {
  TransactionService({super.client});

  Future<List<Map<String, dynamic>>> getTransactions({
    required String householdId,
    String? userId,
    int? startDate,
    int? endDate,
    String? categoryId,
    String? moneySourceId,
    String? type,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = from(SupabaseTables.transactions).select('''
            *,
            categories:category_id(name, color),
            money_sources:money_source_id(name),
            profiles:user_id(display_name, email)
          ''').eq('household_id', householdId);

      if (userId != null) query = query.eq('user_id', userId);
      if (startDate != null) query = query.gte('date', startDate);
      if (endDate != null) query = query.lte('date', endDate);
      if (categoryId != null) query = query.eq('category_id', categoryId);
      if (moneySourceId != null) {
        query = query.eq('money_source_id', moneySourceId);
      }
      if (type != null) query = query.eq('type', type);

      final response = await query
          .order('date', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch transactions: $e');
    }
  }

  Future<Map<String, dynamic>> createTransaction(
      Map<String, dynamic> data) async {
    try {
      final response = await from(SupabaseTables.transactions)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      throw ServerException('Failed to create transaction: $e');
    }
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.transactions).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await from(SupabaseTables.transactions).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete transaction: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTransfers({
    required String householdId,
    int? startDate,
    int? endDate,
  }) async {
    try {
      var query = from(SupabaseTables.transfers).select('''
            *,
            from_source:from_source_id(name),
            to_source:to_source_id(name)
          ''').eq('household_id', householdId);

      if (startDate != null) query = query.gte('date', startDate);
      if (endDate != null) query = query.lte('date', endDate);

      final response = await query.order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch transfers: $e');
    }
  }

  Future<Map<String, dynamic>> createTransfer(Map<String, dynamic> data) async {
    try {
      final response =
          await from(SupabaseTables.transfers).insert(data).select().single();
      return response;
    } catch (e) {
      throw ServerException('Failed to create transfer: $e');
    }
  }
}
