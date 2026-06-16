import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class ShoppingService extends SupabaseService {
  ShoppingService({super.client});

  // ── Lists ──────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getLists({
    required String householdId,
    String? status,
    String? kind,
  }) async {
    try {
      var query = from(SupabaseTables.shoppingLists)
          .select()
          .eq('household_id', householdId);
      if (status != null) query = query.eq('status', status);
      if (kind != null) query = query.eq('kind', kind);
      final res = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch shopping lists: $e');
    }
  }

  /// Lists for a household with a cheap item count
  /// (`shopping_list_items(count)`). Returns rows with a nested count aggregate.
  Future<List<Map<String, dynamic>>> getListsWithCounts({
    required String householdId,
    String? kind,
  }) async {
    try {
      var query = from(SupabaseTables.shoppingLists)
          .select('*, ${SupabaseTables.shoppingListItems}(count)')
          .eq('household_id', householdId);
      if (kind != null) query = query.eq('kind', kind);
      final res = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch shopping lists: $e');
    }
  }

  Future<Map<String, dynamic>> createList(Map<String, dynamic> data) async {
    try {
      return await from(SupabaseTables.shoppingLists)
          .insert(data)
          .select()
          .single();
    } catch (e) {
      throw ServerException('Failed to create shopping list: $e');
    }
  }

  Future<void> updateList(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.shoppingLists).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update shopping list: $e');
    }
  }

  Future<void> deleteList(String id) async {
    try {
      await from(SupabaseTables.shoppingLists).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete shopping list: $e');
    }
  }

  // ── per-member sharing ───────────────────────────────────────────────────
  /// Replaces the member share-list for a template. Empty [userIds] = whole
  /// household ("All").
  Future<void> setMembers({
    required String listId,
    required List<String> userIds,
  }) async {
    try {
      await from(SupabaseTables.shoppingListMembers)
          .delete()
          .eq('list_id', listId);
      if (userIds.isEmpty) return;
      await from(SupabaseTables.shoppingListMembers).insert([
        for (final uid in userIds) {'list_id': listId, 'user_id': uid},
      ]);
    } catch (e) {
      throw ServerException('Failed to set list members: $e');
    }
  }

  Future<List<String>> getMembers(String listId) async {
    try {
      final res = await from(SupabaseTables.shoppingListMembers)
          .select('user_id')
          .eq('list_id', listId);
      return [for (final r in res) r['user_id'] as String];
    } catch (e) {
      throw ServerException('Failed to fetch list members: $e');
    }
  }

  // ── Items ──────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getItems(String listId) async {
    try {
      final res = await from(SupabaseTables.shoppingListItems)
          .select()
          .eq('list_id', listId)
          .order('sort_order');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch shopping items: $e');
    }
  }

  Future<Map<String, dynamic>> createItem(Map<String, dynamic> data) async {
    try {
      return await from(SupabaseTables.shoppingListItems)
          .insert(data)
          .select()
          .single();
    } catch (e) {
      throw ServerException('Failed to create shopping item: $e');
    }
  }

  Future<void> createItems(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) return;
    try {
      await from(SupabaseTables.shoppingListItems).insert(data);
    } catch (e) {
      throw ServerException('Failed to create shopping items: $e');
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.shoppingListItems).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update shopping item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await from(SupabaseTables.shoppingListItems).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete shopping item: $e');
    }
  }
}
