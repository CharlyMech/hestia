import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/payment_card.dart';
import 'package:hestia/domain/repositories/card_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class CardsEvent extends Equatable {
  const CardsEvent();
  @override
  List<Object?> get props => const [];
}

class CardsLoad extends CardsEvent {
  final String accountId;
  const CardsLoad(this.accountId);
  @override
  List<Object?> get props => [accountId];
}

class CardsRefresh extends CardsEvent {
  const CardsRefresh();
}

// ── States ───────────────────────────────────────────────────────────────────

abstract class CardsState extends Equatable {
  const CardsState();
  @override
  List<Object?> get props => const [];
}

class CardsInitial extends CardsState {
  const CardsInitial();
}

class CardsLoading extends CardsState {
  const CardsLoading();
}

class CardsLoaded extends CardsState {
  final List<PaymentCard> cards;
  final String accountId;

  const CardsLoaded(this.cards, {required this.accountId});

  @override
  List<Object?> get props => [cards, accountId];
}

class CardsError extends CardsState {
  final String message;
  const CardsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class CardsBloc extends Bloc<CardsEvent, CardsState> {
  final CardRepository _repo;
  String? _lastAccountId;

  CardsBloc(this._repo) : super(const CardsInitial()) {
    on<CardsLoad>(_onLoad);
    on<CardsRefresh>(_onRefresh);
  }

  Future<void> _onLoad(CardsLoad event, Emitter<CardsState> emit) async {
    _lastAccountId = event.accountId;
    emit(const CardsLoading());
    final (cards, failure) = await _repo.getCardsByAccount(
      accountId: event.accountId,
    );
    if (failure != null) {
      emit(CardsError(failure.message));
    } else {
      emit(CardsLoaded(cards, accountId: event.accountId));
    }
  }

  Future<void> _onRefresh(CardsRefresh event, Emitter<CardsState> emit) async {
    final accountId = _lastAccountId;
    if (accountId == null) return;
    add(CardsLoad(accountId));
  }
}
