import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/domain/repositories/goal_repository.dart';

abstract class GoalsEvent extends Equatable {
  const GoalsEvent();
  @override
  List<Object?> get props => const [];
}

class GoalsLoad extends GoalsEvent {
  final String householdId;
  final String userId;
  const GoalsLoad({required this.householdId, required this.userId});
  @override
  List<Object?> get props => [householdId, userId];
}

class GoalsRefresh extends GoalsEvent {
  final int _nonce;
  GoalsRefresh() : _nonce = DateTime.now().microsecondsSinceEpoch;
  @override
  List<Object?> get props => [_nonce];
}

class GoalsCreate extends GoalsEvent {
  final FinancialGoal goal;
  const GoalsCreate(this.goal);
  @override
  List<Object?> get props => [goal];
}

class GoalsUpdate extends GoalsEvent {
  final FinancialGoal goal;
  const GoalsUpdate(this.goal);
  @override
  List<Object?> get props => [goal];
}

class GoalsDelete extends GoalsEvent {
  final String id;
  const GoalsDelete(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class GoalsState extends Equatable {
  const GoalsState();
  @override
  List<Object?> get props => const [];
}

class GoalsInitial extends GoalsState {
  const GoalsInitial();
}

class GoalsLoading extends GoalsState {
  const GoalsLoading();
}

class GoalsLoaded extends GoalsState {
  final List<FinancialGoal> goals;
  const GoalsLoaded(this.goals);

  List<FinancialGoal> get household =>
      goals.where((g) => g.scope == GoalScope.household).toList();
  List<FinancialGoal> get personal =>
      goals.where((g) => g.scope == GoalScope.personal).toList();

  List<FinancialGoal> forMoneySource(String bankAccountId) =>
      goals.where((g) => g.bankAccountId == bankAccountId).toList();

  double get totalCurrent => goals.fold(0, (s, g) => s + g.currentAmount);
  double get totalTarget => goals.fold(0, (s, g) => s + (g.targetAmount ?? 0));
  double get overallProgress {
    if (totalTarget == 0) return 0;
    return (totalCurrent / totalTarget).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [goals];
}

class GoalsError extends GoalsState {
  final String message;
  const GoalsError(this.message);
  @override
  List<Object?> get props => [message];
}

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  final GoalRepository _repo;
  String? _householdId;
  String? _userId;

  GoalsBloc(this._repo) : super(const GoalsInitial()) {
    on<GoalsLoad>(_onLoad);
    on<GoalsRefresh>(_onRefresh);
    on<GoalsCreate>(_onCreate);
    on<GoalsUpdate>(_onUpdate);
    on<GoalsDelete>(_onDelete);
  }

  Future<void> _onCreate(GoalsCreate e, Emitter<GoalsState> emit) async {
    await _repo.createGoal(e.goal);
    await _fetch(emit);
  }

  Future<void> _onUpdate(GoalsUpdate e, Emitter<GoalsState> emit) async {
    await _repo.updateGoal(e.goal);
    await _fetch(emit);
  }

  Future<void> _onDelete(GoalsDelete e, Emitter<GoalsState> emit) async {
    await _repo.deleteGoal(e.id);
    await _fetch(emit);
  }

  Future<void> _onLoad(GoalsLoad e, Emitter<GoalsState> emit) async {
    _householdId = e.householdId;
    _userId = e.userId;
    emit(const GoalsLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(GoalsRefresh e, Emitter<GoalsState> emit) async {
    if (_householdId == null || _userId == null) return;
    emit(const GoalsLoading());
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<GoalsState> emit) async {
    final (goals, failure) = await _repo.getGoals(
      householdId: _householdId!,
      viewMode: ViewMode.household,
      userId: _userId,
    );
    if (failure != null) {
      emit(GoalsError(failure.message));
      return;
    }
    emit(GoalsLoaded(goals));
  }
}
