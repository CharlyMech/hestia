import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';
import 'package:hestia/domain/entities/shopping_session.dart';
import 'package:hestia/domain/entities/shopping_session_item.dart';
import 'package:hestia/domain/repositories/shopping_repository.dart';
import 'package:hestia/domain/repositories/shopping_session_repository.dart';

/// Bloc for a single shopping list — items CRUD + check toggle. Pairs with
/// the detail screen.
///
/// Dual-mode: edits a TEMPLATE (`shopping_lists` via [ShoppingRepository]) or a
/// SESSION (`shopping_sessions`/local Drift via [ShoppingSessionRepository]).
/// In session mode the session is mapped to a [ShoppingList] and its items to
/// [ShoppingListItem]s so [ShoppingListLoaded] — and the screen — stay identical.
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

/// Load in SESSION mode — edits route through the session repository.
class ShoppingListLoadSession extends ShoppingListEvent {
  final ShoppingSession session;
  const ShoppingListLoadSession(this.session);
  @override
  List<Object?> get props => [session];
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

/// Drag-to-reorder: move the item at [oldIndex] to [newIndex] and persist the
/// new `sort_order` for the whole list.
class ShoppingListReorder extends ShoppingListEvent {
  final int oldIndex;
  final int newIndex;
  const ShoppingListReorder({required this.oldIndex, required this.newIndex});
  @override
  List<Object?> get props => [oldIndex, newIndex];
}

/// Remote peer changed items — refetch without a full-screen loading state.
class ShoppingListRemoteSync extends ShoppingListEvent {
  const ShoppingListRemoteSync();
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
  final ShoppingSessionRepository? _sessionRepo;

  ShoppingList? _list;

  /// Set when in session mode. Items map to [ShoppingListItem] for the UI.
  ShoppingSession? _session;
  bool get _isSession => _session != null;

  ShoppingListBloc(this._repo, {ShoppingSessionRepository? sessionRepo})
      : _sessionRepo = sessionRepo,
        super(const ShoppingListInitial()) {
    on<ShoppingListLoad>(_onLoad);
    on<ShoppingListLoadSession>(_onLoadSession);
    on<ShoppingListAddItem>(_onAdd);
    on<ShoppingListUpdateItem>(_onUpdate);
    on<ShoppingListDeleteItem>(_onDelete);
    on<ShoppingListToggleItem>(_onToggle);
    on<ShoppingListReorder>(_onReorder);
    on<ShoppingListRemoteSync>(_onRemoteSync);
  }

  Future<void> _onLoad(
      ShoppingListLoad e, Emitter<ShoppingListState> emit) async {
    _list = e.list;
    _session = null;
    emit(const ShoppingListLoading());
    await _fetch(emit);
  }

  Future<void> _onLoadSession(
      ShoppingListLoadSession e, Emitter<ShoppingListState> emit) async {
    _session = e.session;
    _list = e.session.toShoppingList();
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
    final name = e.name.trim();
    if (_isSession) {
      await _sessionRepo!.addItem(
        ShoppingSessionItem(
          id: '',
          sessionId: _session!.id,
          name: name,
          qty: e.qty,
          sortOrder: maxOrder + 1,
          createdAt: now,
          lastUpdate: now,
        ),
        scope: _session!.scope,
      );
    } else {
      await _repo.createItem(ShoppingListItem(
        id: '',
        listId: list.id,
        name: name,
        qty: e.qty,
        sortOrder: maxOrder + 1,
        createdAt: now,
        lastUpdate: now,
      ));
    }
    await _fetch(emit);
  }

  Future<void> _onUpdate(
      ShoppingListUpdateItem e, Emitter<ShoppingListState> emit) async {
    if (_isSession) {
      await _sessionRepo!.updateItem(
        ShoppingSessionItem.fromShoppingListItem(e.item,
            sessionId: _session!.id),
        scope: _session!.scope,
      );
    } else {
      await _repo.updateItem(e.item);
    }
    await _fetch(emit);
  }

  Future<void> _onDelete(
      ShoppingListDeleteItem e, Emitter<ShoppingListState> emit) async {
    if (_isSession) {
      await _sessionRepo!.deleteItem(
        itemId: e.itemId,
        sessionId: _session!.id,
        scope: _session!.scope,
      );
    } else {
      await _repo.deleteItem(e.itemId);
    }
    await _fetch(emit);
  }

  Future<void> _onReorder(
      ShoppingListReorder e, Emitter<ShoppingListState> emit) async {
    final cur = state;
    if (cur is! ShoppingListLoaded) return;
    final items = List<ShoppingListItem>.from(cur.items);
    if (e.oldIndex < 0 || e.oldIndex >= items.length) return;
    var newIndex = e.newIndex;
    if (newIndex > e.oldIndex) newIndex -= 1;
    final moved = items.removeAt(e.oldIndex);
    items.insert(newIndex.clamp(0, items.length), moved);

    // Optimistic: reflect the new order immediately with refreshed sortOrder.
    final reordered = <ShoppingListItem>[
      for (var i = 0; i < items.length; i++) items[i].copyWith(sortOrder: i),
    ];
    emit(ShoppingListLoaded(list: cur.list, items: reordered));

    final ids = reordered.map((i) => i.id).toList();
    if (_isSession) {
      await _sessionRepo!.reorderItems(
        sessionId: _session!.id,
        orderedItemIds: ids,
        scope: _session!.scope,
      );
    } else {
      await _repo.reorderItems(ids);
    }
    await _fetch(emit);
  }

  Future<void> _onRemoteSync(
      ShoppingListRemoteSync e, Emitter<ShoppingListState> emit) async {
    if (_list == null) return;
    await _fetch(emit);
  }

  Future<void> _onToggle(
      ShoppingListToggleItem e, Emitter<ShoppingListState> emit) async {
    final cur = state;
    if (cur is! ShoppingListLoaded) return;
    final item = cur.items.where((i) => i.id == e.itemId).firstOrNull;
    if (item == null) return;
    final newChecked = !item.isChecked;
    final toggled = item.copyWith(
      isChecked: newChecked,
      checkedAt: newChecked ? DateTime.now() : null,
      clearCheckedAt: !newChecked,
    );
    if (_isSession) {
      await _sessionRepo!.updateItem(
        ShoppingSessionItem.fromShoppingListItem(toggled,
            sessionId: _session!.id),
        scope: _session!.scope,
      );
    } else {
      await _repo.updateItem(toggled);
    }
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<ShoppingListState> emit) async {
    final list = _list;
    if (list == null) return;
    if (_isSession) {
      final (items, _) = await _sessionRepo!.getItems(
        sessionId: _session!.id,
        scope: _session!.scope,
      );
      emit(ShoppingListLoaded(
        list: list,
        items: items.map((i) => i.toShoppingListItem(listId: list.id)).toList(),
      ));
    } else {
      final (items, _) = await _repo.getItems(list.id);
      emit(ShoppingListLoaded(list: list, items: items));
    }
  }
}
