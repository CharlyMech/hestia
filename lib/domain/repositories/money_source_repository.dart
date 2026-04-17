import 'package:home_expenses/core/constants/enums.dart';
import 'package:home_expenses/core/error/failures.dart';
import 'package:home_expenses/domain/entities/money_source.dart';

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
