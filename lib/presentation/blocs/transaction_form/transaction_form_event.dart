import 'package:equatable/equatable.dart';
import 'package:hestia/core/constants/enums.dart';

enum TransactionKind { expense, income, transfer }

extension TransactionKindX on TransactionKind {
  TransactionType? get asTransactionType => switch (this) {
        TransactionKind.expense => TransactionType.expense,
        TransactionKind.income => TransactionType.income,
        TransactionKind.transfer => null,
      };
}

sealed class TransactionFormEvent extends Equatable {
  const TransactionFormEvent();
  @override
  List<Object?> get props => [];
}

class TransactionFormInit extends TransactionFormEvent {
  final String? transactionId;
  const TransactionFormInit({this.transactionId});
  @override
  List<Object?> get props => [transactionId];
}

class TransactionFormKindChanged extends TransactionFormEvent {
  final TransactionKind kind;
  const TransactionFormKindChanged(this.kind);
  @override
  List<Object?> get props => [kind];
}

class TransactionFormAmountChanged extends TransactionFormEvent {
  final String value;
  const TransactionFormAmountChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class TransactionFormCurrencyChanged extends TransactionFormEvent {
  final String currency;
  const TransactionFormCurrencyChanged(this.currency);
  @override
  List<Object?> get props => [currency];
}

class TransactionFormCategoryChanged extends TransactionFormEvent {
  final String categoryId;
  const TransactionFormCategoryChanged(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class TransactionFormSourceChanged extends TransactionFormEvent {
  final String bankAccountId;
  const TransactionFormSourceChanged(this.bankAccountId);
  @override
  List<Object?> get props => [bankAccountId];
}

class TransactionFormToBankAccountChanged extends TransactionFormEvent {
  final String bankAccountId;
  const TransactionFormToBankAccountChanged(this.bankAccountId);
  @override
  List<Object?> get props => [bankAccountId];
}

class TransactionFormTransactionSourceChanged extends TransactionFormEvent {
  /// Pass null to clear the selection.
  final String? transactionSourceId;
  const TransactionFormTransactionSourceChanged(this.transactionSourceId);
  @override
  List<Object?> get props => [transactionSourceId];
}

class TransactionFormDateChanged extends TransactionFormEvent {
  final DateTime date;
  const TransactionFormDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class TransactionFormRecurringToggled extends TransactionFormEvent {
  final bool value;
  const TransactionFormRecurringToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class TransactionFormNoteChanged extends TransactionFormEvent {
  final String value;
  const TransactionFormNoteChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class TransactionFormSubmit extends TransactionFormEvent {
  const TransactionFormSubmit();
}

class TransactionFormDelete extends TransactionFormEvent {
  const TransactionFormDelete();
}

class TransactionFormLocationToggled extends TransactionFormEvent {
  final bool value;
  const TransactionFormLocationToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class TransactionFormLocationSet extends TransactionFormEvent {
  final double? latitude;
  final double? longitude;
  const TransactionFormLocationSet({this.latitude, this.longitude});
  @override
  List<Object?> get props => [latitude, longitude];
}

class TransactionFormLocationFetchRequested extends TransactionFormEvent {
  const TransactionFormLocationFetchRequested();
}

/// Pass null to clear the card selection.
class TransactionFormCardChanged extends TransactionFormEvent {
  final String? paymentCardId;
  const TransactionFormCardChanged(this.paymentCardId);
  @override
  List<Object?> get props => [paymentCardId];
}

/// Set the optional actor association — exactly one of [petId], [carId],
/// [homeId] should be non-null; passing all null clears the actor.
class TransactionFormActorChanged extends TransactionFormEvent {
  final String? petId;
  final String? carId;
  final String? homeId;

  const TransactionFormActorChanged({this.petId, this.carId, this.homeId});

  @override
  List<Object?> get props => [petId, carId, homeId];
}
