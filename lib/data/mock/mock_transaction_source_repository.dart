import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_latency.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/domain/repositories/transaction_source_repository.dart';
import 'package:uuid/uuid.dart';

class MockTransactionSourceRepository implements TransactionSourceRepository {
  static const _uuid = Uuid();

  @override
  Future<(List<TransactionSource>, Failure?)> getAll({
    required String householdId,
    bool activeOnly = true,
  }) async {
    await mockReadLatency();
    final list = MockStore.instance.transactionSources
        .where((s) => s.householdId == householdId)
        .where((s) => !activeOnly || s.isActive)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return (list, null);
  }

  @override
  Future<(TransactionSource?, Failure?)> create(TransactionSource source) async {
    final created = source.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      lastUpdate: DateTime.now(),
    );
    MockStore.instance.transactionSources.add(created);
    return (created, null);
  }

  @override
  Future<Failure?> update(TransactionSource source) async {
    final list = MockStore.instance.transactionSources;
    final i = list.indexWhere((s) => s.id == source.id);
    if (i < 0) return const ServerFailure('Transaction source not found');
    list[i] = source.copyWith(lastUpdate: DateTime.now());
    return null;
  }

  @override
  Future<Failure?> delete(String id) async {
    MockStore.instance.transactionSources.removeWhere((s) => s.id == id);
    return null;
  }
}
