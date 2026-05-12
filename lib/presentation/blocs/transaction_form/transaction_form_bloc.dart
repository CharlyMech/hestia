import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/services/location_service.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transfer.dart';
import 'package:hestia/domain/repositories/transaction_repository.dart';
import 'package:hestia/presentation/blocs/transaction_form/transaction_form_event.dart';
import 'package:hestia/presentation/blocs/transaction_form/transaction_form_state.dart';

class TransactionFormBloc
    extends Bloc<TransactionFormEvent, TransactionFormState> {
  final TransactionRepository _transactionRepository;
  final LocationService _locationService;
  final String householdId;
  final String userId;

  /// Optional preload of an existing transaction for edit mode.
  final Transaction? initialTransaction;

  TransactionFormBloc({
    required TransactionRepository transactionRepository,
    required LocationService locationService,
    required this.householdId,
    required this.userId,
    this.initialTransaction,
  })  : _transactionRepository = transactionRepository,
        _locationService = locationService,
        super(_buildInitial(initialTransaction)) {
    on<TransactionFormInit>(_onInit);
    on<TransactionFormKindChanged>((e, emit) =>
        emit(state.copyWith(kind: e.kind, errors: const {}, failure: null)));
    on<TransactionFormAmountChanged>(
        (e, emit) => emit(state.copyWith(amount: e.value)));
    on<TransactionFormCategoryChanged>(
        (e, emit) => emit(state.copyWith(categoryId: e.categoryId)));
    on<TransactionFormSourceChanged>(
        (e, emit) => emit(state.copyWith(bankAccountId: e.bankAccountId)));
    on<TransactionFormToBankAccountChanged>(
        (e, emit) => emit(state.copyWith(toBankAccountId: e.bankAccountId)));
    on<TransactionFormTransactionSourceChanged>((e, emit) =>
        emit(state.copyWith(transactionSourceId: e.transactionSourceId)));
    on<TransactionFormDateChanged>(
        (e, emit) => emit(state.copyWith(date: e.date)));
    on<TransactionFormRecurringToggled>(
        (e, emit) => emit(state.copyWith(isRecurring: e.value)));
    on<TransactionFormNoteChanged>(
        (e, emit) => emit(state.copyWith(note: e.value)));
    on<TransactionFormLocationToggled>(_onLocationToggled);
    on<TransactionFormLocationSet>((e, emit) {
      final err = Map<String, String>.from(state.errors)..remove('location');
      emit(state.copyWith(
        latitude: e.latitude,
        longitude: e.longitude,
        locationLoading: false,
        errors: err,
      ));
    });
    on<TransactionFormLocationFetchRequested>(_onLocationFetch);
    on<TransactionFormSubmit>(_onSubmit);
    on<TransactionFormDelete>(_onDelete);
  }

  static TransactionFormState _buildInitial(Transaction? t) {
    if (t == null) return TransactionFormState.initial();
    return TransactionFormState(
      editingId: t.id.isEmpty ? null : t.id,
      kind: t.type == TransactionType.expense
          ? TransactionKind.expense
          : TransactionKind.income,
      amount: t.amount.toStringAsFixed(2),
      categoryId: t.categoryId,
      bankAccountId: t.bankAccountId,
      transactionSourceId: t.transactionSourceId,
      date: t.date,
      isRecurring: t.isRecurring,
      note: t.note ?? '',
      attachLocation: t.hasLocation,
      latitude: t.latitude,
      longitude: t.longitude,
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
      if (state.bankAccountId == null) {
        errors['from'] = 'Pick a from account';
      }
      if (state.toBankAccountId == null) {
        errors['to'] = 'Pick a destination account';
      }
      if (state.bankAccountId != null &&
          state.bankAccountId == state.toBankAccountId) {
        errors['to'] = 'Destination must differ';
      }
    } else {
      if (state.categoryId == null) errors['category'] = 'Pick a category';
      if (state.bankAccountId == null) {
        errors['bankAccount'] = 'Pick a bank account';
      }
      if (state.attachLocation &&
          (state.latitude == null || state.longitude == null)) {
        errors['location'] =
            'Pick a location on the map or use your current position';
      }
    }
    return errors;
  }

  Future<void> _onLocationToggled(
    TransactionFormLocationToggled event,
    Emitter<TransactionFormState> emit,
  ) async {
    if (!event.value) {
      final err = Map<String, String>.from(state.errors)..remove('location');
      emit(state.copyWith(
        attachLocation: false,
        latitude: null,
        longitude: null,
        locationLoading: false,
        errors: err,
      ));
      return;
    }
    final err = Map<String, String>.from(state.errors)..remove('location');
    // Keep existing coordinates (map or saved) — do not auto-call GPS.
    if (state.latitude != null && state.longitude != null) {
      emit(state.copyWith(
        attachLocation: true,
        locationLoading: false,
        errors: err,
      ));
      return;
    }
    emit(state.copyWith(
      attachLocation: true,
      locationLoading: true,
      errors: err,
    ));
    await _fillGps(emit);
  }

  Future<void> _onLocationFetch(
    TransactionFormLocationFetchRequested event,
    Emitter<TransactionFormState> emit,
  ) async {
    emit(state.copyWith(locationLoading: true));
    await _fillGps(emit);
  }

  Future<void> _fillGps(Emitter<TransactionFormState> emit) async {
    final pos = await _locationService.getCurrentPosition();
    if (pos == null) {
      final err = Map<String, String>.from(state.errors);
      // If map / saved coords already exist, GPS failure is non-blocking.
      if (state.latitude == null || state.longitude == null) {
        err['location'] =
            'Could not use GPS. Pick a point on the map or open Settings to allow location.';
      } else {
        err.remove('location');
      }
      emit(state.copyWith(
        locationLoading: false,
        errors: err,
      ));
      return;
    }
    final err = Map<String, String>.from(state.errors)..remove('location');
    emit(state.copyWith(
      latitude: pos.latitude,
      longitude: pos.longitude,
      locationLoading: false,
      errors: err,
    ));
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
        fromSourceId: state.bankAccountId!,
        toSourceId: state.toBankAccountId!,
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
      emit(state.copyWith(
        status: TransactionFormStatus.success,
        submittedTransaction: null,
      ));
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
      bankAccountId: state.bankAccountId!,
      transactionSourceId: state.transactionSourceId,
      amount: amount,
      type: type,
      note: state.note.isEmpty ? null : state.note,
      date: state.date,
      isRecurring: state.isRecurring,
      recurringRule: initialTransaction?.recurringRule,
      createdAt: initialTransaction?.createdAt ?? now,
      lastUpdate: now,
      latitude: state.attachLocation ? state.latitude : null,
      longitude: state.attachLocation ? state.longitude : null,
      categoryName: initialTransaction?.categoryName,
      categoryColor: initialTransaction?.categoryColor,
      bankAccountName: initialTransaction?.bankAccountName,
      transactionSourceName: initialTransaction?.transactionSourceName,
      userName: initialTransaction?.userName,
    );

    if (state.isEditing) {
      final failure =
          await _transactionRepository.updateTransaction(transaction);
      if (failure != null) {
        emit(state.copyWith(
            status: TransactionFormStatus.error, failure: failure));
        return;
      }
      emit(state.copyWith(
        status: TransactionFormStatus.success,
        submittedTransaction: transaction,
      ));
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
      emit(state.copyWith(
        status: TransactionFormStatus.success,
        submittedTransaction: created,
      ));
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
