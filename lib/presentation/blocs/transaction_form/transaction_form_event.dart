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
