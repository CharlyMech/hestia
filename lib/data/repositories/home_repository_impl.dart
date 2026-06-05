import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/services/home_service.dart';
import 'package:hestia/domain/entities/home.dart';
import 'package:hestia/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeService _service;
  HomeRepositoryImpl(this._service);

  Home _fromJson(Map<String, dynamic> j) => Home(
        id: j['id'] as String,
        householdId: j['household_id'] as String,
        name: j['name'] as String,
        address: j['address'] as String,
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        description: j['description'] as String?,
        imageUrl: j['image_url'] as String?,
        createdAt:
            parseSupabaseTimestamp(j['created_at'], orElse: DateTime.now()),
      );

  Map<String, dynamic> _toJson(Home h) => {
        'household_id': h.householdId,
        'name': h.name,
        'address': h.address,
        'latitude': h.latitude,
        'longitude': h.longitude,
        'description': h.description,
        'image_url': h.imageUrl,
      };

  @override
  Future<(List<Home>, Failure?)> getHomes(String householdId) async {
    try {
      final data = await _service.getHomes(householdId);
      return (data.map(_fromJson).toList(), null);
    } catch (e, st) {
      return (<Home>[], reportError(e, st, reason: 'getHomes'));
    }
  }

  @override
  Future<(Home?, Failure?)> getHome(String id) async {
    try {
      final data = await _service.getHome(id);
      return (data == null ? null : _fromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'getHome'));
    }
  }

  @override
  Future<(Home?, Failure?)> createHome(Home home) async {
    try {
      final data = await _service.createHome(_toJson(home));
      return (_fromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'createHome'));
    }
  }

  @override
  Future<Failure?> updateHome(Home home) async {
    try {
      await _service.updateHome(home.id, _toJson(home));
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'updateHome');
    }
  }

  @override
  Future<Failure?> deleteHome(String id) async {
    try {
      await _service.deleteHome(id);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'deleteHome');
    }
  }
}
