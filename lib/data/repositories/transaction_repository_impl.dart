import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/mappers/transaction_mapper.dart';
import 'package:hestia/data/services/transaction_service.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transfer.dart';
import 'package:hestia/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionService _service;

  TransactionRepositoryImpl(this._service);

  @override
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
  }) async {
    try {
      final effectiveUserId = viewMode == ViewMode.personal ? userId : null;

      final data = await _service.getTransactions(
        householdId: householdId,
        userId: effectiveUserId,
        startDate: startDate?.toUnix,
        endDate: endDate?.toUnix,
        categoryId: categoryId,
        moneySourceId: moneySourceId,
        type: type?.value,
        limit: limit,
        offset: offset,
      );

      final transactions = data.map(TransactionMapper.fromJson).toList();
      return (transactions, null);
    } catch (e) {
      return (<Transaction>[], mapExceptionToFailure(e));
    }
  }

  @override
  Future<(Transaction?, Failure?)> createTransaction(
      Transaction transaction) async {
    try {
      final dto = TransactionMapper.toDto(transaction);
      final data = await _service.createTransaction(dto.toInsertJson());
      final created = TransactionMapper.fromJson(data);
      return (created, null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }

  @override
  Future<Failure?> updateTransaction(Transaction transaction) async {
    try {
      final dto = TransactionMapper.toDto(transaction);
      await _service.updateTransaction(transaction.id, dto.toUpdateJson());
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> deleteTransaction(String id) async {
    try {
      await _service.deleteTransaction(id);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<(List<Transfer>, Failure?)> getTransfers({
    required String householdId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final data = await _service.getTransfers(
        householdId: householdId,
        startDate: startDate?.toUnix,
        endDate: endDate?.toUnix,
      );
      final transfers = data.map(TransactionMapper.transferFromJson).toList();
      return (transfers, null);
    } catch (e) {
      return (<Transfer>[], mapExceptionToFailure(e));
    }
  }

  @override
  Future<(Transfer?, Failure?)> createTransfer(Transfer transfer) async {
    try {
      final data = await _service.createTransfer({
        'household_id': transfer.householdId,
        'user_id': transfer.userId,
        'from_source_id': transfer.fromSourceId,
        'to_source_id': transfer.toSourceId,
        'amount': transfer.amount,
        'note': transfer.note,
        'date': transfer.date.toUnix,
      });
      final created = TransactionMapper.transferFromJson(data);
      return (created, null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }
}
