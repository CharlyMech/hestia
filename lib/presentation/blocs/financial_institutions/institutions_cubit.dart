import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/financial_institution.dart';
import 'package:hestia/domain/repositories/financial_institution_repository.dart';

class InstitutionsCubit extends Cubit<List<FinancialInstitution>> {
  final FinancialInstitutionRepository _repo;

  InstitutionsCubit(this._repo) : super(const []);

  Future<void> load() async {
    final (institutions, _) = await _repo.getAll();
    emit(institutions);
  }

  FinancialInstitution? findBySlug(String slug) {
    try {
      return state.firstWhere((i) => i.slug == slug);
    } catch (_) {
      return null;
    }
  }

  FinancialInstitution? findById(String id) {
    try {
      return state.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}
