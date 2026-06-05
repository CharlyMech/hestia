import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/financial_institution.dart';

abstract class FinancialInstitutionRepository {
  Future<(List<FinancialInstitution>, Failure?)> getAll();

  Future<(FinancialInstitution?, Failure?)> getById(String id);

  Future<(FinancialInstitution?, Failure?)> create(FinancialInstitution institution);

  Future<Failure?> update(FinancialInstitution institution);

  Future<Failure?> delete(String id);
}
