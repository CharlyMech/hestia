import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/car.dart';
import 'package:hestia/domain/repositories/car_repository.dart';

abstract class CarsEvent extends Equatable {
  const CarsEvent();
  @override
  List<Object?> get props => const [];
}

class CarsLoad extends CarsEvent {
  final String householdId;
  const CarsLoad(this.householdId);
  @override
  List<Object?> get props => [householdId];
}

class CarsRefresh extends CarsEvent {
  const CarsRefresh();
}

class CarsCreate extends CarsEvent {
  final Car car;
  final List<String> memberIds;
  const CarsCreate(this.car, this.memberIds);
  @override
  List<Object?> get props => [car, memberIds];
}

class CarsUpdate extends CarsEvent {
  final Car car;
  const CarsUpdate(this.car);
  @override
  List<Object?> get props => [car];
}

class CarsDelete extends CarsEvent {
  final String id;
  const CarsDelete(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class CarsState extends Equatable {
  const CarsState();
  @override
  List<Object?> get props => const [];
}

class CarsInitial extends CarsState {
  const CarsInitial();
}

class CarsLoading extends CarsState {
  const CarsLoading();
}

class CarsLoaded extends CarsState {
  final List<Car> cars;

  /// Increments on every successful list fetch so pull-to-refresh can await completion.
  final int revision;
  const CarsLoaded(this.cars, {this.revision = 0});
  @override
  List<Object?> get props => [cars, revision];
}

class CarsError extends CarsState {
  final String message;
  const CarsError(this.message);
  @override
  List<Object?> get props => [message];
}

class CarsBloc extends Bloc<CarsEvent, CarsState> {
  final CarRepository _repo;
  String? _householdId;
  int _listRevision = 0;

  CarsBloc(this._repo) : super(const CarsInitial()) {
    on<CarsLoad>(_onLoad);
    on<CarsRefresh>(_onRefresh);
    on<CarsCreate>(_onCreate);
    on<CarsUpdate>(_onUpdate);
    on<CarsDelete>(_onDelete);
  }

  Future<void> _onLoad(CarsLoad e, Emitter<CarsState> emit) async {
    _householdId = e.householdId;
    emit(const CarsLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(CarsRefresh e, Emitter<CarsState> emit) async {
    if (_householdId == null) {
      final cur = state;
      if (cur is CarsLoaded) {
        _emitCarsLoaded(emit, cur.cars);
      }
      return;
    }
    await _fetch(emit);
  }

  Future<void> _onCreate(CarsCreate e, Emitter<CarsState> emit) async {
    final (_, failure) =
        await _repo.createCar(e.car, memberUserIds: e.memberIds);
    if (failure != null) {
      emit(CarsError(failure.message));
      return;
    }
    await _fetch(emit);
  }

  Future<void> _onUpdate(CarsUpdate e, Emitter<CarsState> emit) async {
    final failure = await _repo.updateCar(e.car);
    if (failure != null) {
      emit(CarsError(failure.message));
      return;
    }
    await _fetch(emit);
  }

  Future<void> _onDelete(CarsDelete e, Emitter<CarsState> emit) async {
    final failure = await _repo.deleteCar(e.id);
    if (failure != null) {
      emit(CarsError(failure.message));
      return;
    }
    await _fetch(emit);
  }

  void _emitCarsLoaded(Emitter<CarsState> emit, List<Car> cars) {
    _listRevision++;
    emit(CarsLoaded(List<Car>.from(cars), revision: _listRevision));
  }

  Future<void> _fetch(Emitter<CarsState> emit) async {
    if (_householdId == null) return;
    final (cars, failure) =
        await _repo.getCars(householdId: _householdId!, activeOnly: false);
    if (failure != null) {
      emit(CarsError(failure.message));
      return;
    }
    _emitCarsLoaded(emit, cars);
  }
}
