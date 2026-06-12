import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/services/fuel_entry_service.dart';
import 'package:hestia/domain/entities/fuel_entry.dart';
import 'package:hestia/domain/repositories/fuel_entry_repository.dart';

class FuelEntryRepositoryImpl implements FuelEntryRepository {
  final FuelEntryService _service;
  FuelEntryRepositoryImpl(this._service);

  FuelEntry _fromJson(Map<String, dynamic> j) => FuelEntry(
        id: j['id'] as String,
        carId: j['car_id'] as String,
        transactionId: j['transaction_id'] as String?,
        odometerKm: (j['odometer_km'] as num).toDouble(),
        liters: (j['liters'] as num).toDouble(),
        pricePerLiter: (j['price_per_liter'] as num).toDouble(),
        totalAmount: (j['total_amount'] as num).toDouble(),
        isFullTank: j['is_full_tank'] as bool? ?? true,
        stationSourceId: j['station_source_id'] as String?,
        notes: j['notes'] as String?,
        filledAt:
            parseSupabaseTimestamp(j['filled_at'], orElse: DateTime.now()),
        createdBy: j['created_by'] as String? ?? '',
        createdAt:
            parseSupabaseTimestamp(j['created_at'], orElse: DateTime.now()),
      );

  Map<String, dynamic> _toJson(FuelEntry e) => {
        'car_id': e.carId,
        'transaction_id': e.transactionId,
        'odometer_km': e.odometerKm,
        'liters': e.liters,
        'price_per_liter': e.pricePerLiter,
        'total_amount': e.totalAmount,
        'is_full_tank': e.isFullTank,
        'station_source_id': e.stationSourceId,
        'notes': e.notes,
        'filled_at': e.filledAt.toUnix,
        'created_by': e.createdBy,
      };

  @override
  Future<(List<FuelEntry>, Failure?)> getEntries({
    required String carId,
    int limit = 200,
  }) async {
    try {
      final data = await _service.getEntries(carId: carId, limit: limit);
      return (data.map(_fromJson).toList(), null);
    } catch (e, st) {
      return (<FuelEntry>[], reportError(e, st, reason: 'getFuelEntries'));
    }
  }

  @override
  Future<(FuelEntry?, Failure?)> create(FuelEntry e) async {
    try {
      final data = await _service.create(entry: _toJson(e));
      return (_fromJson(data), null);
    } catch (err, st) {
      return (null, reportError(err, st, reason: 'createFuelEntry'));
    }
  }

  @override
  Future<Failure?> update(FuelEntry e) async {
    try {
      await _service.update(e.id, _toJson(e));
      return null;
    } catch (err, st) {
      return reportError(err, st, reason: 'updateFuelEntry');
    }
  }

  @override
  Future<Failure?> delete(String id) async {
    try {
      await _service.delete(id);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'deleteFuelEntry');
    }
  }
}
