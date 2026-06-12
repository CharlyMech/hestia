import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class CarService extends SupabaseService {
  CarService({super.client});

  Future<List<Map<String, dynamic>>> getCars({
    required String householdId,
    bool activeOnly = true,
  }) async {
    try {
      var query =
          from(SupabaseTables.cars).select().eq('household_id', householdId);
      if (activeOnly) query = query.eq('is_active', true);
      final res = await query.order('name');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch cars: $e');
    }
  }

  Future<Map<String, dynamic>?> getCar(String id) async {
    try {
      return await from(SupabaseTables.cars)
          .select()
          .eq('id', id)
          .maybeSingle();
    } catch (e) {
      throw ServerException('Failed to fetch car: $e');
    }
  }

  Future<Map<String, dynamic>> createCar(Map<String, dynamic> data) async {
    try {
      return await from(SupabaseTables.cars).insert(data).select().single();
    } catch (e) {
      throw ServerException('Failed to create car: $e');
    }
  }

  Future<void> updateCar(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.cars).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update car: $e');
    }
  }

  Future<void> deleteCar(String id) async {
    try {
      await from(SupabaseTables.cars).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete car: $e');
    }
  }

  Future<void> addMembers(String carId, List<String> userIds) async {
    if (userIds.isEmpty) return;
    try {
      await from(SupabaseTables.carMembers).insert(
        userIds.map((u) => {'car_id': carId, 'user_id': u}).toList(),
      );
    } catch (e) {
      throw ServerException('Failed to add car members: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMembers(String carId) async {
    try {
      final res =
          await from(SupabaseTables.carMembers).select().eq('car_id', carId);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch car members: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMaintenanceRecords(
      String carId) async {
    try {
      final res = await from(SupabaseTables.carMaintenanceRecords)
          .select()
          .eq('car_id', carId)
          .order('recorded_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch maintenance records: $e');
    }
  }

  /// Create via `create-maintenance-record` edge function.
  Future<Map<String, dynamic>> createMaintenanceRecord({
    required Map<String, dynamic> record,
    Map<String, dynamic>? transaction,
    String? id,
  }) async {
    try {
      final res = await client.functions.invoke(
        'create-maintenance-record',
        body: {
          'record': record,
          if (transaction != null) 'transaction': transaction,
          if (id != null) 'id': id,
        },
      );
      final body = res.data as Map<String, dynamic>;
      if (body['error'] != null) {
        throw ServerException(
            'Failed to create maintenance record: ${body['error']}');
      }
      return Map<String, dynamic>.from(body['record'] as Map);
    } catch (e) {
      throw ServerException('Failed to create maintenance record: $e');
    }
  }

  Future<void> updateMaintenanceRecord(
      String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.carMaintenanceRecords)
          .update(data)
          .eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update maintenance record: $e');
    }
  }

  Future<void> deleteMaintenanceRecord(String id) async {
    try {
      await from(SupabaseTables.carMaintenanceRecords).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete maintenance record: $e');
    }
  }
}
