import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_latency.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/repositories/bank_account_repository.dart';
import 'package:uuid/uuid.dart';

class MockBankAccountRepository implements BankAccountRepository {
  static const _uuid = Uuid();

  @override
  Future<(List<BankAccount>, Failure?)> getBankAccounts({
    required String householdId,
    required ViewMode viewMode,
    String? userId,
    bool activeOnly = true,
  }) async {
    await mockReadLatency();
    final list = MockStore.instance.bankAccounts
        .where((s) => s.householdId == householdId)
        .where((s) => !activeOnly || s.isActive)
        .where((s) {
      if (viewMode == ViewMode.household) return true;
      if (s.ownerType == OwnerType.shared) return true;
      return userId == null || s.ownerId == userId;
    }).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return (list, null);
  }

  @override
  Future<(BankAccount?, Failure?)> createBankAccount(BankAccount source) async {
    final created = _copy(source,
        id: _uuid.v4(), createdAt: DateTime.now(), lastUpdate: DateTime.now());
    MockStore.instance.bankAccounts.add(created);
    return (created, null);
  }

  @override
  Future<Failure?> updateBankAccount(BankAccount source) async {
    final list = MockStore.instance.bankAccounts;
    final i = list.indexWhere((s) => s.id == source.id);
    if (i < 0) return const ServerFailure('Money source not found');
    list[i] = _copy(source, lastUpdate: DateTime.now());
    return null;
  }

  @override
  Future<Failure?> deleteBankAccount(String id) async {
    MockStore.instance.bankAccounts.removeWhere((s) => s.id == id);
    return null;
  }

  BankAccount _copy(
    BankAccount s, {
    String? id,
    DateTime? createdAt,
    DateTime? lastUpdate,
  }) =>
      BankAccount(
        id: id ?? s.id,
        householdId: s.householdId,
        ownerType: s.ownerType,
        ownerId: s.ownerId,
        name: s.name,
        institution: s.institution,
        accountType: s.accountType,
        currency: s.currency,
        initialBalance: s.initialBalance,
        currentBalance: s.currentBalance,
        isPrimary: s.isPrimary,
        isActive: s.isActive,
        color: s.color,
        icon: s.icon,
        sortOrder: s.sortOrder,
        createdAt: createdAt ?? s.createdAt,
        lastUpdate: lastUpdate ?? s.lastUpdate,
      );
}
