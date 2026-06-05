import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/services/shopping_session_service.dart';
import 'package:hestia/domain/entities/shopping_session.dart';
import 'package:hestia/domain/repositories/shopping_session_repository.dart';

class ShoppingSessionRepositoryImpl implements ShoppingSessionRepository {
  final ShoppingSessionService _service;
  ShoppingSessionRepositoryImpl(this._service);

  ShoppingSession _fromJson(Map<String, dynamic> j) => ShoppingSession(
        id: j['id'] as String,
        householdId: j['household_id'] as String,
        startedAt: (j['started_at'] as num).toInt(), // unix millis
        endedAt: (j['ended_at'] as num?)?.toInt(),
        listId: j['list_id'] as String?,
        bankAccountId: j['bank_account_id'] as String?,
        transactionId: j['transaction_id'] as String?,
        status: ShoppingSessionStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => ShoppingSessionStatus.active,
        ),
      );

  Map<String, dynamic> _toJson(ShoppingSession s) => {
        'household_id': s.householdId,
        'started_at': s.startedAt,
        'ended_at': s.endedAt,
        'list_id': s.listId,
        'bank_account_id': s.bankAccountId,
        'transaction_id': s.transactionId,
        'status': s.status.name,
      };

  @override
  Future<(List<ShoppingSession>, Failure?)> getSessions({
    required String householdId,
    ShoppingSessionStatus? status,
    int limit = 50,
  }) async {
    if (householdId.isEmpty) return (const <ShoppingSession>[], null);
    try {
      final data = await _service.getSessions(
        householdId: householdId,
        status: status?.name,
        limit: limit,
      );
      return (data.map(_fromJson).toList(), null);
    } catch (e, st) {
      return (<ShoppingSession>[], reportError(e, st, reason: 'getSessions'));
    }
  }

  @override
  Future<(ShoppingSession?, Failure?)> getSession(String id) async {
    try {
      final data = await _service.getSession(id);
      return (data == null ? null : _fromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'getSession'));
    }
  }

  @override
  Future<(ShoppingSession?, Failure?)> createSession(
      ShoppingSession session) async {
    try {
      final data = await _service.create(_toJson(session));
      return (_fromJson(data), null);
    } catch (e, st) {
      return (null, reportError(e, st, reason: 'createSession'));
    }
  }

  @override
  Future<Failure?> updateSession(ShoppingSession session) async {
    try {
      await _service.update(session.id, _toJson(session));
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'updateSession');
    }
  }

  @override
  Future<Failure?> deleteSession(String id) async {
    try {
      await _service.delete(id);
      return null;
    } catch (e, st) {
      return reportError(e, st, reason: 'deleteSession');
    }
  }
}
