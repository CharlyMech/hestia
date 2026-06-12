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
    String? bankAccountId,
    String? type,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = from(SupabaseTables.transactions).select('''
            *,
            categories:category_id(name, color),
            bank_accounts:bank_account_id(name),
            profiles:user_id(display_name, email)
          ''').eq('household_id', householdId);

      if (userId != null) query = query.eq('user_id', userId);
      if (startDate != null) query = query.gte('date', startDate);
      if (endDate != null) query = query.lte('date', endDate);
      if (categoryId != null) query = query.eq('category_id', categoryId);
      if (bankAccountId != null) {
        query = query.eq('bank_account_id', bankAccountId);
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

  /// Insert via the `create-transaction` edge function so the bank account
  /// balance is recomputed server-side (authoritative path).
  Future<Map<String, dynamic>> createTransaction(
      Map<String, dynamic> data) async {
    try {
      final res = await client.functions.invoke(
        'create-transaction',
        body: {'transaction': data},
      );
      final body = res.data as Map<String, dynamic>;
      if (body['error'] != null) {
        throw ServerException('Failed to create transaction: ${body['error']}');
      }
      return Map<String, dynamic>.from(body['transaction'] as Map);
    } catch (e) {
      throw ServerException('Failed to create transaction: $e');
    }
  }

  /// Update via the same edge function (passes `id` → update branch).
  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    try {
      final res = await client.functions.invoke(
        'create-transaction',
        body: {'transaction': data, 'id': id},
      );
      final body = res.data as Map<String, dynamic>;
      if (body['error'] != null) {
        throw ServerException('Failed to update transaction: ${body['error']}');
      }
    } catch (e) {
      throw ServerException('Failed to update transaction: $e');
    }
  }

  /// Delete via the `delete-transaction` edge function (recomputes balance).
  Future<void> deleteTransaction(String id) async {
    try {
      final res = await client.functions.invoke(
        'delete-transaction',
        body: {'id': id},
      );
      final body = res.data as Map<String, dynamic>;
      if (body['error'] != null) {
        throw ServerException('Failed to delete transaction: ${body['error']}');
      }
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
            from_account:from_account_id(name),
            to_account:to_account_id(name)
          ''').eq('household_id', householdId);

      if (startDate != null) query = query.gte('date', startDate);
      if (endDate != null) query = query.lte('date', endDate);

      final response = await query.order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch transfers: $e');
    }
  }

  /// Insert via the `create-transfer` edge function (recomputes both balances).
  Future<Map<String, dynamic>> createTransfer(Map<String, dynamic> data) async {
    try {
      final res = await client.functions.invoke(
        'create-transfer',
        body: {'transfer': data},
      );
      final body = res.data as Map<String, dynamic>;
      if (body['error'] != null) {
        throw ServerException('Failed to create transfer: ${body['error']}');
      }
      return Map<String, dynamic>.from(body['transfer'] as Map);
    } catch (e) {
      throw ServerException('Failed to create transfer: $e');
    }
  }
}
