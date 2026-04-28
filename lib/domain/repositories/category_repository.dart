import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<(List<Category>, Failure?)> getCategories({
    required String householdId,
    TransactionType? type,
    bool activeOnly = true,
  });

  Future<(Category?, Failure?)> createCategory(Category category);

  Future<Failure?> updateCategory(Category category);

  Future<Failure?> deleteCategory(String id);
}
