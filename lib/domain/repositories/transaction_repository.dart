import 'package:home_expenses/core/constants/enums.dart';
import 'package:home_expenses/core/error/failures.dart';
import 'package:home_expenses/domain/entities/transaction.dart';
import 'package:home_expenses/domain/entities/transfer.dart';

abstract class TransactionRepository {
  Future<(List<Transaction>, Failure?)> getTransactions({
    required String householdId,
    required ViewMode viewMode,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? moneySourceId,
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
