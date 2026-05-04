import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transfer.dart';

abstract class TransactionRepository {
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
  });

  Future<(Transaction?, Failure?)> createTransaction(Transaction transaction);

  Future<Failure?> updateTransaction(Transaction transaction);

  Future<Failure?> deleteTransaction(String id);

  Future<(List<Transfer>, Failure?)> getTransfers({
    required String householdId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<(Transfer?, Failure?)> createTransfer(Transfer transfer);
}
