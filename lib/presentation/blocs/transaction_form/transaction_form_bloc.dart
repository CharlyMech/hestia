import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transfer.dart';
import 'package:hestia/domain/repositories/transaction_repository.dart';
import 'package:hestia/presentation/blocs/transaction_form/transaction_form_event.dart';
import 'package:hestia/presentation/blocs/transaction_form/transaction_form_state.dart';

class TransactionFormBloc
    extends Bloc<TransactionFormEvent, TransactionFormState> {
  final TransactionRepository _transactionRepository;
  final String householdId;
  final String userId;

  /// Optional preload of an existing transaction for edit mode.
  final Transaction? initialTransaction;

  TransactionFormBloc({
    required TransactionRepository transactionRepository,
    required this.householdId,
    required this.userId,
    this.initialTransaction,
  })  : _transactionRepository = transactionRepository,
        super(_buildInitial(initialTransaction)) {
    on<TransactionFormInit>(_onInit);
    on<TransactionFormKindChanged>((e, emit) =>
        emit(state.copyWith(kind: e.kind, errors: const {}, failure: null)));
    on<TransactionFormAmountChanged>(
        (e, emit) => emit(state.copyWith(amount: e.value)));
    on<TransactionFormCategoryChanged>(
        (e, emit) => emit(state.copyWith(categoryId: e.categoryId)));
    on<TransactionFormSourceChanged>(
        (e, emit) => emit(state.copyWith(moneySourceId: e.moneySourceId)));
    on<TransactionFormToSourceChanged>(
        (e, emit) => emit(state.copyWith(toMoneySourceId: e.moneySourceId)));
    on<TransactionFormDateChanged>(
        (e, emit) => emit(state.copyWith(date: e.date)));
    on<TransactionFormRecurringToggled>(
        (e, emit) => emit(state.copyWith(isRecurring: e.value)));
    on<TransactionFormNoteChanged>(
        (e, emit) => emit(state.copyWith(note: e.value)));
    on<TransactionFormSubmit>(_onSubmit);
    on<TransactionFormDelete>(_onDelete);
  }

  static TransactionFormState _buildInitial(Transaction? t) {
    if (t == null) return TransactionFormState.initial();
    return TransactionFormState(
      editingId: t.id,
      kind: t.type == TransactionType.expense
          ? TransactionKind.expense
          : TransactionKind.income,
      amount: t.amount.toStringAsFixed(2),
      categoryId: t.categoryId,
      moneySourceId: t.moneySourceId,
      date: t.date,
      isRecurring: t.isRecurring,
      note: t.note ?? '',
    );
  }

  Future<void> _onInit(
      TransactionFormInit event, Emitter<TransactionFormState> emit) async {
    // Hook for future async hydration; nothing to do for now since the form
    // is constructed with the initial transaction passed in.
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    final amount = state.parsedAmount;
    if (amount == null || amount <= 0) {
      errors['amount'] = 'Enter an amount greater than zero';
    }
    if (state.kind == TransactionKind.transfer) {
      if (state.moneySourceId == null) errors['from'] = 'Pick a source';
      if (state.toMoneySourceId == null) errors['to'] = 'Pick a destination';
      if (state.moneySourceId != null &&
          state.moneySourceId == state.toMoneySourceId) {
        errors['to'] = 'Destination must differ';
      }
    } else {
      if (state.categoryId == null) errors['category'] = 'Pick a category';
      if (state.moneySourceId == null) errors['source'] = 'Pick a source';
    }
    return errors;
  }

  Future<void> _onSubmit(
      TransactionFormSubmit event, Emitter<TransactionFormState> emit) async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(
          errors: errors, status: TransactionFormStatus.error, failure: null));
      return;
    }

    emit(state.copyWith(
        status: TransactionFormStatus.submitting,
        errors: const {},
        failure: null));

    final amount = state.parsedAmount!;
    final now = DateTime.now();

    if (state.kind == TransactionKind.transfer) {
      final transfer = Transfer(
        id: '',
        householdId: householdId,
        userId: userId,
        fromSourceId: state.moneySourceId!,
        toSourceId: state.toMoneySourceId!,
        amount: amount,
        note: state.note.isEmpty ? null : state.note,
        date: state.date,
        createdAt: now,
        lastUpdate: now,
      );
      final (created, failure) =
          await _transactionRepository.createTransfer(transfer);
      if (failure != null || created == null) {
        emit(state.copyWith(
          status: TransactionFormStatus.error,
          failure: failure ?? const ServerFailure('Could not create transfer'),
        ));
        return;
      }
      emit(state.copyWith(status: TransactionFormStatus.success));
      return;
    }

    final type = state.kind == TransactionKind.expense
        ? TransactionType.expense
        : TransactionType.income;

    final transaction = Transaction(
      id: state.editingId ?? '',
      householdId: householdId,
      userId: userId,
      categoryId: state.categoryId!,
      moneySourceId: state.moneySourceId!,
      amount: amount,
      type: type,
      note: state.note.isEmpty ? null : state.note,
      date: state.date,
      isRecurring: state.isRecurring,
      createdAt: initialTransaction?.createdAt ?? now,
      lastUpdate: now,
    );

    if (state.isEditing) {
      final failure =
          await _transactionRepository.updateTransaction(transaction);
      if (failure != null) {
        emit(state.copyWith(
            status: TransactionFormStatus.error, failure: failure));
        return;
      }
      emit(state.copyWith(status: TransactionFormStatus.success));
    } else {
      final (created, failure) =
          await _transactionRepository.createTransaction(transaction);
      if (failure != null || created == null) {
        emit(state.copyWith(
          status: TransactionFormStatus.error,
          failure:
              failure ?? const ServerFailure('Could not create transaction'),
        ));
        return;
      }
      emit(state.copyWith(status: TransactionFormStatus.success));
    }
  }

  Future<void> _onDelete(
      TransactionFormDelete event, Emitter<TransactionFormState> emit) async {
    if (!state.isEditing) return;
    emit(state.copyWith(status: TransactionFormStatus.submitting));
    final failure =
        await _transactionRepository.deleteTransaction(state.editingId!);
    if (failure != null) {
      emit(state.copyWith(
          status: TransactionFormStatus.error, failure: failure));
      return;
    }
    emit(state.copyWith(status: TransactionFormStatus.success));
  }
}
