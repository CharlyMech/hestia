import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/dtos/financial_institution_dto.dart';
import 'package:hestia/domain/entities/financial_institution.dart';

abstract final class FinancialInstitutionMapper {
  static FinancialInstitution toDomain(FinancialInstitutionDto dto) {
    return FinancialInstitution(
      id: dto.id,
      name: dto.name,
      slug: dto.slug,
      country: dto.country,
      brandColor: dto.brandColor,
      logoAsset: dto.logoAsset,
      institutionType: InstitutionType.fromString(dto.institutionType),
      isCustom: dto.isCustom,
    );
  }

  static FinancialInstitutionDto toDto(FinancialInstitution entity) {
    return FinancialInstitutionDto(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      country: entity.country,
      brandColor: entity.brandColor,
      logoAsset: entity.logoAsset,
      institutionType: entity.institutionType.value,
      isCustom: entity.isCustom,
      createdAt: DateTime.now().toUnix,
      lastUpdate: DateTime.now().toUnix,
    );
  }

  static FinancialInstitution fromJson(Map<String, dynamic> json) {
    return toDomain(FinancialInstitutionDto.fromJson(json));
  }
}
