import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class FuelEntryService extends SupabaseService {
  FuelEntryService({super.client});

  Future<List<Map<String, dynamic>>> getEntries({
    required String carId,
    int limit = 200,
  }) async {
    try {
      final res = await from(SupabaseTables.fuelEntries)
          .select()
          .eq('car_id', carId)
          .order('filled_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch fuel entries: $e');
    }
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      return await from(SupabaseTables.fuelEntries)
          .insert(data)
          .select()
          .single();
    } catch (e) {
      throw ServerException('Failed to create fuel entry: $e');
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.fuelEntries).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update fuel entry: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await from(SupabaseTables.fuelEntries).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete fuel entry: $e');
    }
  }
}
