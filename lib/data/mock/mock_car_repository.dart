import 'package:hestia/core/audit/audit_logger.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_latency.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/car.dart';
import 'package:hestia/domain/entities/car_member.dart';
import 'package:hestia/domain/repositories/car_repository.dart';
import 'package:uuid/uuid.dart';

class MockCarRepository implements CarRepository {
  static const _uuid = Uuid();

  AuditLogger get _audit => AppDependencies.instance.auditLogger;
  String get _actioner => MockStore.instance.currentProfile?.id ?? 'unknown';

  @override
  Future<(List<Car>, Failure?)> getCars({
    required String householdId,
    bool activeOnly = true,
  }) async {
    await mockReadLatency();
    final list = MockStore.instance.cars
        .where((c) => c.householdId == householdId)
        .where((c) => !activeOnly || c.status == CarStatus.active)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return (list, null);
  }

  @override
  Future<(Car?, Failure?)> getCar(String id) async {
    await mockReadLatency();
    final i = MockStore.instance.cars.indexWhere((c) => c.id == id);
    if (i < 0) return (null, const ServerFailure('Car not found'));
    return (MockStore.instance.cars[i], null);
  }

  @override
  Future<(Car?, Failure?)> createCar(
    Car car, {
    required List<String> memberUserIds,
  }) async {
    final now = DateTime.now();
    final created = car.copyWith(
      id: _uuid.v4(),
      createdAt: now,
      lastUpdate: now,
    );
    MockStore.instance.cars.add(created);
    for (final uid in memberUserIds) {
      MockStore.instance.carMembers.add(CarMember(
        id: _uuid.v4(),
        carId: created.id,
        userId: uid,
        createdAt: now,
      ));
    }
    await _audit.log(AuditEntry(
      actionerId: _actioner,
      action: AuditAction.create,
      targetId: created.id,
      entityType: 'car',
      timestamp: now.millisecondsSinceEpoch ~/ 1000,
    ));
    return (created, null);
  }

  @override
  Future<Failure?> updateCar(Car car) async {
    final list = MockStore.instance.cars;
    final i = list.indexWhere((c) => c.id == car.id);
    if (i < 0) return const ServerFailure('Car not found');
    final snapshot = _carSnapshot(list[i]);
    final now = DateTime.now();
    list[i] = car.copyWith(lastUpdate: now);
    await _audit.log(AuditEntry(
      actionerId: _actioner,
      action: AuditAction.update,
      targetId: car.id,
      entityType: 'car',
      timestamp: now.millisecondsSinceEpoch ~/ 1000,
      snapshot: snapshot,
    ));
    return null;
  }

  @override
  Future<Failure?> deleteCar(String id) async {
    final list = MockStore.instance.cars;
    final i = list.indexWhere((c) => c.id == id);
    final now = DateTime.now();
    if (i >= 0) {
      final snapshot = _carSnapshot(list[i]);
      // Soft-delete via status
      list[i] = list[i].copyWith(
        status: CarStatus.scrap,
        lastUpdate: now,
      );
      // Deactivate child fuel entries
      final entries =
          MockStore.instance.fuelEntries.where((e) => e.carId == id).toList();
      for (final e in entries) {
        await _audit.log(AuditEntry(
          actionerId: _actioner,
          action: AuditAction.deactivate,
          targetId: e.id,
          entityType: 'fuel_entry',
          timestamp: now.millisecondsSinceEpoch ~/ 1000,
        ));
      }
      await _audit.log(AuditEntry(
        actionerId: _actioner,
        action: AuditAction.deactivate,
        targetId: id,
        entityType: 'car',
        timestamp: now.millisecondsSinceEpoch ~/ 1000,
        snapshot: snapshot,
      ));
    }
    return null;
  }

  @override
  Future<(List<CarMember>, Failure?)> getMembers(String carId) async {
    await mockReadLatency();
    final list =
        MockStore.instance.carMembers.where((m) => m.carId == carId).toList();
    return (list, null);
  }

  static Map<String, dynamic> _carSnapshot(Car c) => {
        'id': c.id,
        'name': c.name,
        'licensePlate': c.licensePlate,
        'status': c.status.name,
        'currentOdometerKm': c.currentOdometerKm,
      };
}
