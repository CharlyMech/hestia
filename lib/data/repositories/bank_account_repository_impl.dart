import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mappers/bank_account_mapper.dart';
import 'package:hestia/data/services/bank_account_service.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/repositories/bank_account_repository.dart';

class BankAccountRepositoryImpl implements BankAccountRepository {
  final BankAccountService _service;

  BankAccountRepositoryImpl(this._service);

  @override
  Future<(List<BankAccount>, Failure?)> getBankAccounts({
    required String householdId,
    required ViewMode viewMode,
    String? userId,
    bool activeOnly = true,
  }) async {
    try {
      final data = await _service.getBankAccounts(
        householdId: householdId,
        activeOnly: activeOnly,
      );

      var sources = data.map(BankAccountMapper.fromJson).toList();

      // Apply view mode filtering in Dart (RLS already gives us access)
      if (viewMode == ViewMode.personal && userId != null) {
        sources = sources
            .where(
                (s) => s.ownerType == OwnerType.shared || s.ownerId == userId)
            .toList();
      }

      return (sources, null);
    } catch (e) {
      return (<BankAccount>[], mapExceptionToFailure(e));
    }
  }

  @override
  Future<(BankAccount?, Failure?)> createBankAccount(BankAccount source) async {
    try {
      final dto = BankAccountMapper.toDto(source);
      final data = await _service.createBankAccount(dto.toInsertJson());
      final created = BankAccountMapper.fromJson(data);
      return (created, null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }

  @override
  Future<Failure?> updateBankAccount(BankAccount source) async {
    try {
      final dto = BankAccountMapper.toDto(source);
      await _service.updateBankAccount(source.id, dto.toUpdateJson());
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> deleteBankAccount(String id) async {
    try {
      await _service.deleteBankAccount(id);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}
