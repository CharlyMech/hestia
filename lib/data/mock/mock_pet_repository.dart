import 'package:hestia/core/audit/audit_logger.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_latency.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/pet.dart';
import 'package:hestia/domain/entities/pet_health_record.dart';
import 'package:hestia/domain/repositories/pet_repository.dart';
import 'package:uuid/uuid.dart';

class MockPetRepository implements PetRepository {
  static const _uuid = Uuid();

  AuditLogger get _audit => AppDependencies.instance.auditLogger;
  String get _actioner => MockStore.instance.currentProfile?.id ?? 'unknown';

  @override
  Future<(List<Pet>, Failure?)> getPets({
    required String householdId,
    bool activeOnly = true,
  }) async {
    await mockReadLatency();
    final list = MockStore.instance.pets
        .where((p) => p.householdId == householdId)
        .where((p) => !activeOnly || p.isActive)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return (list, null);
  }

  @override
  Future<(Pet?, Failure?)> getPet(String id) async {
    await mockReadLatency();
    final i = MockStore.instance.pets.indexWhere((p) => p.id == id);
    if (i < 0) return (null, const ServerFailure('Pet not found'));
    return (MockStore.instance.pets[i], null);
  }

  @override
  Future<(Pet?, Failure?)> createPet(Pet pet) async {
    final now = DateTime.now();
    final created = pet.copyWith(
      id: _uuid.v4(),
      createdAt: now,
      lastUpdate: now,
    );
    MockStore.instance.pets.add(created);
    await _audit.log(AuditEntry(
      actionerId: _actioner,
      action: AuditAction.create,
      targetId: created.id,
      entityType: 'pet',
      timestamp: now.millisecondsSinceEpoch ~/ 1000,
    ));
    return (created, null);
  }

  @override
  Future<Failure?> updatePet(Pet pet) async {
    final list = MockStore.instance.pets;
    final i = list.indexWhere((p) => p.id == pet.id);
    if (i < 0) return const ServerFailure('Pet not found');
    final snapshot = _petSnapshot(list[i]);
    final now = DateTime.now();
    list[i] = pet.copyWith(lastUpdate: now);
    await _audit.log(AuditEntry(
      actionerId: _actioner,
      action: AuditAction.update,
      targetId: pet.id,
      entityType: 'pet',
      timestamp: now.millisecondsSinceEpoch ~/ 1000,
      snapshot: snapshot,
    ));
    return null;
  }

  @override
  Future<Failure?> deletePet(String id) async {
    final list = MockStore.instance.pets;
    final i = list.indexWhere((p) => p.id == id);
    final now = DateTime.now();
    if (i >= 0) {
      final snapshot = _petSnapshot(list[i]);
      // Soft-delete: set inactive
      list[i] = list[i].copyWith(isActive: false, lastUpdate: now);
      // Deactivate child health records
      final records = MockStore.instance.petHealthRecords
          .where((r) => r.petId == id)
          .toList();
      for (final r in records) {
        await _audit.log(AuditEntry(
          actionerId: _actioner,
          action: AuditAction.deactivate,
          targetId: r.id,
          entityType: 'pet_health_record',
          timestamp: now.millisecondsSinceEpoch ~/ 1000,
        ));
      }
      await _audit.log(AuditEntry(
        actionerId: _actioner,
        action: AuditAction.deactivate,
        targetId: id,
        entityType: 'pet',
        timestamp: now.millisecondsSinceEpoch ~/ 1000,
        snapshot: snapshot,
      ));
    }
    return null;
  }

  @override
  Future<(List<PetHealthRecord>, Failure?)> getHealthRecords(
      String petId) async {
    await mockReadLatency();
    final list = MockStore.instance.petHealthRecords
        .where((r) => r.petId == petId)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return (list, null);
  }

  @override
  Future<(PetHealthRecord?, Failure?)> createHealthRecord(
      PetHealthRecord record) async {
    final now = DateTime.now();
    final created = record.copyWith(
      id: _uuid.v4(),
      createdAt: now,
    );
    MockStore.instance.petHealthRecords.add(created);
    await _audit.log(AuditEntry(
      actionerId: _actioner,
      action: AuditAction.create,
      targetId: created.id,
      entityType: 'pet_health_record',
      timestamp: now.millisecondsSinceEpoch ~/ 1000,
    ));
    return (created, null);
  }

  @override
  Future<Failure?> updateHealthRecord(PetHealthRecord record) async {
    final list = MockStore.instance.petHealthRecords;
    final i = list.indexWhere((r) => r.id == record.id);
    if (i < 0) return const ServerFailure('Health record not found');
    final snapshot = _recordSnapshot(list[i]);
    final now = DateTime.now();
    list[i] = record;
    await _audit.log(AuditEntry(
      actionerId: _actioner,
      action: AuditAction.update,
      targetId: record.id,
      entityType: 'pet_health_record',
      timestamp: now.millisecondsSinceEpoch ~/ 1000,
      snapshot: snapshot,
    ));
    return null;
  }

  @override
  Future<Failure?> deleteHealthRecord(String id) async {
    final now = DateTime.now();
    MockStore.instance.petHealthRecords.removeWhere((r) => r.id == id);
    await _audit.log(AuditEntry(
      actionerId: _actioner,
      action: AuditAction.delete,
      targetId: id,
      entityType: 'pet_health_record',
      timestamp: now.millisecondsSinceEpoch ~/ 1000,
    ));
    return null;
  }

  static Map<String, dynamic> _petSnapshot(Pet p) => {
        'id': p.id,
        'name': p.name,
        'species': p.species.name,
        'isActive': p.isActive,
        'weightKg': p.weightKg,
      };

  static Map<String, dynamic> _recordSnapshot(PetHealthRecord r) => {
        'id': r.id,
        'type': r.type.name,
        'title': r.title,
        'recordedAt': r.recordedAt.toIso8601String(),
      };
}
