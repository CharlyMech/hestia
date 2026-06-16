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

/// Remote peer changed lists/sessions — refetch in the background.
class ShoppingListsRemoteSync extends ShoppingListsEvent {
  const ShoppingListsRemoteSync();
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

  /// Item count per list id (templates + legacy sessions).
  final Map<String, int> itemCounts;

  /// Increments on every successful list fetch so pull-to-refresh can await completion.
  final int revision;
  const ShoppingListsLoaded(
    this.lists, {
    this.itemCounts = const {},
    this.revision = 0,
  });

  List<ShoppingList> get templates =>
      lists.where((l) => l.kind == ShoppingListKind.template).toList();

  /// Legacy finished sessions still stored as `shopping_lists(kind=session)`.
  /// New finished sessions live in `shopping_sessions` (not shown here yet).
  List<ShoppingList> get sessionHistory => lists
      .where((l) =>
          l.kind == ShoppingListKind.session &&
          l.status != ShoppingListStatus.active)
      .toList();

  List<ShoppingList> get history => sessionHistory;

  @override
  List<Object?> get props => [lists, itemCounts, revision];
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

  String? get householdId => _householdId;

  ShoppingListsBloc(this._repo) : super(const ShoppingListsInitial()) {
    on<ShoppingListsLoad>(_onLoad);
    on<ShoppingListsRefresh>(_onRefresh);
    on<ShoppingListsCreate>(_onCreate);
    on<ShoppingListsRemoteSync>(_onRemoteSync);
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
        _emitLoaded(emit, cur.lists, cur.itemCounts);
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

  Future<void> _onRemoteSync(
      ShoppingListsRemoteSync e, Emitter<ShoppingListsState> emit) async {
    if (_householdId == null || _userId == null) return;
    await _fetch(emit);
  }

  void _emitLoaded(
    Emitter<ShoppingListsState> emit,
    List<ShoppingList> lists,
    Map<String, int> counts,
  ) {
    _listRevision++;
    emit(ShoppingListsLoaded(
      List<ShoppingList>.from(lists),
      itemCounts: counts,
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
    final (counts, _) =
        await _repo.getListItemCounts(householdId: _householdId!);
    _emitLoaded(emit, lists, counts);
  }
}
