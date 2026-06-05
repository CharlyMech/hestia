import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/services/transaction_source_service.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/domain/repositories/transaction_source_repository.dart';

class TransactionSourceRepositoryImpl implements TransactionSourceRepository {
  final TransactionSourceService _service;
  TransactionSourceRepositoryImpl(this._service);

  TransactionSource _fromJson(Map<String, dynamic> j) => TransactionSource(
        id: j['id'] as String,
        householdId: j['household_id'] as String,
        name: j['name'] as String,
        kind: TransactionSourceKind.fromString(j['kind'] as String? ?? 'other'),
        color: j['color'] as String?,
        icon: j['icon'] as String?,
        imageUrl: j['image_url'] as String?,
        isActive: j['is_active'] as bool? ?? true,
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        address: j['address'] as String?,
        createdBy: j['created_by'] as String? ?? '',
        createdAt:
            parseSupabaseTimestamp(j['created_at'], orElse: DateTime.now()),
        lastUpdate:
            parseSupabaseTimestamp(j['last_update'], orElse: DateTime.now()),
      );

  Map<String, dynamic> _toJson(TransactionSource s) => {
        'household_id': s.householdId,
        'name': s.name,
        'kind': s.kind.name,
        'color': s.color,
        'icon': s.icon,
        'image_url': s.imageUrl,
        'is_active': s.isActive,
        'latitude': s.latitude,
        'longitude': s.longitude,
        'address': s.address,
        'created_by': s.createdBy,
      };

  @override
  Future<(List<TransactionSource>, Failure?)> getAll({
    required String householdId,
    bool activeOnly = true,
  }) async {
    if (householdId.isEmpty) return (const <TransactionSource>[], null);
    try {
      final data = await _service.getAll(
          householdId: householdId, activeOnly: activeOnly);
      return (data.map(_fromJson).toList(), null);
    } catch (e, st) {
      return (<TransactionSource>[], reportError(e, st, reason: 'getSources'));
    }
  }

  @override
  Future<(TransactionSource?, Failure?)> create(
      TransactionSource source) async {
    try {
      final data = await _service.create(_toJson(source));
      return (_fromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'createSource'));
    }
  }

  @override
  Future<Failure?> update(TransactionSource source) async {
    try {
      await _service.update(source.id, _toJson(source));
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'updateSource');
    }
  }

  @override
  Future<Failure?> delete(String id) async {
    try {
      await _service.delete(id);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'deleteSource');
    }
  }
}
