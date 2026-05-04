import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/bank_account.dart';

abstract class BankAccountRepository {
  Future<(List<BankAccount>, Failure?)> getBankAccounts({
    required String householdId,
    required ViewMode viewMode,
    String? userId,
    bool activeOnly = true,
  });

  Future<(BankAccount?, Failure?)> createBankAccount(BankAccount source);

  Future<Failure?> updateBankAccount(BankAccount source);

  Future<Failure?> deleteBankAccount(String id);
}
