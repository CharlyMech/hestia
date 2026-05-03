import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/domain/entities/money_source.dart';
import 'package:hestia/domain/repositories/money_source_repository.dart';

abstract class MoneySourcesEvent extends Equatable {
  const MoneySourcesEvent();
  @override
  List<Object?> get props => const [];
}

class MoneySourcesLoad extends MoneySourcesEvent {
  final String householdId;
  final String userId;
  const MoneySourcesLoad({required this.householdId, required this.userId});
  @override
  List<Object?> get props => [householdId, userId];
}

class MoneySourcesRefresh extends MoneySourcesEvent {
  const MoneySourcesRefresh();
}

abstract class MoneySourcesState extends Equatable {
  const MoneySourcesState();
  @override
  List<Object?> get props => const [];
}

class MoneySourcesInitial extends MoneySourcesState {
  const MoneySourcesInitial();
}

class MoneySourcesLoading extends MoneySourcesState {
  const MoneySourcesLoading();
}

class MoneySourcesLoaded extends MoneySourcesState {
  final List<MoneySource> sources;
  const MoneySourcesLoaded(this.sources);
  @override
  List<Object?> get props => [sources];

  /// Total balance across all loaded sources, in the source's own currency.
  /// Caller is responsible for currency conversion if mixed.
  double get totalBalance =>
      sources.fold(0, (sum, s) => sum + s.currentBalance);

  List<MoneySource> get shared =>
      sources.where((s) => s.ownerType == OwnerType.shared).toList();
  List<MoneySource> get personal =>
      sources.where((s) => s.ownerType == OwnerType.personal).toList();
}

class MoneySourcesError extends MoneySourcesState {
  final String message;
  const MoneySourcesError(this.message);
  @override
  List<Object?> get props => [message];
}

class MoneySourcesBloc extends Bloc<MoneySourcesEvent, MoneySourcesState> {
  final MoneySourceRepository _repo;
  String? _householdId;
  String? _userId;

  MoneySourcesBloc(this._repo) : super(const MoneySourcesInitial()) {
    on<MoneySourcesLoad>(_onLoad);
    on<MoneySourcesRefresh>(_onRefresh);
  }

  Future<void> _onLoad(
      MoneySourcesLoad e, Emitter<MoneySourcesState> emit) async {
    _householdId = e.householdId;
    _userId = e.userId;
    emit(const MoneySourcesLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(
      MoneySourcesRefresh e, Emitter<MoneySourcesState> emit) async {
    if (_householdId == null || _userId == null) return;
    emit(const MoneySourcesLoading());
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<MoneySourcesState> emit) async {
    final (sources, failure) = await _repo.getMoneySources(
      householdId: _householdId!,
      viewMode: ViewMode.household,
      userId: _userId,
    );
    if (failure != null) {
      emit(MoneySourcesError(failure.message));
      return;
    }
    emit(MoneySourcesLoaded(sources));
  }
}
