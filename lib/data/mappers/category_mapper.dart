import 'package:home_expenses/core/constants/enums.dart';
import 'package:home_expenses/core/utils/date_utils.dart';
import 'package:home_expenses/data/dtos/category_dto.dart';
import 'package:home_expenses/domain/entities/category.dart';

abstract final class CategoryMapper {
  static Category toDomain(CategoryDto dto) {
    return Category(
      id: dto.id,
      householdId: dto.householdId,
      name: dto.name,
      type: TransactionType.fromString(dto.type),
      color: dto.color,
      icon: dto.icon,
      isActive: dto.isActive,
      sortOrder: dto.sortOrder,
      createdAt: dto.createdAt.fromUnix,
      lastUpdate: dto.lastUpdate.fromUnix,
    );
  }

  static CategoryDto toDto(Category entity) {
    return CategoryDto(
      id: entity.id,
      householdId: entity.householdId,
      name: entity.name,
      type: entity.type.value,
      color: entity.color,
      icon: entity.icon,
      isActive: entity.isActive,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt.toUnix,
      lastUpdate: entity.lastUpdate.toUnix,
    );
  }

  static Category fromJson(Map<String, dynamic> json) {
    return toDomain(CategoryDto.fromJson(json));
  }
}
