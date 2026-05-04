import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_seed.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/household.dart';
import 'package:hestia/domain/entities/profile.dart';
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

  @override
  Future<(List<Profile>, Failure?)> getMemberProfiles(
      String householdId) async {
    final memberIds = MockStore.instance.members
        .where((m) => m.householdId == householdId)
        .map((m) => m.userId)
        .toSet();
    final profiles = MockStore.instance.profiles
        .where((p) => memberIds.contains(p.id))
        .toList();
    return (profiles, null);
  }
}
