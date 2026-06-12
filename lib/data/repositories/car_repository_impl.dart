import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/dtos/car_maintenance_record_dto.dart';
import 'package:hestia/data/mappers/car_maintenance_record_mapper.dart';
import 'package:hestia/data/services/car_service.dart';
import 'package:hestia/domain/entities/car.dart';
import 'package:hestia/domain/entities/car_maintenance_record.dart';
import 'package:hestia/domain/entities/car_member.dart';
import 'package:hestia/domain/repositories/car_repository.dart';

class CarRepositoryImpl implements CarRepository {
  final CarService _service;
  CarRepositoryImpl(this._service);

  Car _fromJson(Map<String, dynamic> j) => Car(
        id: j['id'] as String,
        householdId: j['household_id'] as String,
        name: j['name'] as String,
        imageUrl: j['image_url'] as String?,
        make: j['make'] as String?,
        model: j['model'] as String?,
        year: (j['year'] as num?)?.toInt(),
        licensePlate: j['license_plate'] as String?,
        fuelType: FuelType.values.firstWhere(
          (f) => f.name == j['fuel_type'],
          orElse: () => FuelType.gasoline,
        ),
        tankCapacityLiters: (j['tank_capacity_liters'] as num?)?.toDouble(),
        currentOdometerKm: (j['current_odometer_km'] as num?)?.toDouble(),
        isActive: (j['is_active'] as bool?) ?? true,
        createdBy: j['created_by'] as String? ?? '',
        createdAt:
            parseSupabaseTimestamp(j['created_at'], orElse: DateTime.now()),
        lastUpdate:
            parseSupabaseTimestamp(j['last_update'], orElse: DateTime.now()),
      );

  Map<String, dynamic> _toJson(Car c) => {
        'household_id': c.householdId,
        'name': c.name,
        'image_url': c.imageUrl,
        'make': c.make,
        'model': c.model,
        'year': c.year,
        'license_plate': c.licensePlate,
        'fuel_type': c.fuelType.name,
        'tank_capacity_liters': c.tankCapacityLiters,
        'current_odometer_km': c.currentOdometerKm,
        'is_active': c.isActive,
        'created_by': c.createdBy,
      };

  @override
  Future<(List<Car>, Failure?)> getCars({
    required String householdId,
    bool activeOnly = true,
  }) async {
    if (householdId.isEmpty) return (const <Car>[], null);
    try {
      final data = await _service.getCars(
          householdId: householdId, activeOnly: activeOnly);
      return (data.map(_fromJson).toList(), null);
    } catch (e, st) {
      return (<Car>[], reportError(e, st, reason: 'getCars'));
    }
  }

  @override
  Future<(Car?, Failure?)> getCar(String id) async {
    try {
      final data = await _service.getCar(id);
      return (data == null ? null : _fromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'getCar'));
    }
  }

  @override
  Future<(Car?, Failure?)> createCar(
    Car car, {
    required List<String> memberUserIds,
  }) async {
    try {
      final data = await _service.createCar(_toJson(car));
      final created = _fromJson(data);
      await _service.addMembers(created.id, memberUserIds);
      return (created, null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'createCar'));
    }
  }

  @override
  Future<Failure?> updateCar(Car car) async {
    try {
      await _service.updateCar(car.id, _toJson(car));
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'updateCar');
    }
  }

  @override
  Future<Failure?> deleteCar(String id) async {
    try {
      await _service.deleteCar(id);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'deleteCar');
    }
  }

  @override
  Future<(List<CarMember>, Failure?)> getMembers(String carId) async {
    try {
      final data = await _service.getMembers(carId);
      final members = data
          .map((j) => CarMember(
                id: j['id'] as String,
                carId: j['car_id'] as String,
                userId: j['user_id'] as String,
                createdAt: parseSupabaseTimestamp(j['created_at'],
                    orElse: DateTime.now()),
              ))
          .toList();
      return (members, null);
    } catch (e, st) {
      return (<CarMember>[], reportError(e, st, reason: 'getCarMembers'));
    }
  }

  @override
  Future<(List<CarMaintenanceRecord>, Failure?)> getMaintenanceRecords(
      String carId) async {
    try {
      final data = await _service.getMaintenanceRecords(carId);
      return (
        data
            .map((j) => CarMaintenanceRecordMapper.fromDto(
                CarMaintenanceRecordDto.fromJson(j)))
            .toList(),
        null
      );
    } catch (e, st) {
      return (
        <CarMaintenanceRecord>[],
        reportError(e, st, reason: 'getMaintenanceRecords')
      );
    }
  }

  @override
  Future<Failure?> createMaintenanceRecord(CarMaintenanceRecord record,
      {Map<String, dynamic>? transaction}) async {
    try {
      await _service.createMaintenanceRecord(
        record: CarMaintenanceRecordMapper.toDto(record).toInsertJson(),
        transaction: transaction,
        id: record.id.isEmpty ? null : record.id,
      );
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'createMaintenanceRecord');
    }
  }

  @override
  Future<Failure?> updateMaintenanceRecord(CarMaintenanceRecord record) async {
    try {
      await _service.updateMaintenanceRecord(
        record.id,
        CarMaintenanceRecordMapper.toDto(record).toInsertJson(),
      );
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'updateMaintenanceRecord');
    }
  }

  @override
  Future<Failure?> deleteMaintenanceRecord(String id) async {
    try {
      await _service.deleteMaintenanceRecord(id);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'deleteMaintenanceRecord');
    }
  }
}
