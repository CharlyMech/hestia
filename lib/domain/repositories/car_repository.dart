import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/car.dart';
import 'package:hestia/domain/entities/car_maintenance_record.dart';
import 'package:hestia/domain/entities/car_member.dart';

abstract class CarRepository {
  Future<(List<Car>, Failure?)> getCars({
    required String householdId,
    bool activeOnly = true,
  });

  Future<(Car?, Failure?)> getCar(String id);

  Future<(Car?, Failure?)> createCar(
    Car car, {
    required List<String> memberUserIds,
  });

  Future<Failure?> updateCar(Car car);

  Future<Failure?> deleteCar(String id);

  Future<(List<CarMember>, Failure?)> getMembers(String carId);

  Future<(List<CarMaintenanceRecord>, Failure?)> getMaintenanceRecords(
      String carId);

  Future<Failure?> createMaintenanceRecord(CarMaintenanceRecord record,
      {Map<String, dynamic>? transaction});

  Future<Failure?> updateMaintenanceRecord(CarMaintenanceRecord record);

  Future<Failure?> deleteMaintenanceRecord(String id);
}
