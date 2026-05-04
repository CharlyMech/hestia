import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/transaction_source.dart';

abstract class TransactionSourceRepository {
  Future<(List<TransactionSource>, Failure?)> getAll({
    required String householdId,
    bool activeOnly = true,
  });

  Future<(TransactionSource?, Failure?)> create(TransactionSource source);

  Future<Failure?> update(TransactionSource source);

  Future<Failure?> delete(String id);
}
