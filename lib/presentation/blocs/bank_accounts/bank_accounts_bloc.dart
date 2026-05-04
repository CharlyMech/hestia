import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/repositories/bank_account_repository.dart';

abstract class BankAccountsEvent extends Equatable {
  const BankAccountsEvent();
  @override
  List<Object?> get props => const [];
}

class BankAccountsLoad extends BankAccountsEvent {
  final String householdId;
  final String userId;
  const BankAccountsLoad({required this.householdId, required this.userId});
  @override
  List<Object?> get props => [householdId, userId];
}

class BankAccountsRefresh extends BankAccountsEvent {
  const BankAccountsRefresh();
}

abstract class BankAccountsState extends Equatable {
  const BankAccountsState();
  @override
  List<Object?> get props => const [];
}

class BankAccountsInitial extends BankAccountsState {
  const BankAccountsInitial();
}

class BankAccountsLoading extends BankAccountsState {
  const BankAccountsLoading();
}

class BankAccountsLoaded extends BankAccountsState {
  final List<BankAccount> sources;
  const BankAccountsLoaded(this.sources);
  @override
  List<Object?> get props => [sources];

  /// Total balance across all loaded sources, in the source's own currency.
  /// Caller is responsible for currency conversion if mixed.
  double get totalBalance =>
      sources.fold(0, (sum, s) => sum + s.currentBalance);

  List<BankAccount> get shared =>
      sources.where((s) => s.ownerType == OwnerType.shared).toList();
  List<BankAccount> get personal =>
      sources.where((s) => s.ownerType == OwnerType.personal).toList();
}

class BankAccountsError extends BankAccountsState {
  final String message;
  const BankAccountsError(this.message);
  @override
  List<Object?> get props => [message];
}

class BankAccountsBloc extends Bloc<BankAccountsEvent, BankAccountsState> {
  final BankAccountRepository _repo;
  String? _householdId;
  String? _userId;

  BankAccountsBloc(this._repo) : super(const BankAccountsInitial()) {
    on<BankAccountsLoad>(_onLoad);
    on<BankAccountsRefresh>(_onRefresh);
  }

  Future<void> _onLoad(
      BankAccountsLoad e, Emitter<BankAccountsState> emit) async {
    _householdId = e.householdId;
    _userId = e.userId;
    emit(const BankAccountsLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(
      BankAccountsRefresh e, Emitter<BankAccountsState> emit) async {
    if (_householdId == null || _userId == null) return;
    emit(const BankAccountsLoading());
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<BankAccountsState> emit) async {
    final (sources, failure) = await _repo.getBankAccounts(
      householdId: _householdId!,
      viewMode: ViewMode.personal,
      userId: _userId,
    );
    if (failure != null) {
      emit(BankAccountsError(failure.message));
      return;
    }
    emit(BankAccountsLoaded(sources));
  }
}
