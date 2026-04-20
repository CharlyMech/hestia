import 'package:home_expenses/core/constants/supabase_tables.dart';
import 'package:home_expenses/core/error/error_handler.dart';
import 'package:home_expenses/core/error/failures.dart';
import 'package:home_expenses/core/utils/date_utils.dart';
import 'package:home_expenses/data/services/supabase_service.dart';
import 'package:home_expenses/domain/entities/household.dart';
import 'package:home_expenses/domain/repositories/household_repository.dart';

class HouseholdRepositoryImpl implements HouseholdRepository {
  final SupabaseService _service;

  HouseholdRepositoryImpl(this._service);

  @override
  Future<(Household?, Failure?)> getCurrentHousehold(String userId) async {
    try {
      // Find user's household membership
      final memberData = await _service
          .from(SupabaseTables.householdMembers)
          .select('household_id')
          .eq('user_id', userId)
          .limit(1)
          .maybeSingle();

      if (memberData == null) return (null, null); // No household yet

      final householdId = memberData['household_id'] as String;

      final data = await _service
          .from(SupabaseTables.households)
          .select()
          .eq('id', householdId)
          .single();

      final household = Household(
        id: data['id'] as String,
        name: data['name'] as String,
        createdBy: data['created_by'] as String?,
        createdAt: (data['created_at'] as int).fromUnix,
        lastUpdate: (data['last_update'] as int).fromUnix,
      );

      return (household, null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }

  @override
  Future<(List<HouseholdMember>, Failure?)> getMembers(
      String householdId) async {
    try {
      final data = await _service
          .from(SupabaseTables.householdMembers)
          .select()
          .eq('household_id', householdId);

      final members = (data as List).map((json) {
        return HouseholdMember(
          id: json['id'] as String,
          userId: json['user_id'] as String,
          householdId: json['household_id'] as String,
          role: json['role'] as String,
          createdAt: (json['created_at'] as int).fromUnix,
        );
      }).toList();

      return (members, null);
    } catch (e) {
      return (<HouseholdMember>[], mapExceptionToFailure(e));
    }
  }
}
