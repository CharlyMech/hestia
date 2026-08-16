import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/dtos/card_dto.dart';
import 'package:hestia/domain/entities/payment_card.dart';

abstract final class CardMapper {
  static PaymentCard toDomain(CardDto dto) {
    final account = dto.bankAccounts;
    final institution =
        account?['financial_institutions'] as Map<String, dynamic>?;

    return PaymentCard(
      id: dto.id,
      accountId: dto.accountId,
      network: CardNetwork.fromString(dto.network),
      last4: dto.last4,
      expiryMonth: dto.expiryMonth,
      expiryYear: dto.expiryYear,
      cardholderName: dto.cardholderName,
      isVirtual: dto.isVirtual,
      isActive: dto.isActive,
      color: dto.color,
      sortOrder: dto.sortOrder,
      createdAt: dto.createdAt.fromUnix,
      lastUpdate: dto.lastUpdate.fromUnix,
      institutionName: institution?['name'] as String?,
      institutionLogoAsset: institution?['logo_asset'] as String?,
      institutionBrandColor: institution?['brand_color'] as String?,
    );
  }

  static CardDto toDto(PaymentCard entity) {
    return CardDto(
      id: entity.id,
      accountId: entity.accountId,
      network: entity.network.value,
      last4: entity.last4,
      expiryMonth: entity.expiryMonth,
      expiryYear: entity.expiryYear,
      cardholderName: entity.cardholderName,
      isVirtual: entity.isVirtual,
      isActive: entity.isActive,
      color: entity.color,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt.toUnix,
      lastUpdate: entity.lastUpdate.toUnix,
    );
  }

  static PaymentCard fromJson(Map<String, dynamic> json) {
    return toDomain(CardDto.fromJson(json));
  }
}
