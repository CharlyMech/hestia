import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_session.dart';
import 'package:hestia/domain/repositories/shopping_session_repository.dart';

/// Index bloc for ACTIVE shopping sessions (the cart screen + the title badge).
///
/// Active sessions come from two channels: personal sessions live in the local
/// Drift DB (watched stream), shared sessions live in Supabase (realtime →
/// [ShoppingSessionsRemoteSync]). Both are merged by the repository.
abstract class ShoppingSessionsEvent extends Equatable {
  const ShoppingSessionsEvent();
  @override
  List<Object?> get props => const [];
}

class ShoppingSessionsLoad extends ShoppingSessionsEvent {
  final String householdId;
  final String userId;
  const ShoppingSessionsLoad({required this.householdId, required this.userId});
  @override
  List<Object?> get props => [householdId, userId];
}

class ShoppingSessionsRefresh extends ShoppingSessionsEvent {
  final int _nonce;
  ShoppingSessionsRefresh() : _nonce = DateTime.now().microsecondsSinceEpoch;
  @override
  List<Object?> get props => [_nonce];
}

class ShoppingSessionsStart extends ShoppingSessionsEvent {
  final String name;
  final ShoppingListScope scope;
  final String? bankAccountId;
  final String? transactionSourceId;
  final String? templateId;
  final List<String> sharedWithUserIds;
  const ShoppingSessionsStart({
    required this.name,
    required this.scope,
    this.bankAccountId,
    this.transactionSourceId,
    this.templateId,
    this.sharedWithUserIds = const [],
  });
  @override
  List<Object?> get props => [
        name,
        scope,
        bankAccountId,
        transactionSourceId,
        templateId,
        sharedWithUserIds,
      ];
}

/// Remote (shared) sessions changed — refetch.
class ShoppingSessionsRemoteSync extends ShoppingSessionsEvent {
  const ShoppingSessionsRemoteSync();
}

/// Local (personal) Drift stream ticked with a new active-session list.
class _ShoppingSessionsLocalTick extends ShoppingSessionsEvent {
  final List<ShoppingSession> local;
  const _ShoppingSessionsLocalTick(this.local);
  @override
  List<Object?> get props => [local];
}

abstract class ShoppingSessionsState extends Equatable {
  const ShoppingSessionsState();
  @override
  List<Object?> get props => const [];
}

class ShoppingSessionsInitial extends ShoppingSessionsState {
  const ShoppingSessionsInitial();
}

class ShoppingSessionsLoading extends ShoppingSessionsState {
  const ShoppingSessionsLoading();
}

class ShoppingSessionsLoaded extends ShoppingSessionsState {
  final List<ShoppingSession> active;
  final int revision;
  const ShoppingSessionsLoaded(this.active, {this.revision = 0});

  int get activeCount => active.length;

  @override
  List<Object?> get props => [active, revision];
}

class ShoppingSessionsError extends ShoppingSessionsState {
  final String message;
  const ShoppingSessionsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ShoppingSessionsBloc
    extends Bloc<ShoppingSessionsEvent, ShoppingSessionsState> {
  final ShoppingSessionRepository _repo;
  String? _householdId;
  String? _userId;
  int _revision = 0;
  StreamSubscription<List<ShoppingSession>>? _localSub;

  String? get householdId => _householdId;

  ShoppingSessionsBloc(this._repo) : super(const ShoppingSessionsInitial()) {
    on<ShoppingSessionsLoad>(_onLoad);
    on<ShoppingSessionsRefresh>(_onRefresh);
    on<ShoppingSessionsStart>(_onStart);
    on<ShoppingSessionsRemoteSync>(_onRemoteSync);
    on<_ShoppingSessionsLocalTick>(_onLocalTick);
  }

  Future<void> _onLoad(
      ShoppingSessionsLoad e, Emitter<ShoppingSessionsState> emit) async {
    _householdId = e.householdId;
    _userId = e.userId;
    emit(const ShoppingSessionsLoading());
    _localSub ??= _repo.watchLocalActiveSessions().listen(
          (local) => add(_ShoppingSessionsLocalTick(local)),
        );
    await _fetch(emit);
  }

  Future<void> _onRefresh(
      ShoppingSessionsRefresh e, Emitter<ShoppingSessionsState> emit) async {
    if (_householdId == null) return;
    await _fetch(emit);
  }

  Future<void> _onRemoteSync(
      ShoppingSessionsRemoteSync e, Emitter<ShoppingSessionsState> emit) async {
    if (_householdId == null) return;
    await _fetch(emit);
  }

  /// A Drift change occurred — refetch the merged view (cheap; local read +
  /// one remote query). Keeps personal + shared in sync from one path.
  Future<void> _onLocalTick(
      _ShoppingSessionsLocalTick e, Emitter<ShoppingSessionsState> emit) async {
    if (_householdId == null) return;
    await _fetch(emit);
  }

  Future<void> _onStart(
      ShoppingSessionsStart e, Emitter<ShoppingSessionsState> emit) async {
    if (_householdId == null || _userId == null) return;
    await _repo.startSession(
      householdId: _householdId!,
      userId: _userId!,
      name: e.name,
      scope: e.scope,
      bankAccountId: e.bankAccountId,
      transactionSourceId: e.transactionSourceId,
      templateId: e.templateId,
      sharedWithUserIds: e.sharedWithUserIds,
    );
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<ShoppingSessionsState> emit) async {
    final (sessions, failure) = await _repo.getActiveSessions(
      householdId: _householdId!,
      userId: _userId!,
    );
    if (failure != null) {
      emit(ShoppingSessionsError(failure.message));
      return;
    }
    _revision++;
    emit(ShoppingSessionsLoaded(sessions, revision: _revision));
  }

  @override
  Future<void> close() {
    _localSub?.cancel();
    return super.close();
  }
}
