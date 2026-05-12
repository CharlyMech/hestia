import 'package:hestia/core/audit/audit_logger.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_latency.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/fuel_entry.dart';
import 'package:hestia/domain/repositories/fuel_entry_repository.dart';
import 'package:uuid/uuid.dart';

class MockFuelEntryRepository implements FuelEntryRepository {
  static const _uuid = Uuid();

  AuditLogger get _audit => AppDependencies.instance.auditLogger;
  String get _actioner => MockStore.instance.currentProfile?.id ?? 'unknown';

  @override
  Future<(List<FuelEntry>, Failure?)> getEntries({
    required String carId,
    int limit = 200,
  }) async {
    await mockReadLatency();
    final list = MockStore.instance.fuelEntries
        .where((e) => e.carId == carId)
        .toList()
      ..sort((a, b) => b.filledAt.compareTo(a.filledAt));
    final clipped = list.length > limit ? list.sublist(0, limit) : list;
    return (clipped, null);
  }

  @override
  Future<(FuelEntry?, Failure?)> create(FuelEntry e) async {
    final now = DateTime.now();
    final created = e.copyWith(
      id: _uuid.v4(),
      createdAt: now,
    );
    MockStore.instance.fuelEntries.add(created);
    await _audit.log(AuditEntry(
      actionerId: _actioner,
      action: AuditAction.create,
      targetId: created.id,
      entityType: 'fuel_entry',
      timestamp: now.millisecondsSinceEpoch ~/ 1000,
    ));
    // TODO: link to transaction repo (atomic creation of paired transaction).
    return (created, null);
  }

  @override
  Future<Failure?> update(FuelEntry e) async {
    final list = MockStore.instance.fuelEntries;
    final i = list.indexWhere((x) => x.id == e.id);
    if (i < 0) return const ServerFailure('Fuel entry not found');
    final snapshot = _snapshot(list[i]);
    final now = DateTime.now();
    list[i] = e;
    await _audit.log(AuditEntry(
      actionerId: _actioner,
      action: AuditAction.update,
      targetId: e.id,
      entityType: 'fuel_entry',
      timestamp: now.millisecondsSinceEpoch ~/ 1000,
      snapshot: snapshot,
    ));
    return null;
  }

  @override
  Future<Failure?> delete(String id) async {
    final now = DateTime.now();
    MockStore.instance.fuelEntries.removeWhere((e) => e.id == id);
    await _audit.log(AuditEntry(
      actionerId: _actioner,
      action: AuditAction.delete,
      targetId: id,
      entityType: 'fuel_entry',
      timestamp: now.millisecondsSinceEpoch ~/ 1000,
    ));
    return null;
  }

  static Map<String, dynamic> _snapshot(FuelEntry e) => {
        'id': e.id,
        'carId': e.carId,
        'odometerKm': e.odometerKm,
        'liters': e.liters,
        'totalAmount': e.totalAmount,
        'filledAt': e.filledAt.toIso8601String(),
      };
}
