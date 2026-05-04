import 'package:equatable/equatable.dart';

/// Single line entry inside a [ShoppingList]. Toggling [isChecked] sends the
/// item to the bottom of the list with a small animated delay.
class ShoppingListItem extends Equatable {
  final String id;
  final String listId;
  final String name;
  final int qty;

  /// Lower [sortOrder] floats to the top. Checked items get a high value so
  /// they fall to the bottom.
  final int sortOrder;
  final bool isChecked;
  final DateTime? checkedAt;
  final DateTime createdAt;
  final DateTime lastUpdate;

  const ShoppingListItem({
    required this.id,
    required this.listId,
    required this.name,
    this.qty = 1,
    this.sortOrder = 0,
    this.isChecked = false,
    this.checkedAt,
    required this.createdAt,
    required this.lastUpdate,
  });

  ShoppingListItem copyWith({
    String? id,
    String? listId,
    String? name,
    int? qty,
    int? sortOrder,
    bool? isChecked,
    DateTime? checkedAt,
    bool clearCheckedAt = false,
    DateTime? createdAt,
    DateTime? lastUpdate,
  }) =>
      ShoppingListItem(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        name: name ?? this.name,
        qty: qty ?? this.qty,
        sortOrder: sortOrder ?? this.sortOrder,
        isChecked: isChecked ?? this.isChecked,
        checkedAt: clearCheckedAt ? null : (checkedAt ?? this.checkedAt),
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );

  @override
  List<Object?> get props => [id, name, qty, isChecked, sortOrder];
}
