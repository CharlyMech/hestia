import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/fuel_entry.dart';

abstract class FuelEntryRepository {
  Future<(List<FuelEntry>, Failure?)> getEntries({
    required String carId,
    int limit = 200,
  });

  Future<(FuelEntry?, Failure?)> create(FuelEntry e);

  Future<Failure?> update(FuelEntry e);

  Future<Failure?> delete(String id);
}
