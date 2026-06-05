import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/pet_measurement.dart';

abstract class PetMeasurementRepository {
  Future<(List<PetMeasurement>, Failure?)> getMeasurements(String petId);

  Future<(PetMeasurement?, Failure?)> addMeasurement(
      PetMeasurement measurement);

  Future<Failure?> deleteMeasurement(String id);
}
