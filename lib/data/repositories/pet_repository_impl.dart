import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/services/pet_service.dart';
import 'package:hestia/domain/entities/pet.dart';
import 'package:hestia/domain/entities/pet_health_record.dart';
import 'package:hestia/domain/repositories/pet_repository.dart';

class PetRepositoryImpl implements PetRepository {
  final PetService _service;
  PetRepositoryImpl(this._service);

  Pet _petFromJson(Map<String, dynamic> j) => Pet(
        id: j['id'] as String,
        householdId: j['household_id'] as String,
        name: j['name'] as String,
        species: PetSpecies.values.firstWhere(
          (s) => s.name == j['species'],
          orElse: () => PetSpecies.other,
        ),
        breed: j['breed'] as String?,
        gender: PetGender.values.firstWhere(
          (g) => g.name == j['gender'],
          orElse: () => PetGender.unknown,
        ),
        birthDate: j['birth_date'] != null
            ? DateTime.tryParse(j['birth_date'] as String)
            : null,
        weightKg: (j['weight_kg'] as num?)?.toDouble(),
        imageUrl: j['image_url'] as String?,
        notes: j['notes'] as String?,
        isActive: j['is_active'] as bool? ?? true,
        createdBy: j['created_by'] as String? ?? '',
        createdAt:
            parseSupabaseTimestamp(j['created_at'], orElse: DateTime.now()),
        lastUpdate:
            parseSupabaseTimestamp(j['last_update'], orElse: DateTime.now()),
      );

  Map<String, dynamic> _petToJson(Pet p) => {
        'household_id': p.householdId,
        'name': p.name,
        'species': p.species.name,
        'breed': p.breed,
        'gender': p.gender.name,
        'birth_date': p.birthDate?.toIso8601String().split('T').first,
        'weight_kg': p.weightKg,
        'image_url': p.imageUrl,
        'notes': p.notes,
        'is_active': p.isActive,
        'created_by': p.createdBy,
      };

  PetHealthRecord _recordFromJson(Map<String, dynamic> j) => PetHealthRecord(
        id: j['id'] as String,
        petId: j['pet_id'] as String,
        type: HealthRecordType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => HealthRecordType.other,
        ),
        title: j['title'] as String,
        notes: j['notes'] as String?,
        recordedAt:
            parseSupabaseTimestamp(j['recorded_at'], orElse: DateTime.now()),
        nextDueAt: j['next_due_at'] != null
            ? parseSupabaseTimestamp(j['next_due_at'])
            : null,
        cost: (j['cost'] as num?)?.toDouble(),
        vetName: j['vet_name'] as String?,
        createdBy: j['created_by'] as String? ?? '',
        createdAt:
            parseSupabaseTimestamp(j['created_at'], orElse: DateTime.now()),
      );

  Map<String, dynamic> _recordToJson(PetHealthRecord r) => {
        'pet_id': r.petId,
        'type': r.type.name,
        'title': r.title,
        'notes': r.notes,
        'recorded_at': r.recordedAt.toUnix,
        'next_due_at': r.nextDueAt?.toUnix,
        'cost': r.cost,
        'vet_name': r.vetName,
        'created_by': r.createdBy,
      };

  @override
  Future<(List<Pet>, Failure?)> getPets({
    required String householdId,
    bool activeOnly = true,
  }) async {
    if (householdId.isEmpty) return (const <Pet>[], null);
    try {
      final data = await _service.getPets(
          householdId: householdId, activeOnly: activeOnly);
      return (data.map(_petFromJson).toList(), null);
    } catch (e, st) {
      return (<Pet>[], reportError(e, st, reason: 'getPets'));
    }
  }

  @override
  Future<(Pet?, Failure?)> getPet(String id) async {
    try {
      final data = await _service.getPet(id);
      return (data == null ? null : _petFromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'getPet'));
    }
  }

  @override
  Future<(Pet?, Failure?)> createPet(Pet pet) async {
    try {
      final data = await _service.createPet(_petToJson(pet));
      return (_petFromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'createPet'));
    }
  }

  @override
  Future<Failure?> updatePet(Pet pet) async {
    try {
      await _service.updatePet(pet.id, _petToJson(pet));
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'updatePet');
    }
  }

  @override
  Future<Failure?> deletePet(String id) async {
    try {
      await _service.deletePet(id);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'deletePet');
    }
  }

  @override
  Future<(List<PetHealthRecord>, Failure?)> getHealthRecords(
      String petId) async {
    try {
      final data = await _service.getHealthRecords(petId);
      return (data.map(_recordFromJson).toList(), null);
    } catch (e, st) {
      return (
        <PetHealthRecord>[],
        reportError(e, st, reason: 'getHealthRecords')
      );
    }
  }

  @override
  Future<(PetHealthRecord?, Failure?)> createHealthRecord(
      PetHealthRecord record) async {
    try {
      final data = await _service.createHealthRecord(record: _recordToJson(record));
      return (_recordFromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'createHealthRecord'));
    }
  }

  @override
  Future<Failure?> updateHealthRecord(PetHealthRecord record) async {
    try {
      await _service.updateHealthRecord(record.id, _recordToJson(record));
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'updateHealthRecord');
    }
  }

  @override
  Future<Failure?> deleteHealthRecord(String id) async {
    try {
      await _service.deleteHealthRecord(id);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'deleteHealthRecord');
    }
  }
}
