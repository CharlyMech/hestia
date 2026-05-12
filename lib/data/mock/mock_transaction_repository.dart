import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_latency.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transfer.dart';
import 'package:hestia/domain/repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

class MockTransactionRepository implements TransactionRepository {
  static const _uuid = Uuid();

  @override
  Future<(List<Transaction>, Failure?)> getTransactions({
    required String householdId,
    required ViewMode viewMode,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? bankAccountId,
    TransactionType? type,
    int limit = 50,
    int offset = 0,
  }) async {
    await mockReadLatency();
    final all = MockStore.instance.transactions
        .where((t) => t.householdId == householdId)
        .where((t) =>
            viewMode == ViewMode.household ||
            userId == null ||
            t.userId == userId)
        .where((t) => startDate == null || !t.date.isBefore(startDate))
        .where((t) => endDate == null || !t.date.isAfter(endDate))
        .where((t) => categoryId == null || t.categoryId == categoryId)
        .where((t) => bankAccountId == null || t.bankAccountId == bankAccountId)
        .where((t) => type == null || t.type == type)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final paged = all.skip(offset).take(limit).toList();
    return (paged, null);
  }

  @override
  Future<(Transaction?, Failure?)> createTransaction(
      Transaction transaction) async {
    final store = MockStore.instance;
    final cat = store.categories
        .where((c) => c.id == transaction.categoryId)
        .firstOrNull;
    final ms = store.bankAccounts
        .where((m) => m.id == transaction.bankAccountId)
        .firstOrNull;
    final user =
        store.profiles.where((p) => p.id == transaction.userId).firstOrNull;
    final txSrc = transaction.transactionSourceId == null
        ? null
        : store.transactionSources
            .where((s) => s.id == transaction.transactionSourceId)
            .firstOrNull;

    final created = Transaction(
      id: _uuid.v4(),
      householdId: transaction.householdId,
      userId: transaction.userId,
      categoryId: transaction.categoryId,
      bankAccountId: transaction.bankAccountId,
      transactionSourceId: transaction.transactionSourceId,
      amount: transaction.amount,
      type: transaction.type,
      note: transaction.note,
      date: transaction.date,
      isRecurring: transaction.isRecurring,
      recurringRule: transaction.recurringRule,
      createdAt: DateTime.now(),
      lastUpdate: DateTime.now(),
      latitude: transaction.latitude,
      longitude: transaction.longitude,
      categoryName: cat?.name,
      categoryColor: cat?.color,
      bankAccountName: ms?.name,
      transactionSourceName: txSrc?.name,
      userName: user?.displayName,
    );
    store.transactions.add(created);
    return (created, null);
  }

  @override
  Future<Failure?> updateTransaction(Transaction transaction) async {
    final store = MockStore.instance;
    final i = store.transactions.indexWhere((t) => t.id == transaction.id);
    if (i < 0) return const ServerFailure('Transaction not found');
    final cat = store.categories
        .where((c) => c.id == transaction.categoryId)
        .firstOrNull;
    final ms = store.bankAccounts
        .where((m) => m.id == transaction.bankAccountId)
        .firstOrNull;
    final user =
        store.profiles.where((p) => p.id == transaction.userId).firstOrNull;
    final txSrc = transaction.transactionSourceId == null
        ? null
        : store.transactionSources
            .where((s) => s.id == transaction.transactionSourceId)
            .firstOrNull;
    store.transactions[i] = Transaction(
      id: transaction.id,
      householdId: transaction.householdId,
      userId: transaction.userId,
      categoryId: transaction.categoryId,
      bankAccountId: transaction.bankAccountId,
      transactionSourceId: transaction.transactionSourceId,
      amount: transaction.amount,
      type: transaction.type,
      note: transaction.note,
      date: transaction.date,
      isRecurring: transaction.isRecurring,
      recurringRule: transaction.recurringRule,
      createdAt: transaction.createdAt,
      lastUpdate: DateTime.now(),
      latitude: transaction.latitude,
      longitude: transaction.longitude,
      categoryName: cat?.name,
      categoryColor: cat?.color,
      bankAccountName: ms?.name,
      transactionSourceName: txSrc?.name,
      userName: user?.displayName,
    );
    return null;
  }

  @override
  Future<Failure?> deleteTransaction(String id) async {
    MockStore.instance.transactions.removeWhere((t) => t.id == id);
    return null;
  }

  @override
  Future<(List<Transfer>, Failure?)> getTransfers({
    required String householdId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final list = MockStore.instance.transfers
        .where((t) => t.householdId == householdId)
        .where((t) => startDate == null || !t.date.isBefore(startDate))
        .where((t) => endDate == null || !t.date.isAfter(endDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return (list, null);
  }

  @override
  Future<(Transfer?, Failure?)> createTransfer(Transfer transfer) async {
    final store = MockStore.instance;
    final from = store.bankAccounts
        .where((m) => m.id == transfer.fromSourceId)
        .firstOrNull;
    final to = store.bankAccounts
        .where((m) => m.id == transfer.toSourceId)
        .firstOrNull;
    final created = Transfer(
      id: _uuid.v4(),
      householdId: transfer.householdId,
      userId: transfer.userId,
      fromSourceId: transfer.fromSourceId,
      toSourceId: transfer.toSourceId,
      amount: transfer.amount,
      note: transfer.note,
      date: transfer.date,
      createdAt: DateTime.now(),
      lastUpdate: DateTime.now(),
      fromSourceName: from?.name,
      toSourceName: to?.name,
    );
    store.transfers.add(created);
    return (created, null);
  }
}
