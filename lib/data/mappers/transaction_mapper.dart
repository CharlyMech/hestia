import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/dtos/transaction_dto.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transfer.dart';

abstract final class TransactionMapper {
  /// DTO → Domain Entity
  static Transaction toDomain(TransactionDto dto) {
    return Transaction(
      id: dto.id,
      householdId: dto.householdId,
      userId: dto.userId,
      categoryId: dto.categoryId,
      bankAccountId: dto.bankAccountId,
      transactionSourceId: dto.transactionSourceId,
      amount: dto.amount.toDouble(),
      type: TransactionType.fromString(dto.type),
      note: dto.note,
      date: dto.date.fromUnix,
      isRecurring: dto.isRecurring,
      recurringRule: dto.recurringRule,
      createdAt: dto.createdAt.fromUnix,
      lastUpdate: dto.lastUpdate.fromUnix,
      categoryName: dto.categories?['name'] as String?,
      categoryColor: dto.categories?['color'] as String?,
      bankAccountName: dto.bankAccounts?['name'] as String?,
      transactionSourceName: dto.transactionSources?['name'] as String?,
      userName: dto.profiles?['display_name'] as String? ??
          dto.profiles?['email'] as String?,
    );
  }

  /// Domain Entity → DTO (for inserts)
  static TransactionDto toDto(Transaction entity) {
    return TransactionDto(
      id: entity.id,
      householdId: entity.householdId,
      userId: entity.userId,
      categoryId: entity.categoryId,
      bankAccountId: entity.bankAccountId,
      transactionSourceId: entity.transactionSourceId,
      amount: entity.amount,
      type: entity.type.value,
      note: entity.note,
      date: entity.date.toUnix,
      isRecurring: entity.isRecurring,
      recurringRule: entity.recurringRule,
      createdAt: entity.createdAt.toUnix,
      lastUpdate: entity.lastUpdate.toUnix,
    );
  }

  /// Raw JSON → Domain Entity (shortcut)
  static Transaction fromJson(Map<String, dynamic> json) {
    return toDomain(TransactionDto.fromJson(json));
  }

  /// Transfer from raw JSON
  static Transfer transferFromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      userId: json['user_id'] as String,
      fromSourceId: json['from_source_id'] as String,
      toSourceId: json['to_source_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      date: (json['date'] as int).fromUnix,
      createdAt: (json['created_at'] as int).fromUnix,
      lastUpdate: (json['last_update'] as int).fromUnix,
      fromSourceName:
          (json['from_source'] as Map<String, dynamic>?)?['name'] as String?,
      toSourceName:
          (json['to_source'] as Map<String, dynamic>?)?['name'] as String?,
    );
  }
}
