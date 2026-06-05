import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class CardService extends SupabaseService {
  CardService({super.client});

  Future<List<Map<String, dynamic>>> getCardsByAccount({
    required String accountId,
    bool activeOnly = true,
  }) async {
    try {
      var query = from(SupabaseTables.paymentCards)
          .select('''
            *,
            bank_accounts:account_id(
              name,
              institution_id,
              financial_institutions:institution_id(name, logo_asset, brand_color)
            )
          ''')
          .eq('account_id', accountId);

      if (activeOnly) query = query.eq('is_active', true);

      final response = await query.order('sort_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch cards: $e');
    }
  }

  Future<Map<String, dynamic>> createCard(Map<String, dynamic> data) async {
    try {
      final response = await from(SupabaseTables.paymentCards)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      throw ServerException('Failed to create card: $e');
    }
  }

  Future<void> updateCard(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.paymentCards).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update card: $e');
    }
  }

  Future<void> deleteCard(String id) async {
    try {
      await from(SupabaseTables.paymentCards).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete card: $e');
    }
  }
}
