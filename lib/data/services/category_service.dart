import 'package:home_expenses/core/constants/supabase_tables.dart';
import 'package:home_expenses/core/error/exceptions.dart';

import 'supabase_service.dart';

class CategoryService extends SupabaseService {
  CategoryService({super.client});

  Future<List<Map<String, dynamic>>> getCategories({
    required String householdId,
    String? type,
    bool activeOnly = true,
  }) async {
    try {
      var query = from(SupabaseTables.categories)
          .select()
          .eq('household_id', householdId);

      if (type != null) query = query.eq('type', type);
      if (activeOnly) query = query.eq('is_active', true);

      final response = await query.order('sort_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch categories: $e');
    }
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    try {
      final response =
          await from(SupabaseTables.categories).insert(data).select().single();
      return response;
    } catch (e) {
      throw ServerException('Failed to create category: $e');
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.categories).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await from(SupabaseTables.categories).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete category: $e');
    }
  }
}
