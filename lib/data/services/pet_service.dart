import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class PetService extends SupabaseService {
  PetService({super.client});

  Future<List<Map<String, dynamic>>> getPets({
    required String householdId,
    bool activeOnly = true,
  }) async {
    try {
      var query =
          from(SupabaseTables.pets).select().eq('household_id', householdId);
      if (activeOnly) query = query.eq('is_active', true);
      final res = await query.order('name');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch pets: $e');
    }
  }

  Future<Map<String, dynamic>?> getPet(String id) async {
    try {
      return await from(SupabaseTables.pets)
          .select()
          .eq('id', id)
          .maybeSingle();
    } catch (e) {
      throw ServerException('Failed to fetch pet: $e');
    }
  }

  Future<Map<String, dynamic>> createPet(Map<String, dynamic> data) async {
    try {
      return await from(SupabaseTables.pets).insert(data).select().single();
    } catch (e) {
      throw ServerException('Failed to create pet: $e');
    }
  }

  Future<void> updatePet(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.pets).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update pet: $e');
    }
  }

  Future<void> deletePet(String id) async {
    try {
      await from(SupabaseTables.pets).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete pet: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getHealthRecords(String petId) async {
    try {
      final res = await from(SupabaseTables.petHealthRecords)
          .select()
          .eq('pet_id', petId)
          .order('recorded_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch health records: $e');
    }
  }

  /// Create via `create-health-record` edge function.
  /// Pass [transaction] map to atomically create an expense transaction.
  Future<Map<String, dynamic>> createHealthRecord({
    required Map<String, dynamic> record,
    Map<String, dynamic>? transaction,
    String? id,
  }) async {
    try {
      final res = await client.functions.invoke(
        'create-health-record',
        body: {
          'record': record,
          if (transaction != null) 'transaction': transaction,
          if (id != null) 'id': id,
        },
      );
      final body = res.data as Map<String, dynamic>;
      if (body['error'] != null) {
        throw ServerException(
            'Failed to create health record: ${body['error']}');
      }
      return Map<String, dynamic>.from(body['record'] as Map);
    } catch (e) {
      throw ServerException('Failed to create health record: $e');
    }
  }

  Future<void> updateHealthRecord(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.petHealthRecords).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update health record: $e');
    }
  }

  Future<void> deleteHealthRecord(String id) async {
    try {
      await from(SupabaseTables.petHealthRecords).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete health record: $e');
    }
  }
}
