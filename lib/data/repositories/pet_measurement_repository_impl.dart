import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/services/pet_measurement_service.dart';
import 'package:hestia/domain/entities/pet_measurement.dart';
import 'package:hestia/domain/repositories/pet_measurement_repository.dart';

class PetMeasurementRepositoryImpl implements PetMeasurementRepository {
  final PetMeasurementService _service;
  PetMeasurementRepositoryImpl(this._service);

  PetMeasurement _fromJson(Map<String, dynamic> j) => PetMeasurement(
        id: j['id'] as String,
        petId: j['pet_id'] as String,
        recordedAt: (j['recorded_at'] as num).toInt(), // unix millis
        weightKg: (j['weight_kg'] as num).toDouble(),
        ageMonths: (j['age_months'] as num?)?.toInt(),
      );

  Map<String, dynamic> _toJson(PetMeasurement m) => {
        'pet_id': m.petId,
        'recorded_at': m.recordedAt,
        'weight_kg': m.weightKg,
        'age_months': m.ageMonths,
      };

  @override
  Future<(List<PetMeasurement>, Failure?)> getMeasurements(String petId) async {
    try {
      final data = await _service.getMeasurements(petId);
      return (data.map(_fromJson).toList(), null);
    } catch (e, st) {
      return (
        <PetMeasurement>[],
        reportError(e, st, reason: 'getMeasurements')
      );
    }
  }

  @override
  Future<(PetMeasurement?, Failure?)> addMeasurement(
      PetMeasurement measurement) async {
    try {
      final data = await _service.add(_toJson(measurement));
      return (_fromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'addMeasurement'));
    }
  }

  @override
  Future<Failure?> deleteMeasurement(String id) async {
    try {
      await _service.delete(id);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'deleteMeasurement');
    }
  }
}
