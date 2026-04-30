import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/category.dart';
import 'package:hestia/domain/repositories/category_repository.dart';
import 'package:uuid/uuid.dart';

class MockCategoryRepository implements CategoryRepository {
  static const _uuid = Uuid();

  @override
  Future<(List<Category>, Failure?)> getCategories({
    required String householdId,
    TransactionType? type,
    bool activeOnly = true,
  }) async {
    final list = MockStore.instance.categories
        .where((c) => c.householdId == householdId)
        .where((c) => !activeOnly || c.isActive)
        .where((c) => type == null || c.type == type)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return (list, null);
  }

  @override
  Future<(Category?, Failure?)> createCategory(Category category) async {
    final created = Category(
      id: _uuid.v4(),
      householdId: category.householdId,
      name: category.name,
      type: category.type,
      color: category.color,
      icon: category.icon,
      isActive: category.isActive,
      sortOrder: category.sortOrder,
      createdAt: DateTime.now(),
      lastUpdate: DateTime.now(),
    );
    MockStore.instance.categories.add(created);
    return (created, null);
  }

  @override
  Future<Failure?> updateCategory(Category category) async {
    final list = MockStore.instance.categories;
    final i = list.indexWhere((c) => c.id == category.id);
    if (i < 0) return const ServerFailure('Category not found');
    list[i] = Category(
      id: category.id,
      householdId: category.householdId,
      name: category.name,
      type: category.type,
      color: category.color,
      icon: category.icon,
      isActive: category.isActive,
      sortOrder: category.sortOrder,
      createdAt: category.createdAt,
      lastUpdate: DateTime.now(),
    );
    return null;
  }

  @override
  Future<Failure?> deleteCategory(String id) async {
    MockStore.instance.categories.removeWhere((c) => c.id == id);
    return null;
  }
}
