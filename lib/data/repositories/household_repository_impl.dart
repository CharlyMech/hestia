import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/services/supabase_service.dart';
import 'package:hestia/domain/entities/household.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/domain/repositories/household_repository.dart';

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

  @override
  Future<(List<Profile>, Failure?)> getMemberProfiles(
      String householdId) async {
    try {
      // members → user ids
      final memberRows = await _service
          .from(SupabaseTables.householdMembers)
          .select('user_id')
          .eq('household_id', householdId);
      final ids =
          (memberRows as List).map((r) => r['user_id'] as String).toList();
      if (ids.isEmpty) return (<Profile>[], null);

      final rows = await _service
          .from(SupabaseTables.profiles)
          .select()
          .inFilter('id', ids);

      final profiles = (rows as List).map((json) {
        return Profile(
          id: json['id'] as String,
          email: json['email'] as String,
          displayName: json['display_name'] as String?,
          avatarUrl: json['avatar_url'] as String?,
          preferredCurrency: json['preferred_currency'] as String? ?? 'EUR',
          calendarColor: json['calendar_color'] as String?,
          birthDate: json['birth_date'] != null
              ? DateTime.tryParse(json['birth_date'] as String)
              : null,
          isSuperuser: json['is_superuser'] as bool? ?? false,
          createdAt: (json['created_at'] as int).fromUnix,
          lastUpdate: (json['last_update'] as int).fromUnix,
        );
      }).toList();
      return (profiles, null);
    } catch (e) {
      return (<Profile>[], mapExceptionToFailure(e));
    }
  }
}
