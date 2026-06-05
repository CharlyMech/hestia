import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/pet.dart';
import 'package:hestia/domain/entities/pet_health_record.dart';
import 'package:hestia/domain/repositories/pet_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class PetDetailEvent extends Equatable {
  const PetDetailEvent();
  @override
  List<Object?> get props => const [];
}

class PetDetailLoad extends PetDetailEvent {
  final String petId;
  const PetDetailLoad(this.petId);
  @override
  List<Object?> get props => [petId];
}

class PetDetailRefresh extends PetDetailEvent {
  const PetDetailRefresh();
}

class PetDetailToggleActive extends PetDetailEvent {
  const PetDetailToggleActive();
}

class PetDetailDelete extends PetDetailEvent {
  const PetDetailDelete();
}

class PetDetailReloadRecords extends PetDetailEvent {
  const PetDetailReloadRecords();
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class PetDetailState extends Equatable {
  const PetDetailState();
  @override
  List<Object?> get props => const [];
}

class PetDetailInitial extends PetDetailState {
  const PetDetailInitial();
}

class PetDetailLoading extends PetDetailState {
  const PetDetailLoading();
}

class PetDetailLoaded extends PetDetailState {
  final Pet pet;
  final List<PetHealthRecord> records;
  const PetDetailLoaded(this.pet, this.records);
  @override
  List<Object?> get props => [pet, records];
}

class PetDetailNotFound extends PetDetailState {
  const PetDetailNotFound();
}

class PetDetailDeleted extends PetDetailState {
  const PetDetailDeleted();
}

class PetDetailError extends PetDetailState {
  final String message;
  const PetDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class PetDetailBloc extends Bloc<PetDetailEvent, PetDetailState> {
  final PetRepository _repo;
  String? _petId;

  PetDetailBloc(this._repo) : super(const PetDetailInitial()) {
    on<PetDetailLoad>(_onLoad);
    on<PetDetailRefresh>(_onRefresh);
    on<PetDetailToggleActive>(_onToggleActive);
    on<PetDetailDelete>(_onDelete);
    on<PetDetailReloadRecords>(_onReloadRecords);
  }

  Future<void> _onLoad(PetDetailLoad e, Emitter<PetDetailState> emit) async {
    _petId = e.petId;
    emit(const PetDetailLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(
      PetDetailRefresh e, Emitter<PetDetailState> emit) async {
    await _fetch(emit);
  }

  Future<void> _onToggleActive(
      PetDetailToggleActive e, Emitter<PetDetailState> emit) async {
    final cur = state;
    if (cur is! PetDetailLoaded) return;
    final updated = cur.pet.copyWith(isActive: !cur.pet.isActive);
    final failure = await _repo.updatePet(updated);
    if (failure != null) {
      emit(PetDetailError(failure.message));
      emit(cur);
      return;
    }
    emit(PetDetailLoaded(updated, cur.records));
  }

  Future<void> _onDelete(
      PetDetailDelete e, Emitter<PetDetailState> emit) async {
    final id = _petId;
    if (id == null) return;
    final failure = await _repo.deletePet(id);
    if (failure != null) {
      emit(PetDetailError(failure.message));
      return;
    }
    emit(const PetDetailDeleted());
  }

  Future<void> _onReloadRecords(
      PetDetailReloadRecords e, Emitter<PetDetailState> emit) async {
    final cur = state;
    if (cur is! PetDetailLoaded) return;
    final (records, failure) = await _repo.getHealthRecords(cur.pet.id);
    if (failure != null) {
      emit(PetDetailError(failure.message));
      emit(cur);
      return;
    }
    emit(PetDetailLoaded(cur.pet, records));
  }

  Future<void> _fetch(Emitter<PetDetailState> emit) async {
    final id = _petId;
    if (id == null) return;
    final (pet, petFailure) = await _repo.getPet(id);
    if (petFailure != null) {
      emit(PetDetailError(petFailure.message));
      return;
    }
    if (pet == null) {
      emit(const PetDetailNotFound());
      return;
    }
    final (records, recordsFailure) = await _repo.getHealthRecords(id);
    if (recordsFailure != null) {
      emit(PetDetailError(recordsFailure.message));
      return;
    }
    emit(PetDetailLoaded(pet, records));
  }
}
