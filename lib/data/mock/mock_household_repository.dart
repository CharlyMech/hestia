import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_seed.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/household.dart';
import 'package:hestia/domain/repositories/household_repository.dart';

class MockHouseholdRepository implements HouseholdRepository {
  @override
  Future<(Household?, Failure?)> getCurrentHousehold(String userId) async {
    MockSeed.load();
    return (MockStore.instance.household, null);
  }

  @override
  Future<(List<HouseholdMember>, Failure?)> getMembers(String householdId) async {
    final list = MockStore.instance.members
        .where((m) => m.householdId == householdId)
        .toList();
    return (list, null);
  }
}
