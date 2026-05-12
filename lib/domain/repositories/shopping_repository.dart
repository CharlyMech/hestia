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

  Future<(List<ShoppingListItem>, Failure?)> getItems(String listId);

  Future<(ShoppingListItem?, Failure?)> createItem(ShoppingListItem item);

  Future<Failure?> updateItem(ShoppingListItem item);

  Future<Failure?> deleteItem(String itemId);
}
