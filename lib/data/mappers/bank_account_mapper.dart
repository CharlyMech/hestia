import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/dtos/bank_account_dto.dart';
import 'package:hestia/domain/entities/bank_account.dart';

abstract final class BankAccountMapper {
  static BankAccount toDomain(BankAccountDto dto) {
    return BankAccount(
      id: dto.id,
      householdId: dto.householdId,
      ownerType: OwnerType.fromString(dto.ownerType),
      ownerId: dto.ownerId,
      name: dto.name,
      institution: dto.institution,
      accountType: AccountType.fromString(dto.accountType),
      currency: dto.currency,
      initialBalance: dto.initialBalance.toDouble(),
      currentBalance: dto.currentBalance.toDouble(),
      isPrimary: dto.isPrimary,
      isActive: dto.isActive,
      color: dto.color,
      icon: dto.icon,
      sortOrder: dto.sortOrder,
      createdAt: dto.createdAt.fromUnix,
      lastUpdate: dto.lastUpdate.fromUnix,
    );
  }

  static BankAccountDto toDto(BankAccount entity) {
    return BankAccountDto(
      id: entity.id,
      householdId: entity.householdId,
      ownerType: entity.ownerType.value,
      ownerId: entity.ownerId,
      name: entity.name,
      institution: entity.institution,
      accountType: entity.accountType.value,
      currency: entity.currency,
      initialBalance: entity.initialBalance,
      currentBalance: entity.currentBalance,
      isPrimary: entity.isPrimary,
      isActive: entity.isActive,
      color: entity.color,
      icon: entity.icon,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt.toUnix,
      lastUpdate: entity.lastUpdate.toUnix,
    );
  }

  static BankAccount fromJson(Map<String, dynamic> json) {
    return toDomain(BankAccountDto.fromJson(json));
  }
}
