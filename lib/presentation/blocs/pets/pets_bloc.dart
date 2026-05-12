import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/pet.dart';
import 'package:hestia/domain/entities/pet_health_record.dart';
import 'package:hestia/domain/repositories/pet_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class PetsEvent extends Equatable {
  const PetsEvent();
  @override
  List<Object?> get props => const [];
}

class PetsLoad extends PetsEvent {
  final String householdId;
  const PetsLoad(this.householdId);
  @override
  List<Object?> get props => [householdId];
}

class PetsRefresh extends PetsEvent {
  const PetsRefresh();
}

class PetsCreate extends PetsEvent {
  final Pet pet;
  const PetsCreate(this.pet);
  @override
  List<Object?> get props => [pet];
}

class PetsUpdate extends PetsEvent {
  final Pet pet;
  const PetsUpdate(this.pet);
  @override
  List<Object?> get props => [pet];
}

class PetsDelete extends PetsEvent {
  final String id;
  const PetsDelete(this.id);
  @override
  List<Object?> get props => [id];
}

// ── Health record events ──────────────────────────────────────────────────────

class PetsLoadRecords extends PetsEvent {
  final String petId;
  const PetsLoadRecords(this.petId);
  @override
  List<Object?> get props => [petId];
}

class PetsCreateRecord extends PetsEvent {
  final PetHealthRecord record;
  const PetsCreateRecord(this.record);
  @override
  List<Object?> get props => [record];
}

class PetsUpdateRecord extends PetsEvent {
  final PetHealthRecord record;
  const PetsUpdateRecord(this.record);
  @override
  List<Object?> get props => [record];
}

class PetsDeleteRecord extends PetsEvent {
  final String id;
  final String petId;
  const PetsDeleteRecord(this.id, this.petId);
  @override
  List<Object?> get props => [id, petId];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class PetsState extends Equatable {
  const PetsState();
  @override
  List<Object?> get props => const [];
}

class PetsInitial extends PetsState {
  const PetsInitial();
}

class PetsLoading extends PetsState {
  const PetsLoading();
}

class PetsLoaded extends PetsState {
  final List<Pet> pets;

  /// Increments on every successful list fetch so pull-to-refresh can await completion.
  final int revision;
  const PetsLoaded(this.pets, {this.revision = 0});
  @override
  List<Object?> get props => [pets, revision];
}

class PetsError extends PetsState {
  final String message;
  const PetsError(this.message);
  @override
  List<Object?> get props => [message];
}

class PetsRecordsLoaded extends PetsState {
  final String petId;
  final List<PetHealthRecord> records;
  const PetsRecordsLoaded(this.petId, this.records);
  @override
  List<Object?> get props => [petId, records];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class PetsBloc extends Bloc<PetsEvent, PetsState> {
  final PetRepository _repo;
  String? _householdId;
  int _listRevision = 0;

  PetsBloc(this._repo) : super(const PetsInitial()) {
    on<PetsLoad>(_onLoad);
    on<PetsRefresh>(_onRefresh);
    on<PetsCreate>(_onCreate);
    on<PetsUpdate>(_onUpdate);
    on<PetsDelete>(_onDelete);
    on<PetsLoadRecords>(_onLoadRecords);
    on<PetsCreateRecord>(_onCreateRecord);
    on<PetsUpdateRecord>(_onUpdateRecord);
    on<PetsDeleteRecord>(_onDeleteRecord);
  }

  Future<void> _onLoad(PetsLoad e, Emitter<PetsState> emit) async {
    _householdId = e.householdId;
    emit(const PetsLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(PetsRefresh e, Emitter<PetsState> emit) async {
    if (_householdId == null) {
      final cur = state;
      if (cur is PetsLoaded) {
        _emitPetsLoaded(emit, cur.pets);
      }
      return;
    }
    await _fetch(emit);
  }

  Future<void> _onCreate(PetsCreate e, Emitter<PetsState> emit) async {
    final (_, failure) = await _repo.createPet(e.pet);
    if (failure != null) {
      emit(PetsError(failure.message));
      return;
    }
    await _fetch(emit);
  }

  Future<void> _onUpdate(PetsUpdate e, Emitter<PetsState> emit) async {
    final failure = await _repo.updatePet(e.pet);
    if (failure != null) {
      emit(PetsError(failure.message));
      return;
    }
    await _fetch(emit);
  }

  Future<void> _onDelete(PetsDelete e, Emitter<PetsState> emit) async {
    final failure = await _repo.deletePet(e.id);
    if (failure != null) {
      emit(PetsError(failure.message));
      return;
    }
    await _fetch(emit);
  }

  Future<void> _onLoadRecords(
      PetsLoadRecords e, Emitter<PetsState> emit) async {
    final (records, failure) = await _repo.getHealthRecords(e.petId);
    if (failure != null) {
      emit(PetsError(failure.message));
      return;
    }
    emit(PetsRecordsLoaded(e.petId, records));
  }

  Future<void> _onCreateRecord(
      PetsCreateRecord e, Emitter<PetsState> emit) async {
    final (_, failure) = await _repo.createHealthRecord(e.record);
    if (failure != null) {
      emit(PetsError(failure.message));
      return;
    }
    add(PetsLoadRecords(e.record.petId));
  }

  Future<void> _onUpdateRecord(
      PetsUpdateRecord e, Emitter<PetsState> emit) async {
    final failure = await _repo.updateHealthRecord(e.record);
    if (failure != null) {
      emit(PetsError(failure.message));
      return;
    }
    add(PetsLoadRecords(e.record.petId));
  }

  Future<void> _onDeleteRecord(
      PetsDeleteRecord e, Emitter<PetsState> emit) async {
    final failure = await _repo.deleteHealthRecord(e.id);
    if (failure != null) {
      emit(PetsError(failure.message));
      return;
    }
    add(PetsLoadRecords(e.petId));
  }

  void _emitPetsLoaded(Emitter<PetsState> emit, List<Pet> pets) {
    _listRevision++;
    emit(PetsLoaded(List<Pet>.from(pets), revision: _listRevision));
  }

  Future<void> _fetch(Emitter<PetsState> emit) async {
    if (_householdId == null) return;
    final (pets, failure) =
        await _repo.getPets(householdId: _householdId!, activeOnly: false);
    if (failure != null) {
      emit(PetsError(failure.message));
      return;
    }
    _emitPetsLoaded(emit, pets);
  }
}
