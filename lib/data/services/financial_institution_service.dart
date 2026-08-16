import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class FinancialInstitutionService extends SupabaseService {
  FinancialInstitutionService({super.client});

  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final response = await from(SupabaseTables.financialInstitutions)
          .select()
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch financial institutions: $e');
    }
  }

  Future<Map<String, dynamic>> getById(String id) async {
    try {
      final response = await from(SupabaseTables.financialInstitutions)
          .select()
          .eq('id', id)
          .single();
      return response;
    } catch (e) {
      throw ServerException('Failed to fetch financial institution: $e');
    }
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      final response = await from(SupabaseTables.financialInstitutions)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      throw ServerException('Failed to create financial institution: $e');
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.financialInstitutions)
          .update(data)
          .eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update financial institution: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await from(SupabaseTables.financialInstitutions).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete financial institution: $e');
    }
  }
}
