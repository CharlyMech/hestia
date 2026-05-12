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

class ShoppingListsStartSession extends ShoppingListsEvent {
  final String name;
  final ShoppingListScope scope;
  final String? bankAccountId;
  final String? transactionSourceId;
  final String? templateListId;

  const ShoppingListsStartSession({
    required this.name,
    required this.scope,
    this.bankAccountId,
    this.transactionSourceId,
    this.templateListId,
  });

  @override
  List<Object?> get props =>
      [name, scope, bankAccountId, transactionSourceId, templateListId];
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

  /// Increments on every successful list fetch so pull-to-refresh can await completion.
  final int revision;
  const ShoppingListsLoaded(this.lists, {this.revision = 0});

  List<ShoppingList> get activeSessions => lists
      .where((l) =>
          l.kind == ShoppingListKind.session &&
          l.status == ShoppingListStatus.active)
      .toList();

  List<ShoppingList> get templates =>
      lists.where((l) => l.kind == ShoppingListKind.template).toList();

  List<ShoppingList> get sessionHistory => lists
      .where((l) =>
          l.kind == ShoppingListKind.session &&
          l.status != ShoppingListStatus.active)
      .toList();

  /// Backwards-compatible names.
  List<ShoppingList> get active => activeSessions;
  List<ShoppingList> get history => sessionHistory;

  @override
  List<Object?> get props => [lists, revision];
}

class ShoppingListsError extends ShoppingListsState {
  final String message;
  const ShoppingListsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ShoppingListsBloc extends Bloc<ShoppingListsEvent, ShoppingListsState> {
  final ShoppingRepository _repo;
  String? _householdId;
  String? _userId;
  int _listRevision = 0;

  ShoppingListsBloc(this._repo) : super(const ShoppingListsInitial()) {
    on<ShoppingListsLoad>(_onLoad);
    on<ShoppingListsRefresh>(_onRefresh);
    on<ShoppingListsCreate>(_onCreate);
    on<ShoppingListsStartSession>(_onStartSession);
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
    if (_householdId == null || _userId == null) {
      final cur = state;
      if (cur is ShoppingListsLoaded) {
        _emitLoaded(emit, cur.lists);
      }
      return;
    }
    await _fetch(emit);
  }

  Future<void> _onCreate(
      ShoppingListsCreate e, Emitter<ShoppingListsState> emit) async {
    await _repo.createList(e.list);
    await _fetch(emit);
  }

  Future<void> _onStartSession(
      ShoppingListsStartSession e, Emitter<ShoppingListsState> emit) async {
    if (_householdId == null || _userId == null) return;
    await _repo.startShoppingSession(
      householdId: _householdId!,
      userId: _userId!,
      name: e.name,
      scope: e.scope,
      bankAccountId: e.bankAccountId,
      transactionSourceId: e.transactionSourceId,
      templateListId: e.templateListId,
    );
    await _fetch(emit);
  }

  Future<void> _onCancel(
      ShoppingListsCancel e, Emitter<ShoppingListsState> emit) async {
    final cur = state;
    if (cur is! ShoppingListsLoaded) return;
    final l = cur.lists.where((x) => x.id == e.listId).firstOrNull;
    if (l == null) return;
    await _repo.updateList(l.copyWith(
      status: ShoppingListStatus.cancelled,
      sessionEndedAt: DateTime.now(),
    ));
    await _fetch(emit);
  }

  Future<void> _onMarkPaid(
      ShoppingListsMarkPaid e, Emitter<ShoppingListsState> emit) async {
    final cur = state;
    if (cur is! ShoppingListsLoaded) return;
    final l = cur.lists.where((x) => x.id == e.listId).firstOrNull;
    if (l == null) return;
    final now = DateTime.now();
    await _repo.updateList(l.copyWith(
      status: ShoppingListStatus.paid,
      transactionId: e.transactionId,
      paidAt: now,
      sessionEndedAt: now,
    ));
    await _fetch(emit);
  }

  void _emitLoaded(Emitter<ShoppingListsState> emit, List<ShoppingList> lists) {
    _listRevision++;
    emit(ShoppingListsLoaded(
      List<ShoppingList>.from(lists),
      revision: _listRevision,
    ));
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
    _emitLoaded(emit, lists);
  }
}
