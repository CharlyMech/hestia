import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/home.dart';

abstract class HomeRepository {
  Future<(List<Home>, Failure?)> getHomes(
    String householdId, {
    bool activeOnly = true,
  });

  Future<(Home?, Failure?)> getHome(String id);

  Future<(Home?, Failure?)> createHome(Home home);

  Future<Failure?> updateHome(Home home);

  Future<Failure?> deleteHome(String id);
}
