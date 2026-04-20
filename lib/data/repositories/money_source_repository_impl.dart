import 'package:home_expenses/core/constants/enums.dart';
import 'package:home_expenses/core/error/error_handler.dart';
import 'package:home_expenses/core/error/failures.dart';
import 'package:home_expenses/data/mappers/money_source_mapper.dart';
import 'package:home_expenses/data/services/money_source_service.dart';
import 'package:home_expenses/domain/entities/money_source.dart';
import 'package:home_expenses/domain/repositories/money_source_repository.dart';

class MoneySourceRepositoryImpl implements MoneySourceRepository {
  final MoneySourceService _service;

  MoneySourceRepositoryImpl(this._service);

  @override
  Future<(List<MoneySource>, Failure?)> getMoneySources({
    required String householdId,
    required ViewMode viewMode,
    String? userId,
    bool activeOnly = true,
  }) async {
    try {
      final data = await _service.getMoneySources(
        householdId: householdId,
        activeOnly: activeOnly,
      );

      var sources = data.map(MoneySourceMapper.fromJson).toList();

      // Apply view mode filtering in Dart (RLS already gives us access)
      if (viewMode == ViewMode.personal && userId != null) {
        sources = sources
            .where(
                (s) => s.ownerType == OwnerType.shared || s.ownerId == userId)
            .toList();
      }

      return (sources, null);
    } catch (e) {
      return (<MoneySource>[], mapExceptionToFailure(e));
    }
  }

  @override
  Future<(MoneySource?, Failure?)> createMoneySource(MoneySource source) async {
    try {
      final dto = MoneySourceMapper.toDto(source);
      final data = await _service.createMoneySource(dto.toInsertJson());
      final created = MoneySourceMapper.fromJson(data);
      return (created, null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }

  @override
  Future<Failure?> updateMoneySource(MoneySource source) async {
    try {
      final dto = MoneySourceMapper.toDto(source);
      await _service.updateMoneySource(source.id, dto.toUpdateJson());
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> deleteMoneySource(String id) async {
    try {
      await _service.deleteMoneySource(id);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}
