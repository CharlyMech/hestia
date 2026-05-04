import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';

abstract class ShoppingRepository {
  Future<(List<ShoppingList>, Failure?)> getLists({
    required String householdId,
    required String userId,
    ShoppingListStatus? status,
  });

  Future<(ShoppingList?, Failure?)> createList(ShoppingList list);

  Future<Failure?> updateList(ShoppingList list);

  Future<Failure?> deleteList(String listId);

  Future<(List<ShoppingListItem>, Failure?)> getItems(String listId);

  Future<(ShoppingListItem?, Failure?)> createItem(ShoppingListItem item);

  Future<Failure?> updateItem(ShoppingListItem item);

  Future<Failure?> deleteItem(String itemId);
}
