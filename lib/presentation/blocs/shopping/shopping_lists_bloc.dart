import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/repositories/shopping_repository.dart';

/// Bloc for the index screen — list of shopping lists with Active/History
/// segmentation. Detail-level edits (items, check, finish) live in
/// `ShoppingListBloc`.
abstract class ShoppingListsEvent extends Equatable {
  const ShoppingListsEvent();
  @override
  List<Object?> get props => const [];
}

class ShoppingListsLoad extends ShoppingListsEvent {
  final String householdId;
  final String userId;
  const ShoppingListsLoad({required this.householdId, required this.userId});
  @override
  List<Object?> get props => [householdId, userId];
}

class ShoppingListsRefresh extends ShoppingListsEvent {
  final int _nonce;
  ShoppingListsRefresh() : _nonce = DateTime.now().microsecondsSinceEpoch;
  @override
  List<Object?> get props => [_nonce];
}

class ShoppingListsCreate extends ShoppingListsEvent {
  final ShoppingList list;
  const ShoppingListsCreate(this.list);
  @override
  List<Object?> get props => [list];
}

class ShoppingListsCancel extends ShoppingListsEvent {
  final String listId;
  const ShoppingListsCancel(this.listId);
  @override
  List<Object?> get props => [listId];
}

class ShoppingListsMarkPaid extends ShoppingListsEvent {
  final String listId;
  final String transactionId;
  const ShoppingListsMarkPaid(
      {required this.listId, required this.transactionId});
  @override
  List<Object?> get props => [listId, transactionId];
}

abstract class ShoppingListsState extends Equatable {
  const ShoppingListsState();
  @override
  List<Object?> get props => const [];
}

class ShoppingListsInitial extends ShoppingListsState {
  const ShoppingListsInitial();
}

class ShoppingListsLoading extends ShoppingListsState {
  const ShoppingListsLoading();
}

class ShoppingListsLoaded extends ShoppingListsState {
  final List<ShoppingList> lists;
  const ShoppingListsLoaded(this.lists);

  List<ShoppingList> get active =>
      lists.where((l) => l.status == ShoppingListStatus.active).toList();
  List<ShoppingList> get history => lists
      .where((l) => l.status != ShoppingListStatus.active)
      .toList();

  @override
  List<Object?> get props => [lists];
}

class ShoppingListsError extends ShoppingListsState {
  final String message;
  const ShoppingListsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ShoppingListsBloc
    extends Bloc<ShoppingListsEvent, ShoppingListsState> {
  final ShoppingRepository _repo;
  String? _householdId;
  String? _userId;

  ShoppingListsBloc(this._repo) : super(const ShoppingListsInitial()) {
    on<ShoppingListsLoad>(_onLoad);
    on<ShoppingListsRefresh>(_onRefresh);
    on<ShoppingListsCreate>(_onCreate);
    on<ShoppingListsCancel>(_onCancel);
    on<ShoppingListsMarkPaid>(_onMarkPaid);
  }

  Future<void> _onLoad(
      ShoppingListsLoad e, Emitter<ShoppingListsState> emit) async {
    _householdId = e.householdId;
    _userId = e.userId;
    emit(const ShoppingListsLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(
      ShoppingListsRefresh e, Emitter<ShoppingListsState> emit) async {
    if (_householdId == null) return;
    emit(const ShoppingListsLoading());
    await _fetch(emit);
  }

  Future<void> _onCreate(
      ShoppingListsCreate e, Emitter<ShoppingListsState> emit) async {
    await _repo.createList(e.list);
    await _fetch(emit);
  }

  Future<void> _onCancel(
      ShoppingListsCancel e, Emitter<ShoppingListsState> emit) async {
    final cur = state;
    if (cur is! ShoppingListsLoaded) return;
    final l = cur.lists.where((x) => x.id == e.listId).firstOrNull;
    if (l == null) return;
    await _repo.updateList(l.copyWith(status: ShoppingListStatus.cancelled));
    await _fetch(emit);
  }

  Future<void> _onMarkPaid(
      ShoppingListsMarkPaid e, Emitter<ShoppingListsState> emit) async {
    final cur = state;
    if (cur is! ShoppingListsLoaded) return;
    final l = cur.lists.where((x) => x.id == e.listId).firstOrNull;
    if (l == null) return;
    await _repo.updateList(l.copyWith(
      status: ShoppingListStatus.paid,
      transactionId: e.transactionId,
      paidAt: DateTime.now(),
    ));
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<ShoppingListsState> emit) async {
    final (lists, failure) = await _repo.getLists(
      householdId: _householdId!,
      userId: _userId!,
    );
    if (failure != null) {
      emit(ShoppingListsError(failure.message));
      return;
    }
    emit(ShoppingListsLoaded(lists));
  }
}
