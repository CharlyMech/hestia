import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';

abstract class ShoppingRepository {
  Future<(List<ShoppingList>, Failure?)> getLists({
    required String householdId,
    required String userId,
    ShoppingListStatus? status,
    ShoppingListKind? kind,
  });

  /// Item count per list id for a household (cheap aggregate query).
  Future<(Map<String, int>, Failure?)> getListItemCounts({
    required String householdId,
  });

  /// Replaces the per-member share list for a template. Empty [userIds] = whole
  /// household ("All").
  Future<Failure?> setListMembers({
    required String listId,
    required List<String> userIds,
  });

  /// Members a template is explicitly shared with (empty = whole household).
  Future<(List<String>, Failure?)> getListMembers(String listId);

  Future<(ShoppingList?, Failure?)> createList(ShoppingList list);

  /// Creates an active session; copies unchecked template lines when
  /// [templateListId] is set.
  Future<(ShoppingList?, Failure?)> startShoppingSession({
    required String householdId,
    required String userId,
    required String name,
    required ShoppingListScope scope,
    String? bankAccountId,
    String? transactionSourceId,
    String? templateListId,
  });

  Future<Failure?> updateList(ShoppingList list);

  Future<Failure?> deleteList(String listId);

  /// Closes a session via the `complete-shopping-session` edge function.
  /// Pass [transactionJson] (a snake_case transactions row) to atomically
  /// create the linked expense + recompute the account balance; pass
  /// [cancelled] to mark the session cancelled instead.
  Future<(ShoppingList?, Failure?)> completeSession({
    required String listId,
    Map<String, dynamic>? transactionJson,
    bool cancelled = false,
  });

  Future<(List<ShoppingListItem>, Failure?)> getItems(String listId);

  Future<(ShoppingListItem?, Failure?)> createItem(ShoppingListItem item);

  Future<Failure?> updateItem(ShoppingListItem item);

  Future<Failure?> deleteItem(String itemId);

  /// Persists a new ordering. [orderedItemIds] is the full item list in the
  /// desired top-to-bottom order; each item's `sort_order` is set to its index.
  Future<Failure?> reorderItems(List<String> orderedItemIds);
}
