import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/car_maintenance_record.dart';
import 'package:hestia/domain/repositories/car_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class CarMaintenanceEvent extends Equatable {
  const CarMaintenanceEvent();
  @override
  List<Object?> get props => const [];
}

class CarMaintenanceLoad extends CarMaintenanceEvent {
  final String carId;
  const CarMaintenanceLoad(this.carId);
  @override
  List<Object?> get props => [carId];
}

class CarMaintenanceRefresh extends CarMaintenanceEvent {
  const CarMaintenanceRefresh();
}

class CarMaintenanceCreate extends CarMaintenanceEvent {
  final CarMaintenanceRecord record;
  final Map<String, dynamic>? transaction;
  const CarMaintenanceCreate(this.record, {this.transaction});
  @override
  List<Object?> get props => [record, transaction];
}

class CarMaintenanceUpdate extends CarMaintenanceEvent {
  final CarMaintenanceRecord record;
  const CarMaintenanceUpdate(this.record);
  @override
  List<Object?> get props => [record];
}

class CarMaintenanceDelete extends CarMaintenanceEvent {
  final String id;
  const CarMaintenanceDelete(this.id);
  @override
  List<Object?> get props => [id];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class CarMaintenanceState extends Equatable {
  const CarMaintenanceState();
  @override
  List<Object?> get props => const [];
}

class CarMaintenanceInitial extends CarMaintenanceState {
  const CarMaintenanceInitial();
}

class CarMaintenanceLoading extends CarMaintenanceState {
  const CarMaintenanceLoading();
}

class CarMaintenanceLoaded extends CarMaintenanceState {
  final List<CarMaintenanceRecord> records;
  const CarMaintenanceLoaded(this.records);
  @override
  List<Object?> get props => [records];
}

class CarMaintenanceSaved extends CarMaintenanceState {
  const CarMaintenanceSaved();
}

class CarMaintenanceDeleted extends CarMaintenanceState {
  const CarMaintenanceDeleted();
}

class CarMaintenanceError extends CarMaintenanceState {
  final String message;
  const CarMaintenanceError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class CarMaintenanceBloc
    extends Bloc<CarMaintenanceEvent, CarMaintenanceState> {
  final CarRepository _repo;
  String? _carId;

  CarMaintenanceBloc(this._repo) : super(const CarMaintenanceInitial()) {
    on<CarMaintenanceLoad>(_onLoad);
    on<CarMaintenanceRefresh>(_onRefresh);
    on<CarMaintenanceCreate>(_onCreate);
    on<CarMaintenanceUpdate>(_onUpdate);
    on<CarMaintenanceDelete>(_onDelete);
  }

  Future<void> _onLoad(
      CarMaintenanceLoad e, Emitter<CarMaintenanceState> emit) async {
    _carId = e.carId;
    emit(const CarMaintenanceLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(
      CarMaintenanceRefresh e, Emitter<CarMaintenanceState> emit) async {
    await _fetch(emit);
  }

  Future<void> _onCreate(
      CarMaintenanceCreate e, Emitter<CarMaintenanceState> emit) async {
    emit(const CarMaintenanceLoading());
    final failure = await _repo.createMaintenanceRecord(e.record,
        transaction: e.transaction);
    if (failure != null) {
      emit(CarMaintenanceError(failure.message));
      return;
    }
    emit(const CarMaintenanceSaved());
    await _fetch(emit);
  }

  Future<void> _onUpdate(
      CarMaintenanceUpdate e, Emitter<CarMaintenanceState> emit) async {
    emit(const CarMaintenanceLoading());
    final failure = await _repo.updateMaintenanceRecord(e.record);
    if (failure != null) {
      emit(CarMaintenanceError(failure.message));
      return;
    }
    emit(const CarMaintenanceSaved());
    await _fetch(emit);
  }

  Future<void> _onDelete(
      CarMaintenanceDelete e, Emitter<CarMaintenanceState> emit) async {
    emit(const CarMaintenanceLoading());
    final failure = await _repo.deleteMaintenanceRecord(e.id);
    if (failure != null) {
      emit(CarMaintenanceError(failure.message));
      return;
    }
    emit(const CarMaintenanceDeleted());
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<CarMaintenanceState> emit) async {
    final id = _carId;
    if (id == null) return;
    final (records, failure) = await _repo.getMaintenanceRecords(id);
    if (failure != null) {
      emit(CarMaintenanceError(failure.message));
      return;
    }
    emit(CarMaintenanceLoaded(records));
  }
}
