import 'package:home_expenses/core/constants/enums.dart';
import 'package:home_expenses/core/utils/date_utils.dart';
import 'package:home_expenses/data/dtos/money_source_dto.dart';
import 'package:home_expenses/domain/entities/money_source.dart';

abstract final class MoneySourceMapper {
  static MoneySource toDomain(MoneySourceDto dto) {
    return MoneySource(
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

  static MoneySourceDto toDto(MoneySource entity) {
    return MoneySourceDto(
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

  static MoneySource fromJson(Map<String, dynamic> json) {
    return toDomain(MoneySourceDto.fromJson(json));
  }
}
