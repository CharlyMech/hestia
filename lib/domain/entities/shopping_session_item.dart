import 'package:equatable/equatable.dart';

import 'shopping_list_item.dart';

/// Single line entry inside a [ShoppingSession]. Mirror of [ShoppingListItem]
/// but scoped to a session (`sessionId`) instead of a template (`listId`).
class ShoppingSessionItem extends Equatable {
  final String id;
  final String sessionId;
  final String name;
  final int qty;

  /// Lower [sortOrder] floats to the top.
  final int sortOrder;
  final bool isChecked;
  final DateTime? checkedAt;
  final DateTime createdAt;
  final DateTime lastUpdate;

  const ShoppingSessionItem({
    required this.id,
    required this.sessionId,
    required this.name,
    this.qty = 1,
    this.sortOrder = 0,
    this.isChecked = false,
    this.checkedAt,
    required this.createdAt,
    required this.lastUpdate,
  });

  ShoppingSessionItem copyWith({
    String? id,
    String? sessionId,
    String? name,
    int? qty,
    int? sortOrder,
    bool? isChecked,
    DateTime? checkedAt,
    bool clearCheckedAt = false,
    DateTime? createdAt,
    DateTime? lastUpdate,
  }) =>
      ShoppingSessionItem(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        name: name ?? this.name,
        qty: qty ?? this.qty,
        sortOrder: sortOrder ?? this.sortOrder,
        isChecked: isChecked ?? this.isChecked,
        checkedAt: clearCheckedAt ? null : (checkedAt ?? this.checkedAt),
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );

  /// View as a [ShoppingListItem] (e.g. to reuse template-diff helpers).
  ShoppingListItem toShoppingListItem({String? listId}) => ShoppingListItem(
        id: id,
        listId: listId ?? sessionId,
        name: name,
        qty: qty,
        sortOrder: sortOrder,
        isChecked: isChecked,
        checkedAt: checkedAt,
        createdAt: createdAt,
        lastUpdate: lastUpdate,
      );

  static ShoppingSessionItem fromShoppingListItem(
    ShoppingListItem item, {
    required String sessionId,
  }) =>
      ShoppingSessionItem(
        id: item.id,
        sessionId: sessionId,
        name: item.name,
        qty: item.qty,
        sortOrder: item.sortOrder,
        isChecked: item.isChecked,
        checkedAt: item.checkedAt,
        createdAt: item.createdAt,
        lastUpdate: item.lastUpdate,
      );

  @override
  List<Object?> get props => [id, name, qty, isChecked, sortOrder];
}
