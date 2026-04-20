import 'package:home_expenses/core/constants/enums.dart';
import 'package:home_expenses/core/error/error_handler.dart';
import 'package:home_expenses/core/error/failures.dart';
import 'package:home_expenses/data/mappers/category_mapper.dart';
import 'package:home_expenses/data/services/category_service.dart';
import 'package:home_expenses/domain/entities/category.dart';
import 'package:home_expenses/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryService _service;

  CategoryRepositoryImpl(this._service);

  @override
  Future<(List<Category>, Failure?)> getCategories({
    required String householdId,
    TransactionType? type,
    bool activeOnly = true,
  }) async {
    try {
      final data = await _service.getCategories(
        householdId: householdId,
        type: type?.value,
        activeOnly: activeOnly,
      );
      final categories = data.map(CategoryMapper.fromJson).toList();
      return (categories, null);
    } catch (e) {
      return (<Category>[], mapExceptionToFailure(e));
    }
  }

  @override
  Future<(Category?, Failure?)> createCategory(Category category) async {
    try {
      final dto = CategoryMapper.toDto(category);
      final data = await _service.createCategory(dto.toInsertJson());
      final created = CategoryMapper.fromJson(data);
      return (created, null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }

  @override
  Future<Failure?> updateCategory(Category category) async {
    try {
      final dto = CategoryMapper.toDto(category);
      await _service.updateCategory(category.id, dto.toUpdateJson());
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> deleteCategory(String id) async {
    try {
      await _service.deleteCategory(id);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}
