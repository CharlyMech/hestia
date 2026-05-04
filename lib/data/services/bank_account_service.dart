import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class BankAccountService extends SupabaseService {
  BankAccountService({super.client});

  Future<List<Map<String, dynamic>>> getBankAccounts({
    required String householdId,
    String? userId,
    bool activeOnly = true,
  }) async {
    try {
      var query = from(SupabaseTables.bankAccounts)
          .select()
          .eq('household_id', householdId);

      if (activeOnly) query = query.eq('is_active', true);

      final response = await query.order('sort_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch money sources: $e');
    }
  }

  Future<Map<String, dynamic>> createBankAccount(
      Map<String, dynamic> data) async {
    try {
      final response = await from(SupabaseTables.bankAccounts)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      throw ServerException('Failed to create money source: $e');
    }
  }

  Future<void> updateBankAccount(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.bankAccounts).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update money source: $e');
    }
  }

  Future<void> deleteBankAccount(String id) async {
    try {
      await from(SupabaseTables.bankAccounts).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete money source: $e');
    }
  }
}
