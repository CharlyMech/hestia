import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/shopping_session.dart';

abstract class ShoppingSessionRepository {
  Future<(List<ShoppingSession>, Failure?)> getSessions({
    required String householdId,
    ShoppingSessionStatus? status,
    int limit = 50,
  });

  Future<(ShoppingSession?, Failure?)> getSession(String id);

  Future<(ShoppingSession?, Failure?)> createSession(ShoppingSession session);

  Future<Failure?> updateSession(ShoppingSession session);

  Future<Failure?> deleteSession(String id);
}
