import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/car.dart';
import 'package:hestia/domain/repositories/car_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class CarDetailEvent extends Equatable {
  const CarDetailEvent();
  @override
  List<Object?> get props => const [];
}

class CarDetailLoad extends CarDetailEvent {
  final String carId;
  const CarDetailLoad(this.carId);
  @override
  List<Object?> get props => [carId];
}

class CarDetailRefresh extends CarDetailEvent {
  const CarDetailRefresh();
}

class CarDetailToggleActive extends CarDetailEvent {
  const CarDetailToggleActive();
}

class CarDetailDelete extends CarDetailEvent {
  const CarDetailDelete();
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class CarDetailState extends Equatable {
  const CarDetailState();
  @override
  List<Object?> get props => const [];
}

class CarDetailInitial extends CarDetailState {
  const CarDetailInitial();
}

class CarDetailLoading extends CarDetailState {
  const CarDetailLoading();
}

class CarDetailLoaded extends CarDetailState {
  final Car car;
  const CarDetailLoaded(this.car);
  @override
  List<Object?> get props => [car];
}

class CarDetailNotFound extends CarDetailState {
  const CarDetailNotFound();
}

class CarDetailDeleted extends CarDetailState {
  const CarDetailDeleted();
}

class CarDetailError extends CarDetailState {
  final String message;
  const CarDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class CarDetailBloc extends Bloc<CarDetailEvent, CarDetailState> {
  final CarRepository _repo;
  String? _carId;

  CarDetailBloc(this._repo) : super(const CarDetailInitial()) {
    on<CarDetailLoad>(_onLoad);
    on<CarDetailRefresh>(_onRefresh);
    on<CarDetailToggleActive>(_onToggleActive);
    on<CarDetailDelete>(_onDelete);
  }

  Future<void> _onLoad(CarDetailLoad e, Emitter<CarDetailState> emit) async {
    _carId = e.carId;
    emit(const CarDetailLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(
      CarDetailRefresh e, Emitter<CarDetailState> emit) async {
    await _fetch(emit);
  }

  Future<void> _onToggleActive(
      CarDetailToggleActive e, Emitter<CarDetailState> emit) async {
    final cur = state;
    if (cur is! CarDetailLoaded) return;
    final updated = cur.car.copyWith(isActive: !cur.car.isActive);
    final failure = await _repo.updateCar(updated);
    if (failure != null) {
      emit(CarDetailError(failure.message));
      emit(cur);
      return;
    }
    emit(CarDetailLoaded(updated));
  }

  Future<void> _onDelete(
      CarDetailDelete e, Emitter<CarDetailState> emit) async {
    final id = _carId;
    if (id == null) return;
    final failure = await _repo.deleteCar(id);
    if (failure != null) {
      emit(CarDetailError(failure.message));
      return;
    }
    emit(const CarDetailDeleted());
  }

  Future<void> _fetch(Emitter<CarDetailState> emit) async {
    final id = _carId;
    if (id == null) return;
    final (car, failure) = await _repo.getCar(id);
    if (failure != null) {
      emit(CarDetailError(failure.message));
      return;
    }
    if (car == null) {
      emit(const CarDetailNotFound());
      return;
    }
    emit(CarDetailLoaded(car));
  }
}
