import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/household.dart';

abstract class HouseholdRepository {
  Future<(Household?, Failure?)> getCurrentHousehold(String userId);

  Future<(List<HouseholdMember>, Failure?)> getMembers(String householdId);
}
