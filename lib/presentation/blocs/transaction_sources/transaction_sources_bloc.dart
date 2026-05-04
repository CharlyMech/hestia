import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/domain/repositories/transaction_source_repository.dart';

abstract class TransactionSourcesEvent extends Equatable {
  const TransactionSourcesEvent();
  @override
  List<Object?> get props => const [];
}

class TransactionSourcesLoad extends TransactionSourcesEvent {
  final String householdId;
  const TransactionSourcesLoad({required this.householdId});
  @override
  List<Object?> get props => [householdId];
}

class TransactionSourcesRefresh extends TransactionSourcesEvent {
  final int _nonce;
  TransactionSourcesRefresh()
      : _nonce = DateTime.now().microsecondsSinceEpoch;
  @override
  List<Object?> get props => [_nonce];
}

class TransactionSourcesCreate extends TransactionSourcesEvent {
  final TransactionSource source;
  const TransactionSourcesCreate(this.source);
  @override
  List<Object?> get props => [source];
}

class TransactionSourcesUpdate extends TransactionSourcesEvent {
  final TransactionSource source;
  const TransactionSourcesUpdate(this.source);
  @override
  List<Object?> get props => [source];
}

class TransactionSourcesDelete extends TransactionSourcesEvent {
  final String id;
  const TransactionSourcesDelete(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class TransactionSourcesState extends Equatable {
  const TransactionSourcesState();
  @override
  List<Object?> get props => const [];
}

class TransactionSourcesInitial extends TransactionSourcesState {
  const TransactionSourcesInitial();
}

class TransactionSourcesLoading extends TransactionSourcesState {
  const TransactionSourcesLoading();
}

class TransactionSourcesLoaded extends TransactionSourcesState {
  final List<TransactionSource> sources;
  const TransactionSourcesLoaded(this.sources);
  @override
  List<Object?> get props => [sources];
}

class TransactionSourcesError extends TransactionSourcesState {
  final String message;
  const TransactionSourcesError(this.message);
  @override
  List<Object?> get props => [message];
}

class TransactionSourcesBloc
    extends Bloc<TransactionSourcesEvent, TransactionSourcesState> {
  final TransactionSourceRepository _repo;
  String? _householdId;

  TransactionSourcesBloc(this._repo) : super(const TransactionSourcesInitial()) {
    on<TransactionSourcesLoad>(_onLoad);
    on<TransactionSourcesRefresh>(_onRefresh);
    on<TransactionSourcesCreate>(_onCreate);
    on<TransactionSourcesUpdate>(_onUpdate);
    on<TransactionSourcesDelete>(_onDelete);
  }

  Future<void> _onLoad(
      TransactionSourcesLoad e, Emitter<TransactionSourcesState> emit) async {
    _householdId = e.householdId;
    emit(const TransactionSourcesLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(TransactionSourcesRefresh e,
      Emitter<TransactionSourcesState> emit) async {
    if (_householdId == null) return;
    emit(const TransactionSourcesLoading());
    await _fetch(emit);
  }

  Future<void> _onCreate(TransactionSourcesCreate e,
      Emitter<TransactionSourcesState> emit) async {
    await _repo.create(e.source);
    await _fetch(emit);
  }

  Future<void> _onUpdate(TransactionSourcesUpdate e,
      Emitter<TransactionSourcesState> emit) async {
    await _repo.update(e.source);
    await _fetch(emit);
  }

  Future<void> _onDelete(TransactionSourcesDelete e,
      Emitter<TransactionSourcesState> emit) async {
    await _repo.delete(e.id);
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<TransactionSourcesState> emit) async {
    final (list, failure) = await _repo.getAll(householdId: _householdId!);
    if (failure != null) {
      emit(TransactionSourcesError(failure.message));
      return;
    }
    emit(TransactionSourcesLoaded(list));
  }
}
