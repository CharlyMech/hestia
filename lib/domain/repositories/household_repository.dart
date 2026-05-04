import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/household.dart';
import 'package:hestia/domain/entities/profile.dart';

abstract class HouseholdRepository {
  Future<(Household?, Failure?)> getCurrentHousehold(String userId);

  Future<(List<HouseholdMember>, Failure?)> getMembers(String householdId);

  /// Profiles for every member of [householdId]. Used when the UI needs
  /// per-user attributes (e.g. calendar color) and not just member roles.
  Future<(List<Profile>, Failure?)> getMemberProfiles(String householdId);
}
