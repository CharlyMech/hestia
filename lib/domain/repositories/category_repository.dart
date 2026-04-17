import 'package:home_expenses/core/constants/enums.dart';
import 'package:home_expenses/core/error/failures.dart';
import 'package:home_expenses/domain/entities/category.dart';

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
