import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class PetMeasurementService extends SupabaseService {
  PetMeasurementService({super.client});

  Future<List<Map<String, dynamic>>> getMeasurements(String petId) async {
    try {
      final res = await from(SupabaseTables.petMeasurements)
          .select()
          .eq('pet_id', petId)
          .order('recorded_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw ServerException('Failed to fetch pet measurements: $e');
    }
  }

  Future<Map<String, dynamic>> add(Map<String, dynamic> data) async {
    try {
      return await from(SupabaseTables.petMeasurements)
          .insert(data)
          .select()
          .single();
    } catch (e) {
      throw ServerException('Failed to add pet measurement: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await from(SupabaseTables.petMeasurements).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete pet measurement: $e');
    }
  }
}
