import 'package:home_expenses/core/error/failures.dart';
import 'package:home_expenses/domain/entities/household.dart';

abstract class HouseholdRepository {
  Future<(Household?, Failure?)> getCurrentHousehold(String userId);

  Future<(List<HouseholdMember>, Failure?)> getMembers(String householdId);
}
