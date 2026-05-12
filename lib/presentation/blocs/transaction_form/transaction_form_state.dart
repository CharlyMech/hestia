import 'package:equatable/equatable.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/blocs/transaction_form/transaction_form_event.dart';

enum TransactionFormStatus { idle, loading, submitting, success, error }

class TransactionFormState extends Equatable {
  final TransactionFormStatus status;
  final String? editingId;
  final TransactionKind kind;
  final String amount;
  final String? categoryId;
  final String? bankAccountId;

  /// Transfer destination bank account.
  final String? toBankAccountId;
  final String? transactionSourceId;
  final DateTime date;
  final bool isRecurring;
  final String note;
  final Map<String, String> errors;
  final Failure? failure;

  /// Set when a create/update succeeds, before the sheet pops.
  final Transaction? submittedTransaction;

  /// When true, [latitude]/[longitude] are persisted on the transaction.
  final bool attachLocation;
  final double? latitude;
  final double? longitude;
  final bool locationLoading;

  const TransactionFormState({
    this.status = TransactionFormStatus.idle,
    this.editingId,
    this.kind = TransactionKind.expense,
    this.amount = '',
    this.categoryId,
    this.bankAccountId,
    this.toBankAccountId,
    this.transactionSourceId,
    required this.date,
    this.isRecurring = false,
    this.note = '',
    this.errors = const {},
    this.failure,
    this.submittedTransaction,
    this.attachLocation = false,
    this.latitude,
    this.longitude,
    this.locationLoading = false,
  });

  factory TransactionFormState.initial() => TransactionFormState(
        date: DateTime.now(),
        submittedTransaction: null,
      );

  bool get isEditing => editingId != null;

  double? get parsedAmount {
    final cleaned = amount.replaceAll(',', '.').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  TransactionFormState copyWith({
    TransactionFormStatus? status,
    Object? editingId = _unset,
    TransactionKind? kind,
    String? amount,
    Object? categoryId = _unset,
    Object? bankAccountId = _unset,
    Object? toBankAccountId = _unset,
    Object? transactionSourceId = _unset,
    DateTime? date,
    bool? isRecurring,
    String? note,
    Map<String, String>? errors,
    Object? failure = _unset,
    Object? submittedTransaction = _unset,
    bool? attachLocation,
    Object? latitude = _unset,
    Object? longitude = _unset,
    bool? locationLoading,
  }) {
    return TransactionFormState(
      status: status ?? this.status,
      editingId: editingId == _unset ? this.editingId : editingId as String?,
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      categoryId:
          categoryId == _unset ? this.categoryId : categoryId as String?,
      bankAccountId: bankAccountId == _unset
          ? this.bankAccountId
          : bankAccountId as String?,
      toBankAccountId: toBankAccountId == _unset
          ? this.toBankAccountId
          : toBankAccountId as String?,
      transactionSourceId: transactionSourceId == _unset
          ? this.transactionSourceId
          : transactionSourceId as String?,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      note: note ?? this.note,
      errors: errors ?? this.errors,
      failure: failure == _unset ? this.failure : failure as Failure?,
      submittedTransaction: submittedTransaction == _unset
          ? this.submittedTransaction
          : submittedTransaction as Transaction?,
      attachLocation: attachLocation ?? this.attachLocation,
      latitude: latitude == _unset ? this.latitude : latitude as double?,
      longitude: longitude == _unset ? this.longitude : longitude as double?,
      locationLoading: locationLoading ?? this.locationLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        editingId,
        kind,
        amount,
        categoryId,
        bankAccountId,
        toBankAccountId,
        transactionSourceId,
        date,
        isRecurring,
        note,
        errors,
        failure,
        submittedTransaction,
        attachLocation,
        latitude,
        longitude,
        locationLoading,
      ];
}

const _unset = Object();
