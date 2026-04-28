import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class GoalService extends SupabaseService {
  GoalService({super.client});

  Future<List<Map<String, dynamic>>> getGoals({
    required String householdId,
    String? ownerId,
    bool activeOnly = true,
  }) async {
    try {
      var query = from(SupabaseTables.financialGoals)
          .select()
          .eq('household_id', householdId);

      if (activeOnly) query = query.eq('is_active', true);

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch goals: $e');
    }
  }

  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> data) async {
    try {
      final response = await from(SupabaseTables.financialGoals)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      throw ServerException('Failed to create goal: $e');
    }
  }

  Future<void> updateGoal(String id, Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.financialGoals).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update goal: $e');
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await from(SupabaseTables.financialGoals).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete goal: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getContributions(String goalId) async {
    try {
      final response = await from(SupabaseTables.goalContributions)
          .select()
          .eq('goal_id', goalId)
          .order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch contributions: $e');
    }
  }

  Future<Map<String, dynamic>> addContribution(
      Map<String, dynamic> data) async {
    try {
      final response = await from(SupabaseTables.goalContributions)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      throw ServerException('Failed to add contribution: $e');
    }
  }
}
