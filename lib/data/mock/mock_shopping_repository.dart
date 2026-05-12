import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';
import 'package:hestia/domain/repositories/shopping_repository.dart';
import 'package:uuid/uuid.dart';

class MockShoppingRepository implements ShoppingRepository {
  static const _uuid = Uuid();

  void _autoExpireSessions(MockStore store) {
    final now = DateTime.now();
    for (var i = 0; i < store.shoppingLists.length; i++) {
      final l = store.shoppingLists[i];
      if (!l.shouldAutoExpireSession()) continue;
      store.shoppingLists[i] = l.copyWith(
        status: ShoppingListStatus.cancelled,
        sessionEndedAt: now,
        lastUpdate: now,
      );
    }
  }

  @override
  Future<(List<ShoppingList>, Failure?)> getLists({
    required String householdId,
    required String userId,
    ShoppingListStatus? status,
    ShoppingListKind? kind,
  }) async {
    _autoExpireSessions(MockStore.instance);
    final lists = MockStore.instance.shoppingLists
        .where((l) => l.householdId == householdId)
        .where((l) {
          if (l.scope == ShoppingListScope.shared) return true;
          return l.ownerId == userId;
        })
        .where((l) => status == null || l.status == status)
        .where((l) => kind == null || l.kind == kind)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return (lists, null);
  }

  @override
  Future<(ShoppingList?, Failure?)> createList(ShoppingList list) async {
    final created = list.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      lastUpdate: DateTime.now(),
    );
    MockStore.instance.shoppingLists.add(created);
    return (created, null);
  }

  @override
  Future<(ShoppingList?, Failure?)> startShoppingSession({
    required String householdId,
    required String userId,
    required String name,
    required ShoppingListScope scope,
    String? bankAccountId,
    String? transactionSourceId,
    String? templateListId,
  }) async {
    final now = DateTime.now();
    final session = ShoppingList(
      id: _uuid.v4(),
      householdId: householdId,
      ownerId: userId,
      scope: scope,
      name: name,
      status: ShoppingListStatus.active,
      kind: ShoppingListKind.session,
      templateId: templateListId,
      sessionStartedAt: now,
      bankAccountId: bankAccountId,
      transactionSourceId: transactionSourceId,
      createdAt: now,
      lastUpdate: now,
    );
    MockStore.instance.shoppingLists.add(session);

    if (templateListId != null) {
      final srcItems = MockStore.instance.shoppingListItems
          .where((i) => i.listId == templateListId)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      var order = 0;
      for (final it in srcItems) {
        MockStore.instance.shoppingListItems.add(
          ShoppingListItem(
            id: _uuid.v4(),
            listId: session.id,
            name: it.name,
            qty: it.qty,
            sortOrder: order++,
            isChecked: false,
            createdAt: now,
            lastUpdate: now,
          ),
        );
      }
    }
    return (session, null);
  }

  @override
  Future<Failure?> updateList(ShoppingList list) async {
    final lists = MockStore.instance.shoppingLists;
    final i = lists.indexWhere((l) => l.id == list.id);
    if (i < 0) return const ServerFailure('Shopping list not found');
    lists[i] = list.copyWith(lastUpdate: DateTime.now());
    return null;
  }

  @override
  Future<Failure?> deleteList(String listId) async {
    MockStore.instance.shoppingLists.removeWhere((l) => l.id == listId);
    MockStore.instance.shoppingListItems.removeWhere((i) => i.listId == listId);
    return null;
  }

  @override
  Future<(List<ShoppingListItem>, Failure?)> getItems(String listId) async {
    final items = MockStore.instance.shoppingListItems
        .where((i) => i.listId == listId)
        .toList()
      ..sort((a, b) {
        if (a.isChecked != b.isChecked) return a.isChecked ? 1 : -1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    return (items, null);
  }

  @override
  Future<(ShoppingListItem?, Failure?)> createItem(
      ShoppingListItem item) async {
    final created = item.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      lastUpdate: DateTime.now(),
    );
    MockStore.instance.shoppingListItems.add(created);
    return (created, null);
  }

  @override
  Future<Failure?> updateItem(ShoppingListItem item) async {
    final items = MockStore.instance.shoppingListItems;
    final i = items.indexWhere((x) => x.id == item.id);
    if (i < 0) return const ServerFailure('Item not found');
    items[i] = item.copyWith(lastUpdate: DateTime.now());
    return null;
  }

  @override
  Future<Failure?> deleteItem(String itemId) async {
    MockStore.instance.shoppingListItems.removeWhere((i) => i.id == itemId);
    return null;
  }
}
