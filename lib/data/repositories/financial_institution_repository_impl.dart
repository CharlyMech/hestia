import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mappers/financial_institution_mapper.dart';
import 'package:hestia/data/services/financial_institution_service.dart';
import 'package:hestia/domain/entities/financial_institution.dart';
import 'package:hestia/domain/repositories/financial_institution_repository.dart';

class FinancialInstitutionRepositoryImpl
    implements FinancialInstitutionRepository {
  final FinancialInstitutionService _service;

  FinancialInstitutionRepositoryImpl(this._service);

  @override
  Future<(List<FinancialInstitution>, Failure?)> getAll() async {
    try {
      final data = await _service.getAll();
      final institutions =
          data.map(FinancialInstitutionMapper.fromJson).toList();
      return (institutions, null);
    } catch (e) {
      return (const <FinancialInstitution>[], mapExceptionToFailure(e));
    }
  }

  @override
  Future<(FinancialInstitution?, Failure?)> getById(String id) async {
    try {
      final data = await _service.getById(id);
      return (FinancialInstitutionMapper.fromJson(data), null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }

  @override
  Future<(FinancialInstitution?, Failure?)> create(
      FinancialInstitution institution) async {
    try {
      final dto = FinancialInstitutionMapper.toDto(institution);
      final data = await _service.create(dto.toInsertJson());
      return (FinancialInstitutionMapper.fromJson(data), null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }

  @override
  Future<Failure?> update(FinancialInstitution institution) async {
    try {
      final dto = FinancialInstitutionMapper.toDto(institution);
      await _service.update(institution.id, dto.toUpdateJson());
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> delete(String id) async {
    try {
      await _service.delete(id);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}
