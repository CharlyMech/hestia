import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';
import 'package:hestia/domain/repositories/shopping_repository.dart';

/// Bloc for a single shopping list — items CRUD + check toggle. Pairs with
/// the detail screen.
abstract class ShoppingListEvent extends Equatable {
  const ShoppingListEvent();
  @override
  List<Object?> get props => const [];
}

class ShoppingListLoad extends ShoppingListEvent {
  /// Pass the [list] entity so the bloc has metadata (status/scope/etc.)
  /// without needing to refetch from the index.
  final ShoppingList list;
  const ShoppingListLoad(this.list);
  @override
  List<Object?> get props => [list];
}

class ShoppingListAddItem extends ShoppingListEvent {
  final String name;
  final int qty;
  const ShoppingListAddItem({required this.name, this.qty = 1});
  @override
  List<Object?> get props => [name, qty];
}

class ShoppingListUpdateItem extends ShoppingListEvent {
  final ShoppingListItem item;
  const ShoppingListUpdateItem(this.item);
  @override
  List<Object?> get props => [item];
}

class ShoppingListDeleteItem extends ShoppingListEvent {
  final String itemId;
  const ShoppingListDeleteItem(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class ShoppingListToggleItem extends ShoppingListEvent {
  final String itemId;
  const ShoppingListToggleItem(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

abstract class ShoppingListState extends Equatable {
  const ShoppingListState();
  @override
  List<Object?> get props => const [];
}

class ShoppingListInitial extends ShoppingListState {
  const ShoppingListInitial();
}

class ShoppingListLoading extends ShoppingListState {
  const ShoppingListLoading();
}

class ShoppingListLoaded extends ShoppingListState {
  final ShoppingList list;
  final List<ShoppingListItem> items;
  const ShoppingListLoaded({required this.list, required this.items});

  int get checkedCount => items.where((i) => i.isChecked).length;

  @override
  List<Object?> get props => [list, items];
}

class ShoppingListError extends ShoppingListState {
  final String message;
  const ShoppingListError(this.message);
  @override
  List<Object?> get props => [message];
}

class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  final ShoppingRepository _repo;
  ShoppingList? _list;

  ShoppingListBloc(this._repo) : super(const ShoppingListInitial()) {
    on<ShoppingListLoad>(_onLoad);
    on<ShoppingListAddItem>(_onAdd);
    on<ShoppingListUpdateItem>(_onUpdate);
    on<ShoppingListDeleteItem>(_onDelete);
    on<ShoppingListToggleItem>(_onToggle);
  }

  Future<void> _onLoad(
      ShoppingListLoad e, Emitter<ShoppingListState> emit) async {
    _list = e.list;
    emit(const ShoppingListLoading());
    await _fetch(emit);
  }

  Future<void> _onAdd(
      ShoppingListAddItem e, Emitter<ShoppingListState> emit) async {
    final list = _list;
    if (list == null) return;
    final cur = state;
    final maxOrder = cur is ShoppingListLoaded && cur.items.isNotEmpty
        ? cur.items.map((i) => i.sortOrder).reduce((a, b) => a > b ? a : b)
        : 0;
    final now = DateTime.now();
    await _repo.createItem(ShoppingListItem(
      id: '',
      listId: list.id,
      name: e.name.trim(),
      qty: e.qty,
      sortOrder: maxOrder + 1,
      createdAt: now,
      lastUpdate: now,
    ));
    await _fetch(emit);
  }

  Future<void> _onUpdate(
      ShoppingListUpdateItem e, Emitter<ShoppingListState> emit) async {
    await _repo.updateItem(e.item);
    await _fetch(emit);
  }

  Future<void> _onDelete(
      ShoppingListDeleteItem e, Emitter<ShoppingListState> emit) async {
    await _repo.deleteItem(e.itemId);
    await _fetch(emit);
  }

  Future<void> _onToggle(
      ShoppingListToggleItem e, Emitter<ShoppingListState> emit) async {
    final cur = state;
    if (cur is! ShoppingListLoaded) return;
    final item = cur.items.where((i) => i.id == e.itemId).firstOrNull;
    if (item == null) return;
    final newChecked = !item.isChecked;
    await _repo.updateItem(item.copyWith(
      isChecked: newChecked,
      checkedAt: newChecked ? DateTime.now() : null,
      clearCheckedAt: !newChecked,
    ));
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<ShoppingListState> emit) async {
    final list = _list;
    if (list == null) return;
    final (items, _) = await _repo.getItems(list.id);
    emit(ShoppingListLoaded(list: list, items: items));
  }
}
