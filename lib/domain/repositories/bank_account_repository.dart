import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/money_source.dart';

abstract class MoneySourceRepository {
  Future<(List<MoneySource>, Failure?)> getMoneySources({
    required String householdId,
    required ViewMode viewMode,
    String? userId,
    bool activeOnly = true,
  });

  Future<(MoneySource?, Failure?)> createMoneySource(MoneySource source);

  Future<Failure?> updateMoneySource(MoneySource source);

  Future<Failure?> deleteMoneySource(String id);
}
