// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalTransactionsTable extends LocalTransactions
    with TableInfo<$LocalTransactionsTable, LocalTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bankAccountIdMeta =
      const VerificationMeta('bankAccountId');
  @override
  late final GeneratedColumn<String> bankAccountId = GeneratedColumn<String>(
      'bank_account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionSourceIdMeta =
      const VerificationMeta('transactionSourceId');
  @override
  late final GeneratedColumn<String> transactionSourceId =
      GeneratedColumn<String>('transaction_source_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentCardIdMeta =
      const VerificationMeta('paymentCardId');
  @override
  late final GeneratedColumn<String> paymentCardId = GeneratedColumn<String>(
      'payment_card_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
      'date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurringRuleMeta =
      const VerificationMeta('recurringRule');
  @override
  late final GeneratedColumn<String> recurringRule = GeneratedColumn<String>(
      'recurring_rule', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdateMeta =
      const VerificationMeta('lastUpdate');
  @override
  late final GeneratedColumn<int> lastUpdate = GeneratedColumn<int>(
      'last_update', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        householdId,
        userId,
        categoryId,
        bankAccountId,
        transactionSourceId,
        paymentCardId,
        amount,
        type,
        note,
        date,
        isRecurring,
        recurringRule,
        createdAt,
        lastUpdate,
        isSynced,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_transactions';
  @override
  VerificationContext validateIntegrity(Insertable<LocalTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('bank_account_id')) {
      context.handle(
          _bankAccountIdMeta,
          bankAccountId.isAcceptableOrUnknown(
              data['bank_account_id']!, _bankAccountIdMeta));
    } else if (isInserting) {
      context.missing(_bankAccountIdMeta);
    }
    if (data.containsKey('transaction_source_id')) {
      context.handle(
          _transactionSourceIdMeta,
          transactionSourceId.isAcceptableOrUnknown(
              data['transaction_source_id']!, _transactionSourceIdMeta));
    }
    if (data.containsKey('payment_card_id')) {
      context.handle(
          _paymentCardIdMeta,
          paymentCardId.isAcceptableOrUnknown(
              data['payment_card_id']!, _paymentCardIdMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('recurring_rule')) {
      context.handle(
          _recurringRuleMeta,
          recurringRule.isAcceptableOrUnknown(
              data['recurring_rule']!, _recurringRuleMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update']!, _lastUpdateMeta));
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      bankAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}bank_account_id'])!,
      transactionSourceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_source_id']),
      paymentCardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_card_id']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      recurringRule: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurring_rule']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_update'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $LocalTransactionsTable createAlias(String alias) {
    return $LocalTransactionsTable(attachedDatabase, alias);
  }
}

class LocalTransaction extends DataClass
    implements Insertable<LocalTransaction> {
  final String id;
  final String householdId;
  final String userId;
  final String categoryId;
  final String bankAccountId;
  final String? transactionSourceId;
  final String? paymentCardId;
  final double amount;
  final String type;
  final String? note;
  final int date;
  final bool isRecurring;
  final String? recurringRule;
  final int createdAt;
  final int lastUpdate;
  final bool isSynced;
  final bool isDeleted;
  const LocalTransaction(
      {required this.id,
      required this.householdId,
      required this.userId,
      required this.categoryId,
      required this.bankAccountId,
      this.transactionSourceId,
      this.paymentCardId,
      required this.amount,
      required this.type,
      this.note,
      required this.date,
      required this.isRecurring,
      this.recurringRule,
      required this.createdAt,
      required this.lastUpdate,
      required this.isSynced,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['user_id'] = Variable<String>(userId);
    map['category_id'] = Variable<String>(categoryId);
    map['bank_account_id'] = Variable<String>(bankAccountId);
    if (!nullToAbsent || transactionSourceId != null) {
      map['transaction_source_id'] = Variable<String>(transactionSourceId);
    }
    if (!nullToAbsent || paymentCardId != null) {
      map['payment_card_id'] = Variable<String>(paymentCardId);
    }
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['date'] = Variable<int>(date);
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurringRule != null) {
      map['recurring_rule'] = Variable<String>(recurringRule);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['last_update'] = Variable<int>(lastUpdate);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LocalTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LocalTransactionsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      userId: Value(userId),
      categoryId: Value(categoryId),
      bankAccountId: Value(bankAccountId),
      transactionSourceId: transactionSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionSourceId),
      paymentCardId: paymentCardId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentCardId),
      amount: Value(amount),
      type: Value(type),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      date: Value(date),
      isRecurring: Value(isRecurring),
      recurringRule: recurringRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringRule),
      createdAt: Value(createdAt),
      lastUpdate: Value(lastUpdate),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
    );
  }

  factory LocalTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransaction(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      userId: serializer.fromJson<String>(json['userId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      bankAccountId: serializer.fromJson<String>(json['bankAccountId']),
      transactionSourceId:
          serializer.fromJson<String?>(json['transactionSourceId']),
      paymentCardId: serializer.fromJson<String?>(json['paymentCardId']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      note: serializer.fromJson<String?>(json['note']),
      date: serializer.fromJson<int>(json['date']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurringRule: serializer.fromJson<String?>(json['recurringRule']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastUpdate: serializer.fromJson<int>(json['lastUpdate']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'userId': serializer.toJson<String>(userId),
      'categoryId': serializer.toJson<String>(categoryId),
      'bankAccountId': serializer.toJson<String>(bankAccountId),
      'transactionSourceId': serializer.toJson<String?>(transactionSourceId),
      'paymentCardId': serializer.toJson<String?>(paymentCardId),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'note': serializer.toJson<String?>(note),
      'date': serializer.toJson<int>(date),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurringRule': serializer.toJson<String?>(recurringRule),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastUpdate': serializer.toJson<int>(lastUpdate),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  LocalTransaction copyWith(
          {String? id,
          String? householdId,
          String? userId,
          String? categoryId,
          String? bankAccountId,
          Value<String?> transactionSourceId = const Value.absent(),
          Value<String?> paymentCardId = const Value.absent(),
          double? amount,
          String? type,
          Value<String?> note = const Value.absent(),
          int? date,
          bool? isRecurring,
          Value<String?> recurringRule = const Value.absent(),
          int? createdAt,
          int? lastUpdate,
          bool? isSynced,
          bool? isDeleted}) =>
      LocalTransaction(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        userId: userId ?? this.userId,
        categoryId: categoryId ?? this.categoryId,
        bankAccountId: bankAccountId ?? this.bankAccountId,
        transactionSourceId: transactionSourceId.present
            ? transactionSourceId.value
            : this.transactionSourceId,
        paymentCardId:
            paymentCardId.present ? paymentCardId.value : this.paymentCardId,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        note: note.present ? note.value : this.note,
        date: date ?? this.date,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringRule:
            recurringRule.present ? recurringRule.value : this.recurringRule,
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  LocalTransaction copyWithCompanion(LocalTransactionsCompanion data) {
    return LocalTransaction(
      id: data.id.present ? data.id.value : this.id,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      userId: data.userId.present ? data.userId.value : this.userId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      bankAccountId: data.bankAccountId.present
          ? data.bankAccountId.value
          : this.bankAccountId,
      transactionSourceId: data.transactionSourceId.present
          ? data.transactionSourceId.value
          : this.transactionSourceId,
      paymentCardId: data.paymentCardId.present
          ? data.paymentCardId.value
          : this.paymentCardId,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      recurringRule: data.recurringRule.present
          ? data.recurringRule.value
          : this.recurringRule,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdate:
          data.lastUpdate.present ? data.lastUpdate.value : this.lastUpdate,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransaction(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('userId: $userId, ')
          ..write('categoryId: $categoryId, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('transactionSourceId: $transactionSourceId, ')
          ..write('paymentCardId: $paymentCardId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringRule: $recurringRule, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      householdId,
      userId,
      categoryId,
      bankAccountId,
      transactionSourceId,
      paymentCardId,
      amount,
      type,
      note,
      date,
      isRecurring,
      recurringRule,
      createdAt,
      lastUpdate,
      isSynced,
      isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransaction &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.userId == this.userId &&
          other.categoryId == this.categoryId &&
          other.bankAccountId == this.bankAccountId &&
          other.transactionSourceId == this.transactionSourceId &&
          other.paymentCardId == this.paymentCardId &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.note == this.note &&
          other.date == this.date &&
          other.isRecurring == this.isRecurring &&
          other.recurringRule == this.recurringRule &&
          other.createdAt == this.createdAt &&
          other.lastUpdate == this.lastUpdate &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted);
}

class LocalTransactionsCompanion extends UpdateCompanion<LocalTransaction> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> userId;
  final Value<String> categoryId;
  final Value<String> bankAccountId;
  final Value<String?> transactionSourceId;
  final Value<String?> paymentCardId;
  final Value<double> amount;
  final Value<String> type;
  final Value<String?> note;
  final Value<int> date;
  final Value<bool> isRecurring;
  final Value<String?> recurringRule;
  final Value<int> createdAt;
  final Value<int> lastUpdate;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LocalTransactionsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.userId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    this.transactionSourceId = const Value.absent(),
    this.paymentCardId = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringRule = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTransactionsCompanion.insert({
    required String id,
    required String householdId,
    required String userId,
    required String categoryId,
    required String bankAccountId,
    this.transactionSourceId = const Value.absent(),
    this.paymentCardId = const Value.absent(),
    required double amount,
    required String type,
    this.note = const Value.absent(),
    required int date,
    this.isRecurring = const Value.absent(),
    this.recurringRule = const Value.absent(),
    required int createdAt,
    required int lastUpdate,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        householdId = Value(householdId),
        userId = Value(userId),
        categoryId = Value(categoryId),
        bankAccountId = Value(bankAccountId),
        amount = Value(amount),
        type = Value(type),
        date = Value(date),
        createdAt = Value(createdAt),
        lastUpdate = Value(lastUpdate);
  static Insertable<LocalTransaction> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? userId,
    Expression<String>? categoryId,
    Expression<String>? bankAccountId,
    Expression<String>? transactionSourceId,
    Expression<String>? paymentCardId,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? note,
    Expression<int>? date,
    Expression<bool>? isRecurring,
    Expression<String>? recurringRule,
    Expression<int>? createdAt,
    Expression<int>? lastUpdate,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (userId != null) 'user_id': userId,
      if (categoryId != null) 'category_id': categoryId,
      if (bankAccountId != null) 'bank_account_id': bankAccountId,
      if (transactionSourceId != null)
        'transaction_source_id': transactionSourceId,
      if (paymentCardId != null) 'payment_card_id': paymentCardId,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurringRule != null) 'recurring_rule': recurringRule,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? householdId,
      Value<String>? userId,
      Value<String>? categoryId,
      Value<String>? bankAccountId,
      Value<String?>? transactionSourceId,
      Value<String?>? paymentCardId,
      Value<double>? amount,
      Value<String>? type,
      Value<String?>? note,
      Value<int>? date,
      Value<bool>? isRecurring,
      Value<String?>? recurringRule,
      Value<int>? createdAt,
      Value<int>? lastUpdate,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return LocalTransactionsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      transactionSourceId: transactionSourceId ?? this.transactionSourceId,
      paymentCardId: paymentCardId ?? this.paymentCardId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringRule: recurringRule ?? this.recurringRule,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (bankAccountId.present) {
      map['bank_account_id'] = Variable<String>(bankAccountId.value);
    }
    if (transactionSourceId.present) {
      map['transaction_source_id'] =
          Variable<String>(transactionSourceId.value);
    }
    if (paymentCardId.present) {
      map['payment_card_id'] = Variable<String>(paymentCardId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurringRule.present) {
      map['recurring_rule'] = Variable<String>(recurringRule.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<int>(lastUpdate.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('userId: $userId, ')
          ..write('categoryId: $categoryId, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('transactionSourceId: $transactionSourceId, ')
          ..write('paymentCardId: $paymentCardId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringRule: $recurringRule, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCategoriesTable extends LocalCategories
    with TableInfo<$LocalCategoriesTable, LocalCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdateMeta =
      const VerificationMeta('lastUpdate');
  @override
  late final GeneratedColumn<int> lastUpdate = GeneratedColumn<int>(
      'last_update', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        householdId,
        name,
        type,
        color,
        icon,
        isActive,
        sortOrder,
        createdAt,
        lastUpdate,
        isSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_categories';
  @override
  VerificationContext validateIntegrity(Insertable<LocalCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update']!, _lastUpdateMeta));
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_update'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $LocalCategoriesTable createAlias(String alias) {
    return $LocalCategoriesTable(attachedDatabase, alias);
  }
}

class LocalCategory extends DataClass implements Insertable<LocalCategory> {
  final String id;
  final String householdId;
  final String name;
  final String type;
  final String? color;
  final String? icon;
  final bool isActive;
  final int sortOrder;
  final int createdAt;
  final int lastUpdate;
  final bool isSynced;
  const LocalCategory(
      {required this.id,
      required this.householdId,
      required this.name,
      required this.type,
      this.color,
      this.icon,
      required this.isActive,
      required this.sortOrder,
      required this.createdAt,
      required this.lastUpdate,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    map['last_update'] = Variable<int>(lastUpdate);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LocalCategoriesCompanion(
      id: Value(id),
      householdId: Value(householdId),
      name: Value(name),
      type: Value(type),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      lastUpdate: Value(lastUpdate),
      isSynced: Value(isSynced),
    );
  }

  factory LocalCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCategory(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      color: serializer.fromJson<String?>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastUpdate: serializer.fromJson<int>(json['lastUpdate']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'color': serializer.toJson<String?>(color),
      'icon': serializer.toJson<String?>(icon),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastUpdate': serializer.toJson<int>(lastUpdate),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalCategory copyWith(
          {String? id,
          String? householdId,
          String? name,
          String? type,
          Value<String?> color = const Value.absent(),
          Value<String?> icon = const Value.absent(),
          bool? isActive,
          int? sortOrder,
          int? createdAt,
          int? lastUpdate,
          bool? isSynced}) =>
      LocalCategory(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        name: name ?? this.name,
        type: type ?? this.type,
        color: color.present ? color.value : this.color,
        icon: icon.present ? icon.value : this.icon,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        isSynced: isSynced ?? this.isSynced,
      );
  LocalCategory copyWithCompanion(LocalCategoriesCompanion data) {
    return LocalCategory(
      id: data.id.present ? data.id.value : this.id,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdate:
          data.lastUpdate.present ? data.lastUpdate.value : this.lastUpdate,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategory(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, householdId, name, type, color, icon,
      isActive, sortOrder, createdAt, lastUpdate, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCategory &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.name == this.name &&
          other.type == this.type &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.lastUpdate == this.lastUpdate &&
          other.isSynced == this.isSynced);
}

class LocalCategoriesCompanion extends UpdateCompanion<LocalCategory> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> color;
  final Value<String?> icon;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  final Value<int> lastUpdate;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalCategoriesCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCategoriesCompanion.insert({
    required String id,
    required String householdId,
    required String name,
    required String type,
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int createdAt,
    required int lastUpdate,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        householdId = Value(householdId),
        name = Value(name),
        type = Value(type),
        createdAt = Value(createdAt),
        lastUpdate = Value(lastUpdate);
  static Insertable<LocalCategory> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? lastUpdate,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? householdId,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? color,
      Value<String?>? icon,
      Value<bool>? isActive,
      Value<int>? sortOrder,
      Value<int>? createdAt,
      Value<int>? lastUpdate,
      Value<bool>? isSynced,
      Value<int>? rowid}) {
    return LocalCategoriesCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<int>(lastUpdate.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalBankAccountsTable extends LocalBankAccounts
    with TableInfo<$LocalBankAccountsTable, LocalBankAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBankAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerTypeMeta =
      const VerificationMeta('ownerType');
  @override
  late final GeneratedColumn<String> ownerType = GeneratedColumn<String>(
      'owner_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _institutionMeta =
      const VerificationMeta('institution');
  @override
  late final GeneratedColumn<String> institution = GeneratedColumn<String>(
      'institution', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _institutionIdMeta =
      const VerificationMeta('institutionId');
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
      'institution_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ibanMeta = const VerificationMeta('iban');
  @override
  late final GeneratedColumn<String> iban = GeneratedColumn<String>(
      'iban', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountTypeMeta =
      const VerificationMeta('accountType');
  @override
  late final GeneratedColumn<String> accountType = GeneratedColumn<String>(
      'account_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('EUR'));
  static const VerificationMeta _initialBalanceMeta =
      const VerificationMeta('initialBalance');
  @override
  late final GeneratedColumn<double> initialBalance = GeneratedColumn<double>(
      'initial_balance', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currentBalanceMeta =
      const VerificationMeta('currentBalance');
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
      'current_balance', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isPrimaryMeta =
      const VerificationMeta('isPrimary');
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
      'is_primary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_primary" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdateMeta =
      const VerificationMeta('lastUpdate');
  @override
  late final GeneratedColumn<int> lastUpdate = GeneratedColumn<int>(
      'last_update', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        householdId,
        ownerType,
        ownerId,
        name,
        institution,
        institutionId,
        iban,
        accountType,
        currency,
        initialBalance,
        currentBalance,
        isPrimary,
        isActive,
        color,
        icon,
        sortOrder,
        createdAt,
        lastUpdate,
        isSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_bank_accounts';
  @override
  VerificationContext validateIntegrity(Insertable<LocalBankAccount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('owner_type')) {
      context.handle(_ownerTypeMeta,
          ownerType.isAcceptableOrUnknown(data['owner_type']!, _ownerTypeMeta));
    } else if (isInserting) {
      context.missing(_ownerTypeMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('institution')) {
      context.handle(
          _institutionMeta,
          institution.isAcceptableOrUnknown(
              data['institution']!, _institutionMeta));
    }
    if (data.containsKey('institution_id')) {
      context.handle(
          _institutionIdMeta,
          institutionId.isAcceptableOrUnknown(
              data['institution_id']!, _institutionIdMeta));
    }
    if (data.containsKey('iban')) {
      context.handle(
          _ibanMeta, iban.isAcceptableOrUnknown(data['iban']!, _ibanMeta));
    }
    if (data.containsKey('account_type')) {
      context.handle(
          _accountTypeMeta,
          accountType.isAcceptableOrUnknown(
              data['account_type']!, _accountTypeMeta));
    } else if (isInserting) {
      context.missing(_accountTypeMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
          _initialBalanceMeta,
          initialBalance.isAcceptableOrUnknown(
              data['initial_balance']!, _initialBalanceMeta));
    } else if (isInserting) {
      context.missing(_initialBalanceMeta);
    }
    if (data.containsKey('current_balance')) {
      context.handle(
          _currentBalanceMeta,
          currentBalance.isAcceptableOrUnknown(
              data['current_balance']!, _currentBalanceMeta));
    } else if (isInserting) {
      context.missing(_currentBalanceMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(_isPrimaryMeta,
          isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update']!, _lastUpdateMeta));
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalBankAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBankAccount(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      ownerType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_type'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      institution: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}institution']),
      institutionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}institution_id']),
      iban: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iban']),
      accountType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_type'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      initialBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}initial_balance'])!,
      currentBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}current_balance'])!,
      isPrimary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_primary'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_update'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $LocalBankAccountsTable createAlias(String alias) {
    return $LocalBankAccountsTable(attachedDatabase, alias);
  }
}

class LocalBankAccount extends DataClass
    implements Insertable<LocalBankAccount> {
  final String id;
  final String householdId;
  final String ownerType;
  final String? ownerId;
  final String name;
  final String? institution;
  final String? institutionId;
  final String? iban;
  final String accountType;
  final String currency;
  final double initialBalance;
  final double currentBalance;
  final bool isPrimary;
  final bool isActive;
  final String? color;
  final String? icon;
  final int sortOrder;
  final int createdAt;
  final int lastUpdate;
  final bool isSynced;
  const LocalBankAccount(
      {required this.id,
      required this.householdId,
      required this.ownerType,
      this.ownerId,
      required this.name,
      this.institution,
      this.institutionId,
      this.iban,
      required this.accountType,
      required this.currency,
      required this.initialBalance,
      required this.currentBalance,
      required this.isPrimary,
      required this.isActive,
      this.color,
      this.icon,
      required this.sortOrder,
      required this.createdAt,
      required this.lastUpdate,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['owner_type'] = Variable<String>(ownerType);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || institution != null) {
      map['institution'] = Variable<String>(institution);
    }
    if (!nullToAbsent || institutionId != null) {
      map['institution_id'] = Variable<String>(institutionId);
    }
    if (!nullToAbsent || iban != null) {
      map['iban'] = Variable<String>(iban);
    }
    map['account_type'] = Variable<String>(accountType);
    map['currency'] = Variable<String>(currency);
    map['initial_balance'] = Variable<double>(initialBalance);
    map['current_balance'] = Variable<double>(currentBalance);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    map['last_update'] = Variable<int>(lastUpdate);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalBankAccountsCompanion toCompanion(bool nullToAbsent) {
    return LocalBankAccountsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      ownerType: Value(ownerType),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      name: Value(name),
      institution: institution == null && nullToAbsent
          ? const Value.absent()
          : Value(institution),
      institutionId: institutionId == null && nullToAbsent
          ? const Value.absent()
          : Value(institutionId),
      iban: iban == null && nullToAbsent ? const Value.absent() : Value(iban),
      accountType: Value(accountType),
      currency: Value(currency),
      initialBalance: Value(initialBalance),
      currentBalance: Value(currentBalance),
      isPrimary: Value(isPrimary),
      isActive: Value(isActive),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      lastUpdate: Value(lastUpdate),
      isSynced: Value(isSynced),
    );
  }

  factory LocalBankAccount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBankAccount(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      ownerType: serializer.fromJson<String>(json['ownerType']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      institution: serializer.fromJson<String?>(json['institution']),
      institutionId: serializer.fromJson<String?>(json['institutionId']),
      iban: serializer.fromJson<String?>(json['iban']),
      accountType: serializer.fromJson<String>(json['accountType']),
      currency: serializer.fromJson<String>(json['currency']),
      initialBalance: serializer.fromJson<double>(json['initialBalance']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      color: serializer.fromJson<String?>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastUpdate: serializer.fromJson<int>(json['lastUpdate']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'ownerType': serializer.toJson<String>(ownerType),
      'ownerId': serializer.toJson<String?>(ownerId),
      'name': serializer.toJson<String>(name),
      'institution': serializer.toJson<String?>(institution),
      'institutionId': serializer.toJson<String?>(institutionId),
      'iban': serializer.toJson<String?>(iban),
      'accountType': serializer.toJson<String>(accountType),
      'currency': serializer.toJson<String>(currency),
      'initialBalance': serializer.toJson<double>(initialBalance),
      'currentBalance': serializer.toJson<double>(currentBalance),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'isActive': serializer.toJson<bool>(isActive),
      'color': serializer.toJson<String?>(color),
      'icon': serializer.toJson<String?>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastUpdate': serializer.toJson<int>(lastUpdate),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalBankAccount copyWith(
          {String? id,
          String? householdId,
          String? ownerType,
          Value<String?> ownerId = const Value.absent(),
          String? name,
          Value<String?> institution = const Value.absent(),
          Value<String?> institutionId = const Value.absent(),
          Value<String?> iban = const Value.absent(),
          String? accountType,
          String? currency,
          double? initialBalance,
          double? currentBalance,
          bool? isPrimary,
          bool? isActive,
          Value<String?> color = const Value.absent(),
          Value<String?> icon = const Value.absent(),
          int? sortOrder,
          int? createdAt,
          int? lastUpdate,
          bool? isSynced}) =>
      LocalBankAccount(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        ownerType: ownerType ?? this.ownerType,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        name: name ?? this.name,
        institution: institution.present ? institution.value : this.institution,
        institutionId:
            institutionId.present ? institutionId.value : this.institutionId,
        iban: iban.present ? iban.value : this.iban,
        accountType: accountType ?? this.accountType,
        currency: currency ?? this.currency,
        initialBalance: initialBalance ?? this.initialBalance,
        currentBalance: currentBalance ?? this.currentBalance,
        isPrimary: isPrimary ?? this.isPrimary,
        isActive: isActive ?? this.isActive,
        color: color.present ? color.value : this.color,
        icon: icon.present ? icon.value : this.icon,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        isSynced: isSynced ?? this.isSynced,
      );
  LocalBankAccount copyWithCompanion(LocalBankAccountsCompanion data) {
    return LocalBankAccount(
      id: data.id.present ? data.id.value : this.id,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      institution:
          data.institution.present ? data.institution.value : this.institution,
      institutionId: data.institutionId.present
          ? data.institutionId.value
          : this.institutionId,
      iban: data.iban.present ? data.iban.value : this.iban,
      accountType:
          data.accountType.present ? data.accountType.value : this.accountType,
      currency: data.currency.present ? data.currency.value : this.currency,
      initialBalance: data.initialBalance.present
          ? data.initialBalance.value
          : this.initialBalance,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdate:
          data.lastUpdate.present ? data.lastUpdate.value : this.lastUpdate,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBankAccount(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('institution: $institution, ')
          ..write('institutionId: $institutionId, ')
          ..write('iban: $iban, ')
          ..write('accountType: $accountType, ')
          ..write('currency: $currency, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isActive: $isActive, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      householdId,
      ownerType,
      ownerId,
      name,
      institution,
      institutionId,
      iban,
      accountType,
      currency,
      initialBalance,
      currentBalance,
      isPrimary,
      isActive,
      color,
      icon,
      sortOrder,
      createdAt,
      lastUpdate,
      isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBankAccount &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.institution == this.institution &&
          other.institutionId == this.institutionId &&
          other.iban == this.iban &&
          other.accountType == this.accountType &&
          other.currency == this.currency &&
          other.initialBalance == this.initialBalance &&
          other.currentBalance == this.currentBalance &&
          other.isPrimary == this.isPrimary &&
          other.isActive == this.isActive &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.lastUpdate == this.lastUpdate &&
          other.isSynced == this.isSynced);
}

class LocalBankAccountsCompanion extends UpdateCompanion<LocalBankAccount> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> ownerType;
  final Value<String?> ownerId;
  final Value<String> name;
  final Value<String?> institution;
  final Value<String?> institutionId;
  final Value<String?> iban;
  final Value<String> accountType;
  final Value<String> currency;
  final Value<double> initialBalance;
  final Value<double> currentBalance;
  final Value<bool> isPrimary;
  final Value<bool> isActive;
  final Value<String?> color;
  final Value<String?> icon;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  final Value<int> lastUpdate;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalBankAccountsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.institution = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.iban = const Value.absent(),
    this.accountType = const Value.absent(),
    this.currency = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isActive = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalBankAccountsCompanion.insert({
    required String id,
    required String householdId,
    required String ownerType,
    this.ownerId = const Value.absent(),
    required String name,
    this.institution = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.iban = const Value.absent(),
    required String accountType,
    this.currency = const Value.absent(),
    required double initialBalance,
    required double currentBalance,
    this.isPrimary = const Value.absent(),
    this.isActive = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int createdAt,
    required int lastUpdate,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        householdId = Value(householdId),
        ownerType = Value(ownerType),
        name = Value(name),
        accountType = Value(accountType),
        initialBalance = Value(initialBalance),
        currentBalance = Value(currentBalance),
        createdAt = Value(createdAt),
        lastUpdate = Value(lastUpdate);
  static Insertable<LocalBankAccount> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? institution,
    Expression<String>? institutionId,
    Expression<String>? iban,
    Expression<String>? accountType,
    Expression<String>? currency,
    Expression<double>? initialBalance,
    Expression<double>? currentBalance,
    Expression<bool>? isPrimary,
    Expression<bool>? isActive,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? lastUpdate,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (institution != null) 'institution': institution,
      if (institutionId != null) 'institution_id': institutionId,
      if (iban != null) 'iban': iban,
      if (accountType != null) 'account_type': accountType,
      if (currency != null) 'currency': currency,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (isActive != null) 'is_active': isActive,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalBankAccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? householdId,
      Value<String>? ownerType,
      Value<String?>? ownerId,
      Value<String>? name,
      Value<String?>? institution,
      Value<String?>? institutionId,
      Value<String?>? iban,
      Value<String>? accountType,
      Value<String>? currency,
      Value<double>? initialBalance,
      Value<double>? currentBalance,
      Value<bool>? isPrimary,
      Value<bool>? isActive,
      Value<String?>? color,
      Value<String?>? icon,
      Value<int>? sortOrder,
      Value<int>? createdAt,
      Value<int>? lastUpdate,
      Value<bool>? isSynced,
      Value<int>? rowid}) {
    return LocalBankAccountsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      institution: institution ?? this.institution,
      institutionId: institutionId ?? this.institutionId,
      iban: iban ?? this.iban,
      accountType: accountType ?? this.accountType,
      currency: currency ?? this.currency,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(ownerType.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (institution.present) {
      map['institution'] = Variable<String>(institution.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (iban.present) {
      map['iban'] = Variable<String>(iban.value);
    }
    if (accountType.present) {
      map['account_type'] = Variable<String>(accountType.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<double>(initialBalance.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<int>(lastUpdate.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalBankAccountsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('institution: $institution, ')
          ..write('institutionId: $institutionId, ')
          ..write('iban: $iban, ')
          ..write('accountType: $accountType, ')
          ..write('currency: $currency, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isActive: $isActive, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalGoalsTable extends LocalGoals
    with TableInfo<$LocalGoalsTable, LocalGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
      'scope', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bankAccountIdMeta =
      const VerificationMeta('bankAccountId');
  @override
  late final GeneratedColumn<String> bankAccountId = GeneratedColumn<String>(
      'bank_account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _goalTypeMeta =
      const VerificationMeta('goalType');
  @override
  late final GeneratedColumn<String> goalType = GeneratedColumn<String>(
      'goal_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
      'target_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _monthlyTargetMeta =
      const VerificationMeta('monthlyTarget');
  @override
  late final GeneratedColumn<double> monthlyTarget = GeneratedColumn<double>(
      'monthly_target', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _currentAmountMeta =
      const VerificationMeta('currentAmount');
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
      'current_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('EUR'));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<int> startDate = GeneratedColumn<int>(
      'start_date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<int> endDate = GeneratedColumn<int>(
      'end_date', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdateMeta =
      const VerificationMeta('lastUpdate');
  @override
  late final GeneratedColumn<int> lastUpdate = GeneratedColumn<int>(
      'last_update', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        householdId,
        scope,
        ownerId,
        bankAccountId,
        name,
        goalType,
        targetAmount,
        monthlyTarget,
        currentAmount,
        currency,
        startDate,
        endDate,
        isActive,
        color,
        icon,
        createdAt,
        lastUpdate,
        isSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_goals';
  @override
  VerificationContext validateIntegrity(Insertable<LocalGoal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
          _scopeMeta, scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta));
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('bank_account_id')) {
      context.handle(
          _bankAccountIdMeta,
          bankAccountId.isAcceptableOrUnknown(
              data['bank_account_id']!, _bankAccountIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('goal_type')) {
      context.handle(_goalTypeMeta,
          goalType.isAcceptableOrUnknown(data['goal_type']!, _goalTypeMeta));
    } else if (isInserting) {
      context.missing(_goalTypeMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    }
    if (data.containsKey('monthly_target')) {
      context.handle(
          _monthlyTargetMeta,
          monthlyTarget.isAcceptableOrUnknown(
              data['monthly_target']!, _monthlyTargetMeta));
    }
    if (data.containsKey('current_amount')) {
      context.handle(
          _currentAmountMeta,
          currentAmount.isAcceptableOrUnknown(
              data['current_amount']!, _currentAmountMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update']!, _lastUpdateMeta));
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalGoal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      scope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      bankAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_account_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      goalType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal_type'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_amount']),
      monthlyTarget: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monthly_target']),
      currentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_amount'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_date']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_update'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $LocalGoalsTable createAlias(String alias) {
    return $LocalGoalsTable(attachedDatabase, alias);
  }
}

class LocalGoal extends DataClass implements Insertable<LocalGoal> {
  final String id;
  final String householdId;
  final String scope;
  final String? ownerId;
  final String? bankAccountId;
  final String name;
  final String goalType;
  final double? targetAmount;
  final double? monthlyTarget;
  final double currentAmount;
  final String currency;
  final int startDate;
  final int? endDate;
  final bool isActive;
  final String? color;
  final String? icon;
  final int createdAt;
  final int lastUpdate;
  final bool isSynced;
  const LocalGoal(
      {required this.id,
      required this.householdId,
      required this.scope,
      this.ownerId,
      this.bankAccountId,
      required this.name,
      required this.goalType,
      this.targetAmount,
      this.monthlyTarget,
      required this.currentAmount,
      required this.currency,
      required this.startDate,
      this.endDate,
      required this.isActive,
      this.color,
      this.icon,
      required this.createdAt,
      required this.lastUpdate,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || bankAccountId != null) {
      map['bank_account_id'] = Variable<String>(bankAccountId);
    }
    map['name'] = Variable<String>(name);
    map['goal_type'] = Variable<String>(goalType);
    if (!nullToAbsent || targetAmount != null) {
      map['target_amount'] = Variable<double>(targetAmount);
    }
    if (!nullToAbsent || monthlyTarget != null) {
      map['monthly_target'] = Variable<double>(monthlyTarget);
    }
    map['current_amount'] = Variable<double>(currentAmount);
    map['currency'] = Variable<String>(currency);
    map['start_date'] = Variable<int>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<int>(endDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['last_update'] = Variable<int>(lastUpdate);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalGoalsCompanion toCompanion(bool nullToAbsent) {
    return LocalGoalsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      scope: Value(scope),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      bankAccountId: bankAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(bankAccountId),
      name: Value(name),
      goalType: Value(goalType),
      targetAmount: targetAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(targetAmount),
      monthlyTarget: monthlyTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyTarget),
      currentAmount: Value(currentAmount),
      currency: Value(currency),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isActive: Value(isActive),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      createdAt: Value(createdAt),
      lastUpdate: Value(lastUpdate),
      isSynced: Value(isSynced),
    );
  }

  factory LocalGoal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalGoal(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      scope: serializer.fromJson<String>(json['scope']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      bankAccountId: serializer.fromJson<String?>(json['bankAccountId']),
      name: serializer.fromJson<String>(json['name']),
      goalType: serializer.fromJson<String>(json['goalType']),
      targetAmount: serializer.fromJson<double?>(json['targetAmount']),
      monthlyTarget: serializer.fromJson<double?>(json['monthlyTarget']),
      currentAmount: serializer.fromJson<double>(json['currentAmount']),
      currency: serializer.fromJson<String>(json['currency']),
      startDate: serializer.fromJson<int>(json['startDate']),
      endDate: serializer.fromJson<int?>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      color: serializer.fromJson<String?>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastUpdate: serializer.fromJson<int>(json['lastUpdate']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'scope': serializer.toJson<String>(scope),
      'ownerId': serializer.toJson<String?>(ownerId),
      'bankAccountId': serializer.toJson<String?>(bankAccountId),
      'name': serializer.toJson<String>(name),
      'goalType': serializer.toJson<String>(goalType),
      'targetAmount': serializer.toJson<double?>(targetAmount),
      'monthlyTarget': serializer.toJson<double?>(monthlyTarget),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'currency': serializer.toJson<String>(currency),
      'startDate': serializer.toJson<int>(startDate),
      'endDate': serializer.toJson<int?>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
      'color': serializer.toJson<String?>(color),
      'icon': serializer.toJson<String?>(icon),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastUpdate': serializer.toJson<int>(lastUpdate),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalGoal copyWith(
          {String? id,
          String? householdId,
          String? scope,
          Value<String?> ownerId = const Value.absent(),
          Value<String?> bankAccountId = const Value.absent(),
          String? name,
          String? goalType,
          Value<double?> targetAmount = const Value.absent(),
          Value<double?> monthlyTarget = const Value.absent(),
          double? currentAmount,
          String? currency,
          int? startDate,
          Value<int?> endDate = const Value.absent(),
          bool? isActive,
          Value<String?> color = const Value.absent(),
          Value<String?> icon = const Value.absent(),
          int? createdAt,
          int? lastUpdate,
          bool? isSynced}) =>
      LocalGoal(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        scope: scope ?? this.scope,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        bankAccountId:
            bankAccountId.present ? bankAccountId.value : this.bankAccountId,
        name: name ?? this.name,
        goalType: goalType ?? this.goalType,
        targetAmount:
            targetAmount.present ? targetAmount.value : this.targetAmount,
        monthlyTarget:
            monthlyTarget.present ? monthlyTarget.value : this.monthlyTarget,
        currentAmount: currentAmount ?? this.currentAmount,
        currency: currency ?? this.currency,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        isActive: isActive ?? this.isActive,
        color: color.present ? color.value : this.color,
        icon: icon.present ? icon.value : this.icon,
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        isSynced: isSynced ?? this.isSynced,
      );
  LocalGoal copyWithCompanion(LocalGoalsCompanion data) {
    return LocalGoal(
      id: data.id.present ? data.id.value : this.id,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      scope: data.scope.present ? data.scope.value : this.scope,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      bankAccountId: data.bankAccountId.present
          ? data.bankAccountId.value
          : this.bankAccountId,
      name: data.name.present ? data.name.value : this.name,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      monthlyTarget: data.monthlyTarget.present
          ? data.monthlyTarget.value
          : this.monthlyTarget,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      currency: data.currency.present ? data.currency.value : this.currency,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdate:
          data.lastUpdate.present ? data.lastUpdate.value : this.lastUpdate,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalGoal(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('scope: $scope, ')
          ..write('ownerId: $ownerId, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('name: $name, ')
          ..write('goalType: $goalType, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('monthlyTarget: $monthlyTarget, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('currency: $currency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      householdId,
      scope,
      ownerId,
      bankAccountId,
      name,
      goalType,
      targetAmount,
      monthlyTarget,
      currentAmount,
      currency,
      startDate,
      endDate,
      isActive,
      color,
      icon,
      createdAt,
      lastUpdate,
      isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalGoal &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.scope == this.scope &&
          other.ownerId == this.ownerId &&
          other.bankAccountId == this.bankAccountId &&
          other.name == this.name &&
          other.goalType == this.goalType &&
          other.targetAmount == this.targetAmount &&
          other.monthlyTarget == this.monthlyTarget &&
          other.currentAmount == this.currentAmount &&
          other.currency == this.currency &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.createdAt == this.createdAt &&
          other.lastUpdate == this.lastUpdate &&
          other.isSynced == this.isSynced);
}

class LocalGoalsCompanion extends UpdateCompanion<LocalGoal> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> scope;
  final Value<String?> ownerId;
  final Value<String?> bankAccountId;
  final Value<String> name;
  final Value<String> goalType;
  final Value<double?> targetAmount;
  final Value<double?> monthlyTarget;
  final Value<double> currentAmount;
  final Value<String> currency;
  final Value<int> startDate;
  final Value<int?> endDate;
  final Value<bool> isActive;
  final Value<String?> color;
  final Value<String?> icon;
  final Value<int> createdAt;
  final Value<int> lastUpdate;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalGoalsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.scope = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    this.name = const Value.absent(),
    this.goalType = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.monthlyTarget = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.currency = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalGoalsCompanion.insert({
    required String id,
    required String householdId,
    required String scope,
    this.ownerId = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    required String name,
    required String goalType,
    this.targetAmount = const Value.absent(),
    this.monthlyTarget = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.currency = const Value.absent(),
    required int startDate,
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    required int createdAt,
    required int lastUpdate,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        householdId = Value(householdId),
        scope = Value(scope),
        name = Value(name),
        goalType = Value(goalType),
        startDate = Value(startDate),
        createdAt = Value(createdAt),
        lastUpdate = Value(lastUpdate);
  static Insertable<LocalGoal> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? scope,
    Expression<String>? ownerId,
    Expression<String>? bankAccountId,
    Expression<String>? name,
    Expression<String>? goalType,
    Expression<double>? targetAmount,
    Expression<double>? monthlyTarget,
    Expression<double>? currentAmount,
    Expression<String>? currency,
    Expression<int>? startDate,
    Expression<int>? endDate,
    Expression<bool>? isActive,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<int>? createdAt,
    Expression<int>? lastUpdate,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (scope != null) 'scope': scope,
      if (ownerId != null) 'owner_id': ownerId,
      if (bankAccountId != null) 'bank_account_id': bankAccountId,
      if (name != null) 'name': name,
      if (goalType != null) 'goal_type': goalType,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (monthlyTarget != null) 'monthly_target': monthlyTarget,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (currency != null) 'currency': currency,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalGoalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? householdId,
      Value<String>? scope,
      Value<String?>? ownerId,
      Value<String?>? bankAccountId,
      Value<String>? name,
      Value<String>? goalType,
      Value<double?>? targetAmount,
      Value<double?>? monthlyTarget,
      Value<double>? currentAmount,
      Value<String>? currency,
      Value<int>? startDate,
      Value<int?>? endDate,
      Value<bool>? isActive,
      Value<String?>? color,
      Value<String?>? icon,
      Value<int>? createdAt,
      Value<int>? lastUpdate,
      Value<bool>? isSynced,
      Value<int>? rowid}) {
    return LocalGoalsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      scope: scope ?? this.scope,
      ownerId: ownerId ?? this.ownerId,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      name: name ?? this.name,
      goalType: goalType ?? this.goalType,
      targetAmount: targetAmount ?? this.targetAmount,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (bankAccountId.present) {
      map['bank_account_id'] = Variable<String>(bankAccountId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (goalType.present) {
      map['goal_type'] = Variable<String>(goalType.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (monthlyTarget.present) {
      map['monthly_target'] = Variable<double>(monthlyTarget.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<double>(currentAmount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<int>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<int>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<int>(lastUpdate.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalGoalsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('scope: $scope, ')
          ..write('ownerId: $ownerId, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('name: $name, ')
          ..write('goalType: $goalType, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('monthlyTarget: $monthlyTarget, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('currency: $currency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalNotificationsTable extends LocalNotifications
    with TableInfo<$LocalNotificationsTable, LocalNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, householdId, title, body, type, payload, isRead, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_notifications';
  @override
  VerificationContext validateIntegrity(Insertable<LocalNotification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalNotification(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LocalNotificationsTable createAlias(String alias) {
    return $LocalNotificationsTable(attachedDatabase, alias);
  }
}

class LocalNotification extends DataClass
    implements Insertable<LocalNotification> {
  final String id;
  final String userId;
  final String householdId;
  final String title;
  final String body;
  final String type;
  final String? payload;
  final bool isRead;
  final int createdAt;
  const LocalNotification(
      {required this.id,
      required this.userId,
      required this.householdId,
      required this.title,
      required this.body,
      required this.type,
      this.payload,
      required this.isRead,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['household_id'] = Variable<String>(householdId);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  LocalNotificationsCompanion toCompanion(bool nullToAbsent) {
    return LocalNotificationsCompanion(
      id: Value(id),
      userId: Value(userId),
      householdId: Value(householdId),
      title: Value(title),
      body: Value(body),
      type: Value(type),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      isRead: Value(isRead),
      createdAt: Value(createdAt),
    );
  }

  factory LocalNotification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalNotification(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      type: serializer.fromJson<String>(json['type']),
      payload: serializer.fromJson<String?>(json['payload']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'householdId': serializer.toJson<String>(householdId),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'type': serializer.toJson<String>(type),
      'payload': serializer.toJson<String?>(payload),
      'isRead': serializer.toJson<bool>(isRead),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  LocalNotification copyWith(
          {String? id,
          String? userId,
          String? householdId,
          String? title,
          String? body,
          String? type,
          Value<String?> payload = const Value.absent(),
          bool? isRead,
          int? createdAt}) =>
      LocalNotification(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        householdId: householdId ?? this.householdId,
        title: title ?? this.title,
        body: body ?? this.body,
        type: type ?? this.type,
        payload: payload.present ? payload.value : this.payload,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
      );
  LocalNotification copyWithCompanion(LocalNotificationsCompanion data) {
    return LocalNotification(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      type: data.type.present ? data.type.value : this.type,
      payload: data.payload.present ? data.payload.value : this.payload,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalNotification(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('householdId: $householdId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userId, householdId, title, body, type, payload, isRead, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalNotification &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.householdId == this.householdId &&
          other.title == this.title &&
          other.body == this.body &&
          other.type == this.type &&
          other.payload == this.payload &&
          other.isRead == this.isRead &&
          other.createdAt == this.createdAt);
}

class LocalNotificationsCompanion extends UpdateCompanion<LocalNotification> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> householdId;
  final Value<String> title;
  final Value<String> body;
  final Value<String> type;
  final Value<String?> payload;
  final Value<bool> isRead;
  final Value<int> createdAt;
  final Value<int> rowid;
  const LocalNotificationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.type = const Value.absent(),
    this.payload = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalNotificationsCompanion.insert({
    required String id,
    required String userId,
    required String householdId,
    required String title,
    required String body,
    required String type,
    this.payload = const Value.absent(),
    this.isRead = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        householdId = Value(householdId),
        title = Value(title),
        body = Value(body),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<LocalNotification> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? householdId,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? type,
    Expression<String>? payload,
    Expression<bool>? isRead,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (householdId != null) 'household_id': householdId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (type != null) 'type': type,
      if (payload != null) 'payload': payload,
      if (isRead != null) 'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalNotificationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? householdId,
      Value<String>? title,
      Value<String>? body,
      Value<String>? type,
      Value<String?>? payload,
      Value<bool>? isRead,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return LocalNotificationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      householdId: householdId ?? this.householdId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('householdId: $householdId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFinancialInstitutionsTable extends LocalFinancialInstitutions
    with
        TableInfo<$LocalFinancialInstitutionsTable, LocalFinancialInstitution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFinancialInstitutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
      'slug', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _countryMeta =
      const VerificationMeta('country');
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
      'country', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _brandColorMeta =
      const VerificationMeta('brandColor');
  @override
  late final GeneratedColumn<String> brandColor = GeneratedColumn<String>(
      'brand_color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _logoAssetMeta =
      const VerificationMeta('logoAsset');
  @override
  late final GeneratedColumn<String> logoAsset = GeneratedColumn<String>(
      'logo_asset', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _institutionTypeMeta =
      const VerificationMeta('institutionType');
  @override
  late final GeneratedColumn<String> institutionType = GeneratedColumn<String>(
      'institution_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('bank'));
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdateMeta =
      const VerificationMeta('lastUpdate');
  @override
  late final GeneratedColumn<int> lastUpdate = GeneratedColumn<int>(
      'last_update', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        slug,
        country,
        brandColor,
        logoAsset,
        institutionType,
        isCustom,
        createdAt,
        lastUpdate,
        isSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_financial_institutions';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalFinancialInstitution> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
          _slugMeta, slug.isAcceptableOrUnknown(data['slug']!, _slugMeta));
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('country')) {
      context.handle(_countryMeta,
          country.isAcceptableOrUnknown(data['country']!, _countryMeta));
    }
    if (data.containsKey('brand_color')) {
      context.handle(
          _brandColorMeta,
          brandColor.isAcceptableOrUnknown(
              data['brand_color']!, _brandColorMeta));
    } else if (isInserting) {
      context.missing(_brandColorMeta);
    }
    if (data.containsKey('logo_asset')) {
      context.handle(_logoAssetMeta,
          logoAsset.isAcceptableOrUnknown(data['logo_asset']!, _logoAssetMeta));
    }
    if (data.containsKey('institution_type')) {
      context.handle(
          _institutionTypeMeta,
          institutionType.isAcceptableOrUnknown(
              data['institution_type']!, _institutionTypeMeta));
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update']!, _lastUpdateMeta));
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFinancialInstitution map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFinancialInstitution(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      slug: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}slug'])!,
      country: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country'])!,
      brandColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand_color'])!,
      logoAsset: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_asset']),
      institutionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}institution_type'])!,
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_update'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $LocalFinancialInstitutionsTable createAlias(String alias) {
    return $LocalFinancialInstitutionsTable(attachedDatabase, alias);
  }
}

class LocalFinancialInstitution extends DataClass
    implements Insertable<LocalFinancialInstitution> {
  final String id;
  final String name;
  final String slug;
  final String country;
  final String brandColor;
  final String? logoAsset;
  final String institutionType;
  final bool isCustom;
  final int createdAt;
  final int lastUpdate;
  final bool isSynced;
  const LocalFinancialInstitution(
      {required this.id,
      required this.name,
      required this.slug,
      required this.country,
      required this.brandColor,
      this.logoAsset,
      required this.institutionType,
      required this.isCustom,
      required this.createdAt,
      required this.lastUpdate,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['slug'] = Variable<String>(slug);
    map['country'] = Variable<String>(country);
    map['brand_color'] = Variable<String>(brandColor);
    if (!nullToAbsent || logoAsset != null) {
      map['logo_asset'] = Variable<String>(logoAsset);
    }
    map['institution_type'] = Variable<String>(institutionType);
    map['is_custom'] = Variable<bool>(isCustom);
    map['created_at'] = Variable<int>(createdAt);
    map['last_update'] = Variable<int>(lastUpdate);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalFinancialInstitutionsCompanion toCompanion(bool nullToAbsent) {
    return LocalFinancialInstitutionsCompanion(
      id: Value(id),
      name: Value(name),
      slug: Value(slug),
      country: Value(country),
      brandColor: Value(brandColor),
      logoAsset: logoAsset == null && nullToAbsent
          ? const Value.absent()
          : Value(logoAsset),
      institutionType: Value(institutionType),
      isCustom: Value(isCustom),
      createdAt: Value(createdAt),
      lastUpdate: Value(lastUpdate),
      isSynced: Value(isSynced),
    );
  }

  factory LocalFinancialInstitution.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFinancialInstitution(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      slug: serializer.fromJson<String>(json['slug']),
      country: serializer.fromJson<String>(json['country']),
      brandColor: serializer.fromJson<String>(json['brandColor']),
      logoAsset: serializer.fromJson<String?>(json['logoAsset']),
      institutionType: serializer.fromJson<String>(json['institutionType']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastUpdate: serializer.fromJson<int>(json['lastUpdate']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'slug': serializer.toJson<String>(slug),
      'country': serializer.toJson<String>(country),
      'brandColor': serializer.toJson<String>(brandColor),
      'logoAsset': serializer.toJson<String?>(logoAsset),
      'institutionType': serializer.toJson<String>(institutionType),
      'isCustom': serializer.toJson<bool>(isCustom),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastUpdate': serializer.toJson<int>(lastUpdate),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalFinancialInstitution copyWith(
          {String? id,
          String? name,
          String? slug,
          String? country,
          String? brandColor,
          Value<String?> logoAsset = const Value.absent(),
          String? institutionType,
          bool? isCustom,
          int? createdAt,
          int? lastUpdate,
          bool? isSynced}) =>
      LocalFinancialInstitution(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        country: country ?? this.country,
        brandColor: brandColor ?? this.brandColor,
        logoAsset: logoAsset.present ? logoAsset.value : this.logoAsset,
        institutionType: institutionType ?? this.institutionType,
        isCustom: isCustom ?? this.isCustom,
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        isSynced: isSynced ?? this.isSynced,
      );
  LocalFinancialInstitution copyWithCompanion(
      LocalFinancialInstitutionsCompanion data) {
    return LocalFinancialInstitution(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      slug: data.slug.present ? data.slug.value : this.slug,
      country: data.country.present ? data.country.value : this.country,
      brandColor:
          data.brandColor.present ? data.brandColor.value : this.brandColor,
      logoAsset: data.logoAsset.present ? data.logoAsset.value : this.logoAsset,
      institutionType: data.institutionType.present
          ? data.institutionType.value
          : this.institutionType,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdate:
          data.lastUpdate.present ? data.lastUpdate.value : this.lastUpdate,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFinancialInstitution(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('slug: $slug, ')
          ..write('country: $country, ')
          ..write('brandColor: $brandColor, ')
          ..write('logoAsset: $logoAsset, ')
          ..write('institutionType: $institutionType, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, slug, country, brandColor,
      logoAsset, institutionType, isCustom, createdAt, lastUpdate, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFinancialInstitution &&
          other.id == this.id &&
          other.name == this.name &&
          other.slug == this.slug &&
          other.country == this.country &&
          other.brandColor == this.brandColor &&
          other.logoAsset == this.logoAsset &&
          other.institutionType == this.institutionType &&
          other.isCustom == this.isCustom &&
          other.createdAt == this.createdAt &&
          other.lastUpdate == this.lastUpdate &&
          other.isSynced == this.isSynced);
}

class LocalFinancialInstitutionsCompanion
    extends UpdateCompanion<LocalFinancialInstitution> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> slug;
  final Value<String> country;
  final Value<String> brandColor;
  final Value<String?> logoAsset;
  final Value<String> institutionType;
  final Value<bool> isCustom;
  final Value<int> createdAt;
  final Value<int> lastUpdate;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalFinancialInstitutionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.slug = const Value.absent(),
    this.country = const Value.absent(),
    this.brandColor = const Value.absent(),
    this.logoAsset = const Value.absent(),
    this.institutionType = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFinancialInstitutionsCompanion.insert({
    required String id,
    required String name,
    required String slug,
    this.country = const Value.absent(),
    required String brandColor,
    this.logoAsset = const Value.absent(),
    this.institutionType = const Value.absent(),
    this.isCustom = const Value.absent(),
    required int createdAt,
    required int lastUpdate,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        slug = Value(slug),
        brandColor = Value(brandColor),
        createdAt = Value(createdAt),
        lastUpdate = Value(lastUpdate);
  static Insertable<LocalFinancialInstitution> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? slug,
    Expression<String>? country,
    Expression<String>? brandColor,
    Expression<String>? logoAsset,
    Expression<String>? institutionType,
    Expression<bool>? isCustom,
    Expression<int>? createdAt,
    Expression<int>? lastUpdate,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (slug != null) 'slug': slug,
      if (country != null) 'country': country,
      if (brandColor != null) 'brand_color': brandColor,
      if (logoAsset != null) 'logo_asset': logoAsset,
      if (institutionType != null) 'institution_type': institutionType,
      if (isCustom != null) 'is_custom': isCustom,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFinancialInstitutionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? slug,
      Value<String>? country,
      Value<String>? brandColor,
      Value<String?>? logoAsset,
      Value<String>? institutionType,
      Value<bool>? isCustom,
      Value<int>? createdAt,
      Value<int>? lastUpdate,
      Value<bool>? isSynced,
      Value<int>? rowid}) {
    return LocalFinancialInstitutionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      country: country ?? this.country,
      brandColor: brandColor ?? this.brandColor,
      logoAsset: logoAsset ?? this.logoAsset,
      institutionType: institutionType ?? this.institutionType,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (brandColor.present) {
      map['brand_color'] = Variable<String>(brandColor.value);
    }
    if (logoAsset.present) {
      map['logo_asset'] = Variable<String>(logoAsset.value);
    }
    if (institutionType.present) {
      map['institution_type'] = Variable<String>(institutionType.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<int>(lastUpdate.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFinancialInstitutionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('slug: $slug, ')
          ..write('country: $country, ')
          ..write('brandColor: $brandColor, ')
          ..write('logoAsset: $logoAsset, ')
          ..write('institutionType: $institutionType, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCardsTable extends LocalCards
    with TableInfo<$LocalCardsTable, LocalCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_bank_accounts (id)'));
  static const VerificationMeta _networkMeta =
      const VerificationMeta('network');
  @override
  late final GeneratedColumn<String> network = GeneratedColumn<String>(
      'network', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _last4Meta = const VerificationMeta('last4');
  @override
  late final GeneratedColumn<String> last4 = GeneratedColumn<String>(
      'last4', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expiryMonthMeta =
      const VerificationMeta('expiryMonth');
  @override
  late final GeneratedColumn<int> expiryMonth = GeneratedColumn<int>(
      'expiry_month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _expiryYearMeta =
      const VerificationMeta('expiryYear');
  @override
  late final GeneratedColumn<int> expiryYear = GeneratedColumn<int>(
      'expiry_year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cardholderNameMeta =
      const VerificationMeta('cardholderName');
  @override
  late final GeneratedColumn<String> cardholderName = GeneratedColumn<String>(
      'cardholder_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isVirtualMeta =
      const VerificationMeta('isVirtual');
  @override
  late final GeneratedColumn<bool> isVirtual = GeneratedColumn<bool>(
      'is_virtual', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_virtual" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPrimaryMeta =
      const VerificationMeta('isPrimary');
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
      'is_primary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_primary" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _ownerProfileIdMeta =
      const VerificationMeta('ownerProfileId');
  @override
  late final GeneratedColumn<String> ownerProfileId = GeneratedColumn<String>(
      'owner_profile_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdateMeta =
      const VerificationMeta('lastUpdate');
  @override
  late final GeneratedColumn<int> lastUpdate = GeneratedColumn<int>(
      'last_update', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        accountId,
        network,
        last4,
        expiryMonth,
        expiryYear,
        cardholderName,
        isVirtual,
        isPrimary,
        isActive,
        ownerProfileId,
        color,
        sortOrder,
        createdAt,
        lastUpdate,
        isSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_cards';
  @override
  VerificationContext validateIntegrity(Insertable<LocalCard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('network')) {
      context.handle(_networkMeta,
          network.isAcceptableOrUnknown(data['network']!, _networkMeta));
    } else if (isInserting) {
      context.missing(_networkMeta);
    }
    if (data.containsKey('last4')) {
      context.handle(
          _last4Meta, last4.isAcceptableOrUnknown(data['last4']!, _last4Meta));
    } else if (isInserting) {
      context.missing(_last4Meta);
    }
    if (data.containsKey('expiry_month')) {
      context.handle(
          _expiryMonthMeta,
          expiryMonth.isAcceptableOrUnknown(
              data['expiry_month']!, _expiryMonthMeta));
    } else if (isInserting) {
      context.missing(_expiryMonthMeta);
    }
    if (data.containsKey('expiry_year')) {
      context.handle(
          _expiryYearMeta,
          expiryYear.isAcceptableOrUnknown(
              data['expiry_year']!, _expiryYearMeta));
    } else if (isInserting) {
      context.missing(_expiryYearMeta);
    }
    if (data.containsKey('cardholder_name')) {
      context.handle(
          _cardholderNameMeta,
          cardholderName.isAcceptableOrUnknown(
              data['cardholder_name']!, _cardholderNameMeta));
    } else if (isInserting) {
      context.missing(_cardholderNameMeta);
    }
    if (data.containsKey('is_virtual')) {
      context.handle(_isVirtualMeta,
          isVirtual.isAcceptableOrUnknown(data['is_virtual']!, _isVirtualMeta));
    }
    if (data.containsKey('is_primary')) {
      context.handle(_isPrimaryMeta,
          isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('owner_profile_id')) {
      context.handle(
          _ownerProfileIdMeta,
          ownerProfileId.isAcceptableOrUnknown(
              data['owner_profile_id']!, _ownerProfileIdMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update']!, _lastUpdateMeta));
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCard(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      network: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}network'])!,
      last4: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last4'])!,
      expiryMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expiry_month'])!,
      expiryYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expiry_year'])!,
      cardholderName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cardholder_name'])!,
      isVirtual: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_virtual'])!,
      isPrimary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_primary'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      ownerProfileId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}owner_profile_id']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_update'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $LocalCardsTable createAlias(String alias) {
    return $LocalCardsTable(attachedDatabase, alias);
  }
}

class LocalCard extends DataClass implements Insertable<LocalCard> {
  final String id;
  final String accountId;
  final String network;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final String cardholderName;
  final bool isVirtual;
  final bool isPrimary;
  final bool isActive;
  final String? ownerProfileId;
  final String? color;
  final int sortOrder;
  final int createdAt;
  final int lastUpdate;
  final bool isSynced;
  const LocalCard(
      {required this.id,
      required this.accountId,
      required this.network,
      required this.last4,
      required this.expiryMonth,
      required this.expiryYear,
      required this.cardholderName,
      required this.isVirtual,
      required this.isPrimary,
      required this.isActive,
      this.ownerProfileId,
      this.color,
      required this.sortOrder,
      required this.createdAt,
      required this.lastUpdate,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['network'] = Variable<String>(network);
    map['last4'] = Variable<String>(last4);
    map['expiry_month'] = Variable<int>(expiryMonth);
    map['expiry_year'] = Variable<int>(expiryYear);
    map['cardholder_name'] = Variable<String>(cardholderName);
    map['is_virtual'] = Variable<bool>(isVirtual);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || ownerProfileId != null) {
      map['owner_profile_id'] = Variable<String>(ownerProfileId);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    map['last_update'] = Variable<int>(lastUpdate);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalCardsCompanion toCompanion(bool nullToAbsent) {
    return LocalCardsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      network: Value(network),
      last4: Value(last4),
      expiryMonth: Value(expiryMonth),
      expiryYear: Value(expiryYear),
      cardholderName: Value(cardholderName),
      isVirtual: Value(isVirtual),
      isPrimary: Value(isPrimary),
      isActive: Value(isActive),
      ownerProfileId: ownerProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerProfileId),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      lastUpdate: Value(lastUpdate),
      isSynced: Value(isSynced),
    );
  }

  factory LocalCard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCard(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      network: serializer.fromJson<String>(json['network']),
      last4: serializer.fromJson<String>(json['last4']),
      expiryMonth: serializer.fromJson<int>(json['expiryMonth']),
      expiryYear: serializer.fromJson<int>(json['expiryYear']),
      cardholderName: serializer.fromJson<String>(json['cardholderName']),
      isVirtual: serializer.fromJson<bool>(json['isVirtual']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      ownerProfileId: serializer.fromJson<String?>(json['ownerProfileId']),
      color: serializer.fromJson<String?>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastUpdate: serializer.fromJson<int>(json['lastUpdate']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'network': serializer.toJson<String>(network),
      'last4': serializer.toJson<String>(last4),
      'expiryMonth': serializer.toJson<int>(expiryMonth),
      'expiryYear': serializer.toJson<int>(expiryYear),
      'cardholderName': serializer.toJson<String>(cardholderName),
      'isVirtual': serializer.toJson<bool>(isVirtual),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'isActive': serializer.toJson<bool>(isActive),
      'ownerProfileId': serializer.toJson<String?>(ownerProfileId),
      'color': serializer.toJson<String?>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastUpdate': serializer.toJson<int>(lastUpdate),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalCard copyWith(
          {String? id,
          String? accountId,
          String? network,
          String? last4,
          int? expiryMonth,
          int? expiryYear,
          String? cardholderName,
          bool? isVirtual,
          bool? isPrimary,
          bool? isActive,
          Value<String?> ownerProfileId = const Value.absent(),
          Value<String?> color = const Value.absent(),
          int? sortOrder,
          int? createdAt,
          int? lastUpdate,
          bool? isSynced}) =>
      LocalCard(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        network: network ?? this.network,
        last4: last4 ?? this.last4,
        expiryMonth: expiryMonth ?? this.expiryMonth,
        expiryYear: expiryYear ?? this.expiryYear,
        cardholderName: cardholderName ?? this.cardholderName,
        isVirtual: isVirtual ?? this.isVirtual,
        isPrimary: isPrimary ?? this.isPrimary,
        isActive: isActive ?? this.isActive,
        ownerProfileId:
            ownerProfileId.present ? ownerProfileId.value : this.ownerProfileId,
        color: color.present ? color.value : this.color,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        isSynced: isSynced ?? this.isSynced,
      );
  LocalCard copyWithCompanion(LocalCardsCompanion data) {
    return LocalCard(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      network: data.network.present ? data.network.value : this.network,
      last4: data.last4.present ? data.last4.value : this.last4,
      expiryMonth:
          data.expiryMonth.present ? data.expiryMonth.value : this.expiryMonth,
      expiryYear:
          data.expiryYear.present ? data.expiryYear.value : this.expiryYear,
      cardholderName: data.cardholderName.present
          ? data.cardholderName.value
          : this.cardholderName,
      isVirtual: data.isVirtual.present ? data.isVirtual.value : this.isVirtual,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      ownerProfileId: data.ownerProfileId.present
          ? data.ownerProfileId.value
          : this.ownerProfileId,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdate:
          data.lastUpdate.present ? data.lastUpdate.value : this.lastUpdate,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCard(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('network: $network, ')
          ..write('last4: $last4, ')
          ..write('expiryMonth: $expiryMonth, ')
          ..write('expiryYear: $expiryYear, ')
          ..write('cardholderName: $cardholderName, ')
          ..write('isVirtual: $isVirtual, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isActive: $isActive, ')
          ..write('ownerProfileId: $ownerProfileId, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      accountId,
      network,
      last4,
      expiryMonth,
      expiryYear,
      cardholderName,
      isVirtual,
      isPrimary,
      isActive,
      ownerProfileId,
      color,
      sortOrder,
      createdAt,
      lastUpdate,
      isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCard &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.network == this.network &&
          other.last4 == this.last4 &&
          other.expiryMonth == this.expiryMonth &&
          other.expiryYear == this.expiryYear &&
          other.cardholderName == this.cardholderName &&
          other.isVirtual == this.isVirtual &&
          other.isPrimary == this.isPrimary &&
          other.isActive == this.isActive &&
          other.ownerProfileId == this.ownerProfileId &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.lastUpdate == this.lastUpdate &&
          other.isSynced == this.isSynced);
}

class LocalCardsCompanion extends UpdateCompanion<LocalCard> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> network;
  final Value<String> last4;
  final Value<int> expiryMonth;
  final Value<int> expiryYear;
  final Value<String> cardholderName;
  final Value<bool> isVirtual;
  final Value<bool> isPrimary;
  final Value<bool> isActive;
  final Value<String?> ownerProfileId;
  final Value<String?> color;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  final Value<int> lastUpdate;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalCardsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.network = const Value.absent(),
    this.last4 = const Value.absent(),
    this.expiryMonth = const Value.absent(),
    this.expiryYear = const Value.absent(),
    this.cardholderName = const Value.absent(),
    this.isVirtual = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isActive = const Value.absent(),
    this.ownerProfileId = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCardsCompanion.insert({
    required String id,
    required String accountId,
    required String network,
    required String last4,
    required int expiryMonth,
    required int expiryYear,
    required String cardholderName,
    this.isVirtual = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isActive = const Value.absent(),
    this.ownerProfileId = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int createdAt,
    required int lastUpdate,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        accountId = Value(accountId),
        network = Value(network),
        last4 = Value(last4),
        expiryMonth = Value(expiryMonth),
        expiryYear = Value(expiryYear),
        cardholderName = Value(cardholderName),
        createdAt = Value(createdAt),
        lastUpdate = Value(lastUpdate);
  static Insertable<LocalCard> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? network,
    Expression<String>? last4,
    Expression<int>? expiryMonth,
    Expression<int>? expiryYear,
    Expression<String>? cardholderName,
    Expression<bool>? isVirtual,
    Expression<bool>? isPrimary,
    Expression<bool>? isActive,
    Expression<String>? ownerProfileId,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? lastUpdate,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (network != null) 'network': network,
      if (last4 != null) 'last4': last4,
      if (expiryMonth != null) 'expiry_month': expiryMonth,
      if (expiryYear != null) 'expiry_year': expiryYear,
      if (cardholderName != null) 'cardholder_name': cardholderName,
      if (isVirtual != null) 'is_virtual': isVirtual,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (isActive != null) 'is_active': isActive,
      if (ownerProfileId != null) 'owner_profile_id': ownerProfileId,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCardsCompanion copyWith(
      {Value<String>? id,
      Value<String>? accountId,
      Value<String>? network,
      Value<String>? last4,
      Value<int>? expiryMonth,
      Value<int>? expiryYear,
      Value<String>? cardholderName,
      Value<bool>? isVirtual,
      Value<bool>? isPrimary,
      Value<bool>? isActive,
      Value<String?>? ownerProfileId,
      Value<String?>? color,
      Value<int>? sortOrder,
      Value<int>? createdAt,
      Value<int>? lastUpdate,
      Value<bool>? isSynced,
      Value<int>? rowid}) {
    return LocalCardsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      network: network ?? this.network,
      last4: last4 ?? this.last4,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cardholderName: cardholderName ?? this.cardholderName,
      isVirtual: isVirtual ?? this.isVirtual,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      ownerProfileId: ownerProfileId ?? this.ownerProfileId,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (network.present) {
      map['network'] = Variable<String>(network.value);
    }
    if (last4.present) {
      map['last4'] = Variable<String>(last4.value);
    }
    if (expiryMonth.present) {
      map['expiry_month'] = Variable<int>(expiryMonth.value);
    }
    if (expiryYear.present) {
      map['expiry_year'] = Variable<int>(expiryYear.value);
    }
    if (cardholderName.present) {
      map['cardholder_name'] = Variable<String>(cardholderName.value);
    }
    if (isVirtual.present) {
      map['is_virtual'] = Variable<bool>(isVirtual.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (ownerProfileId.present) {
      map['owner_profile_id'] = Variable<String>(ownerProfileId.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<int>(lastUpdate.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCardsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('network: $network, ')
          ..write('last4: $last4, ')
          ..write('expiryMonth: $expiryMonth, ')
          ..write('expiryYear: $expiryYear, ')
          ..write('cardholderName: $cardholderName, ')
          ..write('isVirtual: $isVirtual, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isActive: $isActive, ')
          ..write('ownerProfileId: $ownerProfileId, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAccountMembersTable extends LocalAccountMembers
    with TableInfo<$LocalAccountMembersTable, LocalAccountMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAccountMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_bank_accounts (id)'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('owner'));
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<int> joinedAt = GeneratedColumn<int>(
      'joined_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, accountId, userId, role, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_account_members';
  @override
  VerificationContext validateIntegrity(Insertable<LocalAccountMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAccountMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAccountMember(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}joined_at'])!,
    );
  }

  @override
  $LocalAccountMembersTable createAlias(String alias) {
    return $LocalAccountMembersTable(attachedDatabase, alias);
  }
}

class LocalAccountMember extends DataClass
    implements Insertable<LocalAccountMember> {
  final String id;
  final String accountId;
  final String userId;
  final String role;
  final int joinedAt;
  const LocalAccountMember(
      {required this.id,
      required this.accountId,
      required this.userId,
      required this.role,
      required this.joinedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    map['joined_at'] = Variable<int>(joinedAt);
    return map;
  }

  LocalAccountMembersCompanion toCompanion(bool nullToAbsent) {
    return LocalAccountMembersCompanion(
      id: Value(id),
      accountId: Value(accountId),
      userId: Value(userId),
      role: Value(role),
      joinedAt: Value(joinedAt),
    );
  }

  factory LocalAccountMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAccountMember(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      joinedAt: serializer.fromJson<int>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'joinedAt': serializer.toJson<int>(joinedAt),
    };
  }

  LocalAccountMember copyWith(
          {String? id,
          String? accountId,
          String? userId,
          String? role,
          int? joinedAt}) =>
      LocalAccountMember(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        userId: userId ?? this.userId,
        role: role ?? this.role,
        joinedAt: joinedAt ?? this.joinedAt,
      );
  LocalAccountMember copyWithCompanion(LocalAccountMembersCompanion data) {
    return LocalAccountMember(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountMember(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accountId, userId, role, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAccountMember &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.joinedAt == this.joinedAt);
}

class LocalAccountMembersCompanion extends UpdateCompanion<LocalAccountMember> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> userId;
  final Value<String> role;
  final Value<int> joinedAt;
  final Value<int> rowid;
  const LocalAccountMembersCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAccountMembersCompanion.insert({
    required String id,
    required String accountId,
    required String userId,
    this.role = const Value.absent(),
    required int joinedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        accountId = Value(accountId),
        userId = Value(userId),
        joinedAt = Value(joinedAt);
  static Insertable<LocalAccountMember> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<int>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAccountMembersCompanion copyWith(
      {Value<String>? id,
      Value<String>? accountId,
      Value<String>? userId,
      Value<String>? role,
      Value<int>? joinedAt,
      Value<int>? rowid}) {
    return LocalAccountMembersCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<int>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountMembersCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalShoppingSessionsTable extends LocalShoppingSessions
    with TableInfo<$LocalShoppingSessionsTable, LocalShoppingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalShoppingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
      'scope', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bankAccountIdMeta =
      const VerificationMeta('bankAccountId');
  @override
  late final GeneratedColumn<String> bankAccountId = GeneratedColumn<String>(
      'bank_account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transactionSourceIdMeta =
      const VerificationMeta('transactionSourceId');
  @override
  late final GeneratedColumn<String> transactionSourceId =
      GeneratedColumn<String>('transaction_source_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
      'started_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<int> paidAt = GeneratedColumn<int>(
      'paid_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdateMeta =
      const VerificationMeta('lastUpdate');
  @override
  late final GeneratedColumn<int> lastUpdate = GeneratedColumn<int>(
      'last_update', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        householdId,
        ownerId,
        name,
        scope,
        status,
        templateId,
        bankAccountId,
        transactionSourceId,
        transactionId,
        startedAt,
        endedAt,
        paidAt,
        createdAt,
        lastUpdate,
        isSynced,
        isDirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_shopping_sessions';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalShoppingSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
          _scopeMeta, scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta));
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    }
    if (data.containsKey('bank_account_id')) {
      context.handle(
          _bankAccountIdMeta,
          bankAccountId.isAcceptableOrUnknown(
              data['bank_account_id']!, _bankAccountIdMeta));
    }
    if (data.containsKey('transaction_source_id')) {
      context.handle(
          _transactionSourceIdMeta,
          transactionSourceId.isAcceptableOrUnknown(
              data['transaction_source_id']!, _transactionSourceIdMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('paid_at')) {
      context.handle(_paidAtMeta,
          paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update']!, _lastUpdateMeta));
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalShoppingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalShoppingSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      scope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id']),
      bankAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_account_id']),
      transactionSourceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_source_id']),
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ended_at']),
      paidAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paid_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_update'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
    );
  }

  @override
  $LocalShoppingSessionsTable createAlias(String alias) {
    return $LocalShoppingSessionsTable(attachedDatabase, alias);
  }
}

class LocalShoppingSession extends DataClass
    implements Insertable<LocalShoppingSession> {
  final String id;
  final String householdId;
  final String ownerId;
  final String name;
  final String scope;
  final String status;
  final String? templateId;
  final String? bankAccountId;
  final String? transactionSourceId;
  final String? transactionId;
  final int startedAt;
  final int? endedAt;
  final int? paidAt;
  final int createdAt;
  final int lastUpdate;
  final bool isSynced;
  final bool isDirty;
  const LocalShoppingSession(
      {required this.id,
      required this.householdId,
      required this.ownerId,
      required this.name,
      required this.scope,
      required this.status,
      this.templateId,
      this.bankAccountId,
      this.transactionSourceId,
      this.transactionId,
      required this.startedAt,
      this.endedAt,
      this.paidAt,
      required this.createdAt,
      required this.lastUpdate,
      required this.isSynced,
      required this.isDirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    map['scope'] = Variable<String>(scope);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    if (!nullToAbsent || bankAccountId != null) {
      map['bank_account_id'] = Variable<String>(bankAccountId);
    }
    if (!nullToAbsent || transactionSourceId != null) {
      map['transaction_source_id'] = Variable<String>(transactionSourceId);
    }
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    if (!nullToAbsent || paidAt != null) {
      map['paid_at'] = Variable<int>(paidAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['last_update'] = Variable<int>(lastUpdate);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  LocalShoppingSessionsCompanion toCompanion(bool nullToAbsent) {
    return LocalShoppingSessionsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      ownerId: Value(ownerId),
      name: Value(name),
      scope: Value(scope),
      status: Value(status),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      bankAccountId: bankAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(bankAccountId),
      transactionSourceId: transactionSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionSourceId),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      paidAt:
          paidAt == null && nullToAbsent ? const Value.absent() : Value(paidAt),
      createdAt: Value(createdAt),
      lastUpdate: Value(lastUpdate),
      isSynced: Value(isSynced),
      isDirty: Value(isDirty),
    );
  }

  factory LocalShoppingSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalShoppingSession(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      scope: serializer.fromJson<String>(json['scope']),
      status: serializer.fromJson<String>(json['status']),
      templateId: serializer.fromJson<String?>(json['templateId']),
      bankAccountId: serializer.fromJson<String?>(json['bankAccountId']),
      transactionSourceId:
          serializer.fromJson<String?>(json['transactionSourceId']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      paidAt: serializer.fromJson<int?>(json['paidAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastUpdate: serializer.fromJson<int>(json['lastUpdate']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'scope': serializer.toJson<String>(scope),
      'status': serializer.toJson<String>(status),
      'templateId': serializer.toJson<String?>(templateId),
      'bankAccountId': serializer.toJson<String?>(bankAccountId),
      'transactionSourceId': serializer.toJson<String?>(transactionSourceId),
      'transactionId': serializer.toJson<String?>(transactionId),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'paidAt': serializer.toJson<int?>(paidAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastUpdate': serializer.toJson<int>(lastUpdate),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  LocalShoppingSession copyWith(
          {String? id,
          String? householdId,
          String? ownerId,
          String? name,
          String? scope,
          String? status,
          Value<String?> templateId = const Value.absent(),
          Value<String?> bankAccountId = const Value.absent(),
          Value<String?> transactionSourceId = const Value.absent(),
          Value<String?> transactionId = const Value.absent(),
          int? startedAt,
          Value<int?> endedAt = const Value.absent(),
          Value<int?> paidAt = const Value.absent(),
          int? createdAt,
          int? lastUpdate,
          bool? isSynced,
          bool? isDirty}) =>
      LocalShoppingSession(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        ownerId: ownerId ?? this.ownerId,
        name: name ?? this.name,
        scope: scope ?? this.scope,
        status: status ?? this.status,
        templateId: templateId.present ? templateId.value : this.templateId,
        bankAccountId:
            bankAccountId.present ? bankAccountId.value : this.bankAccountId,
        transactionSourceId: transactionSourceId.present
            ? transactionSourceId.value
            : this.transactionSourceId,
        transactionId:
            transactionId.present ? transactionId.value : this.transactionId,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        paidAt: paidAt.present ? paidAt.value : this.paidAt,
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        isSynced: isSynced ?? this.isSynced,
        isDirty: isDirty ?? this.isDirty,
      );
  LocalShoppingSession copyWithCompanion(LocalShoppingSessionsCompanion data) {
    return LocalShoppingSession(
      id: data.id.present ? data.id.value : this.id,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      scope: data.scope.present ? data.scope.value : this.scope,
      status: data.status.present ? data.status.value : this.status,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      bankAccountId: data.bankAccountId.present
          ? data.bankAccountId.value
          : this.bankAccountId,
      transactionSourceId: data.transactionSourceId.present
          ? data.transactionSourceId.value
          : this.transactionSourceId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdate:
          data.lastUpdate.present ? data.lastUpdate.value : this.lastUpdate,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalShoppingSession(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('scope: $scope, ')
          ..write('status: $status, ')
          ..write('templateId: $templateId, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('transactionSourceId: $transactionSourceId, ')
          ..write('transactionId: $transactionId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      householdId,
      ownerId,
      name,
      scope,
      status,
      templateId,
      bankAccountId,
      transactionSourceId,
      transactionId,
      startedAt,
      endedAt,
      paidAt,
      createdAt,
      lastUpdate,
      isSynced,
      isDirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalShoppingSession &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.scope == this.scope &&
          other.status == this.status &&
          other.templateId == this.templateId &&
          other.bankAccountId == this.bankAccountId &&
          other.transactionSourceId == this.transactionSourceId &&
          other.transactionId == this.transactionId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.paidAt == this.paidAt &&
          other.createdAt == this.createdAt &&
          other.lastUpdate == this.lastUpdate &&
          other.isSynced == this.isSynced &&
          other.isDirty == this.isDirty);
}

class LocalShoppingSessionsCompanion
    extends UpdateCompanion<LocalShoppingSession> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<String> scope;
  final Value<String> status;
  final Value<String?> templateId;
  final Value<String?> bankAccountId;
  final Value<String?> transactionSourceId;
  final Value<String?> transactionId;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<int?> paidAt;
  final Value<int> createdAt;
  final Value<int> lastUpdate;
  final Value<bool> isSynced;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const LocalShoppingSessionsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.scope = const Value.absent(),
    this.status = const Value.absent(),
    this.templateId = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    this.transactionSourceId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalShoppingSessionsCompanion.insert({
    required String id,
    required String householdId,
    required String ownerId,
    required String name,
    required String scope,
    required String status,
    this.templateId = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    this.transactionSourceId = const Value.absent(),
    this.transactionId = const Value.absent(),
    required int startedAt,
    this.endedAt = const Value.absent(),
    this.paidAt = const Value.absent(),
    required int createdAt,
    required int lastUpdate,
    this.isSynced = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        householdId = Value(householdId),
        ownerId = Value(ownerId),
        name = Value(name),
        scope = Value(scope),
        status = Value(status),
        startedAt = Value(startedAt),
        createdAt = Value(createdAt),
        lastUpdate = Value(lastUpdate);
  static Insertable<LocalShoppingSession> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? scope,
    Expression<String>? status,
    Expression<String>? templateId,
    Expression<String>? bankAccountId,
    Expression<String>? transactionSourceId,
    Expression<String>? transactionId,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? paidAt,
    Expression<int>? createdAt,
    Expression<int>? lastUpdate,
    Expression<bool>? isSynced,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (scope != null) 'scope': scope,
      if (status != null) 'status': status,
      if (templateId != null) 'template_id': templateId,
      if (bankAccountId != null) 'bank_account_id': bankAccountId,
      if (transactionSourceId != null)
        'transaction_source_id': transactionSourceId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (paidAt != null) 'paid_at': paidAt,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalShoppingSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? householdId,
      Value<String>? ownerId,
      Value<String>? name,
      Value<String>? scope,
      Value<String>? status,
      Value<String?>? templateId,
      Value<String?>? bankAccountId,
      Value<String?>? transactionSourceId,
      Value<String?>? transactionId,
      Value<int>? startedAt,
      Value<int?>? endedAt,
      Value<int?>? paidAt,
      Value<int>? createdAt,
      Value<int>? lastUpdate,
      Value<bool>? isSynced,
      Value<bool>? isDirty,
      Value<int>? rowid}) {
    return LocalShoppingSessionsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      scope: scope ?? this.scope,
      status: status ?? this.status,
      templateId: templateId ?? this.templateId,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      transactionSourceId: transactionSourceId ?? this.transactionSourceId,
      transactionId: transactionId ?? this.transactionId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isSynced: isSynced ?? this.isSynced,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (bankAccountId.present) {
      map['bank_account_id'] = Variable<String>(bankAccountId.value);
    }
    if (transactionSourceId.present) {
      map['transaction_source_id'] =
          Variable<String>(transactionSourceId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<int>(paidAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<int>(lastUpdate.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalShoppingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('scope: $scope, ')
          ..write('status: $status, ')
          ..write('templateId: $templateId, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('transactionSourceId: $transactionSourceId, ')
          ..write('transactionId: $transactionId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalShoppingSessionItemsTable extends LocalShoppingSessionItems
    with TableInfo<$LocalShoppingSessionItemsTable, LocalShoppingSessionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalShoppingSessionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_shopping_sessions (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
      'qty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isCheckedMeta =
      const VerificationMeta('isChecked');
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
      'is_checked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_checked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _checkedAtMeta =
      const VerificationMeta('checkedAt');
  @override
  late final GeneratedColumn<int> checkedAt = GeneratedColumn<int>(
      'checked_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdateMeta =
      const VerificationMeta('lastUpdate');
  @override
  late final GeneratedColumn<int> lastUpdate = GeneratedColumn<int>(
      'last_update', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        name,
        qty,
        sortOrder,
        isChecked,
        checkedAt,
        createdAt,
        lastUpdate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_shopping_session_items';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalShoppingSessionItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
          _qtyMeta, qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_checked')) {
      context.handle(_isCheckedMeta,
          isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta));
    }
    if (data.containsKey('checked_at')) {
      context.handle(_checkedAtMeta,
          checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update']!, _lastUpdateMeta));
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalShoppingSessionItem map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalShoppingSessionItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      qty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isChecked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_checked'])!,
      checkedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}checked_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_update'])!,
    );
  }

  @override
  $LocalShoppingSessionItemsTable createAlias(String alias) {
    return $LocalShoppingSessionItemsTable(attachedDatabase, alias);
  }
}

class LocalShoppingSessionItem extends DataClass
    implements Insertable<LocalShoppingSessionItem> {
  final String id;
  final String sessionId;
  final String name;
  final int qty;
  final int sortOrder;
  final bool isChecked;
  final int? checkedAt;
  final int createdAt;
  final int lastUpdate;
  const LocalShoppingSessionItem(
      {required this.id,
      required this.sessionId,
      required this.name,
      required this.qty,
      required this.sortOrder,
      required this.isChecked,
      this.checkedAt,
      required this.createdAt,
      required this.lastUpdate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['name'] = Variable<String>(name);
    map['qty'] = Variable<int>(qty);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_checked'] = Variable<bool>(isChecked);
    if (!nullToAbsent || checkedAt != null) {
      map['checked_at'] = Variable<int>(checkedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['last_update'] = Variable<int>(lastUpdate);
    return map;
  }

  LocalShoppingSessionItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalShoppingSessionItemsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      name: Value(name),
      qty: Value(qty),
      sortOrder: Value(sortOrder),
      isChecked: Value(isChecked),
      checkedAt: checkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedAt),
      createdAt: Value(createdAt),
      lastUpdate: Value(lastUpdate),
    );
  }

  factory LocalShoppingSessionItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalShoppingSessionItem(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      name: serializer.fromJson<String>(json['name']),
      qty: serializer.fromJson<int>(json['qty']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
      checkedAt: serializer.fromJson<int?>(json['checkedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastUpdate: serializer.fromJson<int>(json['lastUpdate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'name': serializer.toJson<String>(name),
      'qty': serializer.toJson<int>(qty),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isChecked': serializer.toJson<bool>(isChecked),
      'checkedAt': serializer.toJson<int?>(checkedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastUpdate': serializer.toJson<int>(lastUpdate),
    };
  }

  LocalShoppingSessionItem copyWith(
          {String? id,
          String? sessionId,
          String? name,
          int? qty,
          int? sortOrder,
          bool? isChecked,
          Value<int?> checkedAt = const Value.absent(),
          int? createdAt,
          int? lastUpdate}) =>
      LocalShoppingSessionItem(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        name: name ?? this.name,
        qty: qty ?? this.qty,
        sortOrder: sortOrder ?? this.sortOrder,
        isChecked: isChecked ?? this.isChecked,
        checkedAt: checkedAt.present ? checkedAt.value : this.checkedAt,
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
  LocalShoppingSessionItem copyWithCompanion(
      LocalShoppingSessionItemsCompanion data) {
    return LocalShoppingSessionItem(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      name: data.name.present ? data.name.value : this.name,
      qty: data.qty.present ? data.qty.value : this.qty,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdate:
          data.lastUpdate.present ? data.lastUpdate.value : this.lastUpdate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalShoppingSessionItem(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('name: $name, ')
          ..write('qty: $qty, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isChecked: $isChecked, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, name, qty, sortOrder,
      isChecked, checkedAt, createdAt, lastUpdate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalShoppingSessionItem &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.name == this.name &&
          other.qty == this.qty &&
          other.sortOrder == this.sortOrder &&
          other.isChecked == this.isChecked &&
          other.checkedAt == this.checkedAt &&
          other.createdAt == this.createdAt &&
          other.lastUpdate == this.lastUpdate);
}

class LocalShoppingSessionItemsCompanion
    extends UpdateCompanion<LocalShoppingSessionItem> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> name;
  final Value<int> qty;
  final Value<int> sortOrder;
  final Value<bool> isChecked;
  final Value<int?> checkedAt;
  final Value<int> createdAt;
  final Value<int> lastUpdate;
  final Value<int> rowid;
  const LocalShoppingSessionItemsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.name = const Value.absent(),
    this.qty = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalShoppingSessionItemsCompanion.insert({
    required String id,
    required String sessionId,
    required String name,
    this.qty = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.checkedAt = const Value.absent(),
    required int createdAt,
    required int lastUpdate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        name = Value(name),
        createdAt = Value(createdAt),
        lastUpdate = Value(lastUpdate);
  static Insertable<LocalShoppingSessionItem> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? name,
    Expression<int>? qty,
    Expression<int>? sortOrder,
    Expression<bool>? isChecked,
    Expression<int>? checkedAt,
    Expression<int>? createdAt,
    Expression<int>? lastUpdate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (name != null) 'name': name,
      if (qty != null) 'qty': qty,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isChecked != null) 'is_checked': isChecked,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalShoppingSessionItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? name,
      Value<int>? qty,
      Value<int>? sortOrder,
      Value<bool>? isChecked,
      Value<int?>? checkedAt,
      Value<int>? createdAt,
      Value<int>? lastUpdate,
      Value<int>? rowid}) {
    return LocalShoppingSessionItemsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      sortOrder: sortOrder ?? this.sortOrder,
      isChecked: isChecked ?? this.isChecked,
      checkedAt: checkedAt ?? this.checkedAt,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<int>(checkedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<int>(lastUpdate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalShoppingSessionItemsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('name: $name, ')
          ..write('qty: $qty, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isChecked: $isChecked, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalTransactionsTable localTransactions =
      $LocalTransactionsTable(this);
  late final $LocalCategoriesTable localCategories =
      $LocalCategoriesTable(this);
  late final $LocalBankAccountsTable localBankAccounts =
      $LocalBankAccountsTable(this);
  late final $LocalGoalsTable localGoals = $LocalGoalsTable(this);
  late final $LocalNotificationsTable localNotifications =
      $LocalNotificationsTable(this);
  late final $LocalFinancialInstitutionsTable localFinancialInstitutions =
      $LocalFinancialInstitutionsTable(this);
  late final $LocalCardsTable localCards = $LocalCardsTable(this);
  late final $LocalAccountMembersTable localAccountMembers =
      $LocalAccountMembersTable(this);
  late final $LocalShoppingSessionsTable localShoppingSessions =
      $LocalShoppingSessionsTable(this);
  late final $LocalShoppingSessionItemsTable localShoppingSessionItems =
      $LocalShoppingSessionItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localTransactions,
        localCategories,
        localBankAccounts,
        localGoals,
        localNotifications,
        localFinancialInstitutions,
        localCards,
        localAccountMembers,
        localShoppingSessions,
        localShoppingSessionItems
      ];
}

typedef $$LocalTransactionsTableCreateCompanionBuilder
    = LocalTransactionsCompanion Function({
  required String id,
  required String householdId,
  required String userId,
  required String categoryId,
  required String bankAccountId,
  Value<String?> transactionSourceId,
  Value<String?> paymentCardId,
  required double amount,
  required String type,
  Value<String?> note,
  required int date,
  Value<bool> isRecurring,
  Value<String?> recurringRule,
  required int createdAt,
  required int lastUpdate,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$LocalTransactionsTableUpdateCompanionBuilder
    = LocalTransactionsCompanion Function({
  Value<String> id,
  Value<String> householdId,
  Value<String> userId,
  Value<String> categoryId,
  Value<String> bankAccountId,
  Value<String?> transactionSourceId,
  Value<String?> paymentCardId,
  Value<double> amount,
  Value<String> type,
  Value<String?> note,
  Value<int> date,
  Value<bool> isRecurring,
  Value<String?> recurringRule,
  Value<int> createdAt,
  Value<int> lastUpdate,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$LocalTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankAccountId => $composableBuilder(
      column: $table.bankAccountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionSourceId => $composableBuilder(
      column: $table.transactionSourceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentCardId => $composableBuilder(
      column: $table.paymentCardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurringRule => $composableBuilder(
      column: $table.recurringRule, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
}

class $$LocalTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankAccountId => $composableBuilder(
      column: $table.bankAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionSourceId => $composableBuilder(
      column: $table.transactionSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentCardId => $composableBuilder(
      column: $table.paymentCardId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurringRule => $composableBuilder(
      column: $table.recurringRule,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$LocalTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get bankAccountId => $composableBuilder(
      column: $table.bankAccountId, builder: (column) => column);

  GeneratedColumn<String> get transactionSourceId => $composableBuilder(
      column: $table.transactionSourceId, builder: (column) => column);

  GeneratedColumn<String> get paymentCardId => $composableBuilder(
      column: $table.paymentCardId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<String> get recurringRule => $composableBuilder(
      column: $table.recurringRule, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$LocalTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalTransactionsTable,
    LocalTransaction,
    $$LocalTransactionsTableFilterComposer,
    $$LocalTransactionsTableOrderingComposer,
    $$LocalTransactionsTableAnnotationComposer,
    $$LocalTransactionsTableCreateCompanionBuilder,
    $$LocalTransactionsTableUpdateCompanionBuilder,
    (
      LocalTransaction,
      BaseReferences<_$AppDatabase, $LocalTransactionsTable, LocalTransaction>
    ),
    LocalTransaction,
    PrefetchHooks Function()> {
  $$LocalTransactionsTableTableManager(
      _$AppDatabase db, $LocalTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String> bankAccountId = const Value.absent(),
            Value<String?> transactionSourceId = const Value.absent(),
            Value<String?> paymentCardId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> date = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurringRule = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> lastUpdate = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTransactionsCompanion(
            id: id,
            householdId: householdId,
            userId: userId,
            categoryId: categoryId,
            bankAccountId: bankAccountId,
            transactionSourceId: transactionSourceId,
            paymentCardId: paymentCardId,
            amount: amount,
            type: type,
            note: note,
            date: date,
            isRecurring: isRecurring,
            recurringRule: recurringRule,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String householdId,
            required String userId,
            required String categoryId,
            required String bankAccountId,
            Value<String?> transactionSourceId = const Value.absent(),
            Value<String?> paymentCardId = const Value.absent(),
            required double amount,
            required String type,
            Value<String?> note = const Value.absent(),
            required int date,
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurringRule = const Value.absent(),
            required int createdAt,
            required int lastUpdate,
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTransactionsCompanion.insert(
            id: id,
            householdId: householdId,
            userId: userId,
            categoryId: categoryId,
            bankAccountId: bankAccountId,
            transactionSourceId: transactionSourceId,
            paymentCardId: paymentCardId,
            amount: amount,
            type: type,
            note: note,
            date: date,
            isRecurring: isRecurring,
            recurringRule: recurringRule,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalTransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalTransactionsTable,
    LocalTransaction,
    $$LocalTransactionsTableFilterComposer,
    $$LocalTransactionsTableOrderingComposer,
    $$LocalTransactionsTableAnnotationComposer,
    $$LocalTransactionsTableCreateCompanionBuilder,
    $$LocalTransactionsTableUpdateCompanionBuilder,
    (
      LocalTransaction,
      BaseReferences<_$AppDatabase, $LocalTransactionsTable, LocalTransaction>
    ),
    LocalTransaction,
    PrefetchHooks Function()>;
typedef $$LocalCategoriesTableCreateCompanionBuilder = LocalCategoriesCompanion
    Function({
  required String id,
  required String householdId,
  required String name,
  required String type,
  Value<String?> color,
  Value<String?> icon,
  Value<bool> isActive,
  Value<int> sortOrder,
  required int createdAt,
  required int lastUpdate,
  Value<bool> isSynced,
  Value<int> rowid,
});
typedef $$LocalCategoriesTableUpdateCompanionBuilder = LocalCategoriesCompanion
    Function({
  Value<String> id,
  Value<String> householdId,
  Value<String> name,
  Value<String> type,
  Value<String?> color,
  Value<String?> icon,
  Value<bool> isActive,
  Value<int> sortOrder,
  Value<int> createdAt,
  Value<int> lastUpdate,
  Value<bool> isSynced,
  Value<int> rowid,
});

class $$LocalCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));
}

class $$LocalCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));
}

class $$LocalCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LocalCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalCategoriesTable,
    LocalCategory,
    $$LocalCategoriesTableFilterComposer,
    $$LocalCategoriesTableOrderingComposer,
    $$LocalCategoriesTableAnnotationComposer,
    $$LocalCategoriesTableCreateCompanionBuilder,
    $$LocalCategoriesTableUpdateCompanionBuilder,
    (
      LocalCategory,
      BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>
    ),
    LocalCategory,
    PrefetchHooks Function()> {
  $$LocalCategoriesTableTableManager(
      _$AppDatabase db, $LocalCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> lastUpdate = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCategoriesCompanion(
            id: id,
            householdId: householdId,
            name: name,
            type: type,
            color: color,
            icon: icon,
            isActive: isActive,
            sortOrder: sortOrder,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String householdId,
            required String name,
            required String type,
            Value<String?> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required int createdAt,
            required int lastUpdate,
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCategoriesCompanion.insert(
            id: id,
            householdId: householdId,
            name: name,
            type: type,
            color: color,
            icon: icon,
            isActive: isActive,
            sortOrder: sortOrder,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalCategoriesTable,
    LocalCategory,
    $$LocalCategoriesTableFilterComposer,
    $$LocalCategoriesTableOrderingComposer,
    $$LocalCategoriesTableAnnotationComposer,
    $$LocalCategoriesTableCreateCompanionBuilder,
    $$LocalCategoriesTableUpdateCompanionBuilder,
    (
      LocalCategory,
      BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>
    ),
    LocalCategory,
    PrefetchHooks Function()>;
typedef $$LocalBankAccountsTableCreateCompanionBuilder
    = LocalBankAccountsCompanion Function({
  required String id,
  required String householdId,
  required String ownerType,
  Value<String?> ownerId,
  required String name,
  Value<String?> institution,
  Value<String?> institutionId,
  Value<String?> iban,
  required String accountType,
  Value<String> currency,
  required double initialBalance,
  required double currentBalance,
  Value<bool> isPrimary,
  Value<bool> isActive,
  Value<String?> color,
  Value<String?> icon,
  Value<int> sortOrder,
  required int createdAt,
  required int lastUpdate,
  Value<bool> isSynced,
  Value<int> rowid,
});
typedef $$LocalBankAccountsTableUpdateCompanionBuilder
    = LocalBankAccountsCompanion Function({
  Value<String> id,
  Value<String> householdId,
  Value<String> ownerType,
  Value<String?> ownerId,
  Value<String> name,
  Value<String?> institution,
  Value<String?> institutionId,
  Value<String?> iban,
  Value<String> accountType,
  Value<String> currency,
  Value<double> initialBalance,
  Value<double> currentBalance,
  Value<bool> isPrimary,
  Value<bool> isActive,
  Value<String?> color,
  Value<String?> icon,
  Value<int> sortOrder,
  Value<int> createdAt,
  Value<int> lastUpdate,
  Value<bool> isSynced,
  Value<int> rowid,
});

final class $$LocalBankAccountsTableReferences extends BaseReferences<
    _$AppDatabase, $LocalBankAccountsTable, LocalBankAccount> {
  $$LocalBankAccountsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocalCardsTable, List<LocalCard>>
      _localCardsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.localCards,
              aliasName: $_aliasNameGenerator(
                  db.localBankAccounts.id, db.localCards.accountId));

  $$LocalCardsTableProcessedTableManager get localCardsRefs {
    final manager = $$LocalCardsTableTableManager($_db, $_db.localCards)
        .filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localCardsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LocalAccountMembersTable,
      List<LocalAccountMember>> _localAccountMembersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.localAccountMembers,
          aliasName: $_aliasNameGenerator(
              db.localBankAccounts.id, db.localAccountMembers.accountId));

  $$LocalAccountMembersTableProcessedTableManager get localAccountMembersRefs {
    final manager = $$LocalAccountMembersTableTableManager(
            $_db, $_db.localAccountMembers)
        .filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_localAccountMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LocalBankAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalBankAccountsTable> {
  $$LocalBankAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerType => $composableBuilder(
      column: $table.ownerType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get institution => $composableBuilder(
      column: $table.institution, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get institutionId => $composableBuilder(
      column: $table.institutionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iban => $composableBuilder(
      column: $table.iban, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountType => $composableBuilder(
      column: $table.accountType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get initialBalance => $composableBuilder(
      column: $table.initialBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentBalance => $composableBuilder(
      column: $table.currentBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  Expression<bool> localCardsRefs(
      Expression<bool> Function($$LocalCardsTableFilterComposer f) f) {
    final $$LocalCardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.localCards,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalCardsTableFilterComposer(
              $db: $db,
              $table: $db.localCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> localAccountMembersRefs(
      Expression<bool> Function($$LocalAccountMembersTableFilterComposer f) f) {
    final $$LocalAccountMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.localAccountMembers,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalAccountMembersTableFilterComposer(
              $db: $db,
              $table: $db.localAccountMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocalBankAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalBankAccountsTable> {
  $$LocalBankAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerType => $composableBuilder(
      column: $table.ownerType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get institution => $composableBuilder(
      column: $table.institution, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get institutionId => $composableBuilder(
      column: $table.institutionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iban => $composableBuilder(
      column: $table.iban, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountType => $composableBuilder(
      column: $table.accountType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get initialBalance => $composableBuilder(
      column: $table.initialBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentBalance => $composableBuilder(
      column: $table.currentBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));
}

class $$LocalBankAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalBankAccountsTable> {
  $$LocalBankAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get institution => $composableBuilder(
      column: $table.institution, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
      column: $table.institutionId, builder: (column) => column);

  GeneratedColumn<String> get iban =>
      $composableBuilder(column: $table.iban, builder: (column) => column);

  GeneratedColumn<String> get accountType => $composableBuilder(
      column: $table.accountType, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get initialBalance => $composableBuilder(
      column: $table.initialBalance, builder: (column) => column);

  GeneratedColumn<double> get currentBalance => $composableBuilder(
      column: $table.currentBalance, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  Expression<T> localCardsRefs<T extends Object>(
      Expression<T> Function($$LocalCardsTableAnnotationComposer a) f) {
    final $$LocalCardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.localCards,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalCardsTableAnnotationComposer(
              $db: $db,
              $table: $db.localCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> localAccountMembersRefs<T extends Object>(
      Expression<T> Function($$LocalAccountMembersTableAnnotationComposer a)
          f) {
    final $$LocalAccountMembersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.localAccountMembers,
            getReferencedColumn: (t) => t.accountId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LocalAccountMembersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.localAccountMembers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$LocalBankAccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalBankAccountsTable,
    LocalBankAccount,
    $$LocalBankAccountsTableFilterComposer,
    $$LocalBankAccountsTableOrderingComposer,
    $$LocalBankAccountsTableAnnotationComposer,
    $$LocalBankAccountsTableCreateCompanionBuilder,
    $$LocalBankAccountsTableUpdateCompanionBuilder,
    (LocalBankAccount, $$LocalBankAccountsTableReferences),
    LocalBankAccount,
    PrefetchHooks Function(
        {bool localCardsRefs, bool localAccountMembersRefs})> {
  $$LocalBankAccountsTableTableManager(
      _$AppDatabase db, $LocalBankAccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBankAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalBankAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalBankAccountsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> ownerType = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> institution = const Value.absent(),
            Value<String?> institutionId = const Value.absent(),
            Value<String?> iban = const Value.absent(),
            Value<String> accountType = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<double> initialBalance = const Value.absent(),
            Value<double> currentBalance = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> lastUpdate = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalBankAccountsCompanion(
            id: id,
            householdId: householdId,
            ownerType: ownerType,
            ownerId: ownerId,
            name: name,
            institution: institution,
            institutionId: institutionId,
            iban: iban,
            accountType: accountType,
            currency: currency,
            initialBalance: initialBalance,
            currentBalance: currentBalance,
            isPrimary: isPrimary,
            isActive: isActive,
            color: color,
            icon: icon,
            sortOrder: sortOrder,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String householdId,
            required String ownerType,
            Value<String?> ownerId = const Value.absent(),
            required String name,
            Value<String?> institution = const Value.absent(),
            Value<String?> institutionId = const Value.absent(),
            Value<String?> iban = const Value.absent(),
            required String accountType,
            Value<String> currency = const Value.absent(),
            required double initialBalance,
            required double currentBalance,
            Value<bool> isPrimary = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required int createdAt,
            required int lastUpdate,
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalBankAccountsCompanion.insert(
            id: id,
            householdId: householdId,
            ownerType: ownerType,
            ownerId: ownerId,
            name: name,
            institution: institution,
            institutionId: institutionId,
            iban: iban,
            accountType: accountType,
            currency: currency,
            initialBalance: initialBalance,
            currentBalance: currentBalance,
            isPrimary: isPrimary,
            isActive: isActive,
            color: color,
            icon: icon,
            sortOrder: sortOrder,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalBankAccountsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {localCardsRefs = false, localAccountMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localCardsRefs) db.localCards,
                if (localAccountMembersRefs) db.localAccountMembers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localCardsRefs)
                    await $_getPrefetchedData<LocalBankAccount,
                            $LocalBankAccountsTable, LocalCard>(
                        currentTable: table,
                        referencedTable: $$LocalBankAccountsTableReferences
                            ._localCardsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalBankAccountsTableReferences(db, table, p0)
                                .localCardsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.id),
                        typedResults: items),
                  if (localAccountMembersRefs)
                    await $_getPrefetchedData<LocalBankAccount,
                            $LocalBankAccountsTable, LocalAccountMember>(
                        currentTable: table,
                        referencedTable: $$LocalBankAccountsTableReferences
                            ._localAccountMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalBankAccountsTableReferences(db, table, p0)
                                .localAccountMembersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LocalBankAccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalBankAccountsTable,
    LocalBankAccount,
    $$LocalBankAccountsTableFilterComposer,
    $$LocalBankAccountsTableOrderingComposer,
    $$LocalBankAccountsTableAnnotationComposer,
    $$LocalBankAccountsTableCreateCompanionBuilder,
    $$LocalBankAccountsTableUpdateCompanionBuilder,
    (LocalBankAccount, $$LocalBankAccountsTableReferences),
    LocalBankAccount,
    PrefetchHooks Function(
        {bool localCardsRefs, bool localAccountMembersRefs})>;
typedef $$LocalGoalsTableCreateCompanionBuilder = LocalGoalsCompanion Function({
  required String id,
  required String householdId,
  required String scope,
  Value<String?> ownerId,
  Value<String?> bankAccountId,
  required String name,
  required String goalType,
  Value<double?> targetAmount,
  Value<double?> monthlyTarget,
  Value<double> currentAmount,
  Value<String> currency,
  required int startDate,
  Value<int?> endDate,
  Value<bool> isActive,
  Value<String?> color,
  Value<String?> icon,
  required int createdAt,
  required int lastUpdate,
  Value<bool> isSynced,
  Value<int> rowid,
});
typedef $$LocalGoalsTableUpdateCompanionBuilder = LocalGoalsCompanion Function({
  Value<String> id,
  Value<String> householdId,
  Value<String> scope,
  Value<String?> ownerId,
  Value<String?> bankAccountId,
  Value<String> name,
  Value<String> goalType,
  Value<double?> targetAmount,
  Value<double?> monthlyTarget,
  Value<double> currentAmount,
  Value<String> currency,
  Value<int> startDate,
  Value<int?> endDate,
  Value<bool> isActive,
  Value<String?> color,
  Value<String?> icon,
  Value<int> createdAt,
  Value<int> lastUpdate,
  Value<bool> isSynced,
  Value<int> rowid,
});

class $$LocalGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalGoalsTable> {
  $$LocalGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankAccountId => $composableBuilder(
      column: $table.bankAccountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goalType => $composableBuilder(
      column: $table.goalType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monthlyTarget => $composableBuilder(
      column: $table.monthlyTarget, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));
}

class $$LocalGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalGoalsTable> {
  $$LocalGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankAccountId => $composableBuilder(
      column: $table.bankAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goalType => $composableBuilder(
      column: $table.goalType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monthlyTarget => $composableBuilder(
      column: $table.monthlyTarget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));
}

class $$LocalGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalGoalsTable> {
  $$LocalGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get bankAccountId => $composableBuilder(
      column: $table.bankAccountId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<double> get monthlyTarget => $composableBuilder(
      column: $table.monthlyTarget, builder: (column) => column);

  GeneratedColumn<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LocalGoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalGoalsTable,
    LocalGoal,
    $$LocalGoalsTableFilterComposer,
    $$LocalGoalsTableOrderingComposer,
    $$LocalGoalsTableAnnotationComposer,
    $$LocalGoalsTableCreateCompanionBuilder,
    $$LocalGoalsTableUpdateCompanionBuilder,
    (LocalGoal, BaseReferences<_$AppDatabase, $LocalGoalsTable, LocalGoal>),
    LocalGoal,
    PrefetchHooks Function()> {
  $$LocalGoalsTableTableManager(_$AppDatabase db, $LocalGoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> scope = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<String?> bankAccountId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> goalType = const Value.absent(),
            Value<double?> targetAmount = const Value.absent(),
            Value<double?> monthlyTarget = const Value.absent(),
            Value<double> currentAmount = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int> startDate = const Value.absent(),
            Value<int?> endDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> lastUpdate = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalGoalsCompanion(
            id: id,
            householdId: householdId,
            scope: scope,
            ownerId: ownerId,
            bankAccountId: bankAccountId,
            name: name,
            goalType: goalType,
            targetAmount: targetAmount,
            monthlyTarget: monthlyTarget,
            currentAmount: currentAmount,
            currency: currency,
            startDate: startDate,
            endDate: endDate,
            isActive: isActive,
            color: color,
            icon: icon,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String householdId,
            required String scope,
            Value<String?> ownerId = const Value.absent(),
            Value<String?> bankAccountId = const Value.absent(),
            required String name,
            required String goalType,
            Value<double?> targetAmount = const Value.absent(),
            Value<double?> monthlyTarget = const Value.absent(),
            Value<double> currentAmount = const Value.absent(),
            Value<String> currency = const Value.absent(),
            required int startDate,
            Value<int?> endDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            required int createdAt,
            required int lastUpdate,
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalGoalsCompanion.insert(
            id: id,
            householdId: householdId,
            scope: scope,
            ownerId: ownerId,
            bankAccountId: bankAccountId,
            name: name,
            goalType: goalType,
            targetAmount: targetAmount,
            monthlyTarget: monthlyTarget,
            currentAmount: currentAmount,
            currency: currency,
            startDate: startDate,
            endDate: endDate,
            isActive: isActive,
            color: color,
            icon: icon,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalGoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalGoalsTable,
    LocalGoal,
    $$LocalGoalsTableFilterComposer,
    $$LocalGoalsTableOrderingComposer,
    $$LocalGoalsTableAnnotationComposer,
    $$LocalGoalsTableCreateCompanionBuilder,
    $$LocalGoalsTableUpdateCompanionBuilder,
    (LocalGoal, BaseReferences<_$AppDatabase, $LocalGoalsTable, LocalGoal>),
    LocalGoal,
    PrefetchHooks Function()>;
typedef $$LocalNotificationsTableCreateCompanionBuilder
    = LocalNotificationsCompanion Function({
  required String id,
  required String userId,
  required String householdId,
  required String title,
  required String body,
  required String type,
  Value<String?> payload,
  Value<bool> isRead,
  required int createdAt,
  Value<int> rowid,
});
typedef $$LocalNotificationsTableUpdateCompanionBuilder
    = LocalNotificationsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> householdId,
  Value<String> title,
  Value<String> body,
  Value<String> type,
  Value<String?> payload,
  Value<bool> isRead,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$LocalNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalNotificationsTable> {
  $$LocalNotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LocalNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalNotificationsTable> {
  $$LocalNotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalNotificationsTable> {
  $$LocalNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalNotificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalNotificationsTable,
    LocalNotification,
    $$LocalNotificationsTableFilterComposer,
    $$LocalNotificationsTableOrderingComposer,
    $$LocalNotificationsTableAnnotationComposer,
    $$LocalNotificationsTableCreateCompanionBuilder,
    $$LocalNotificationsTableUpdateCompanionBuilder,
    (
      LocalNotification,
      BaseReferences<_$AppDatabase, $LocalNotificationsTable, LocalNotification>
    ),
    LocalNotification,
    PrefetchHooks Function()> {
  $$LocalNotificationsTableTableManager(
      _$AppDatabase db, $LocalNotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalNotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalNotificationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalNotificationsCompanion(
            id: id,
            userId: userId,
            householdId: householdId,
            title: title,
            body: body,
            type: type,
            payload: payload,
            isRead: isRead,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String householdId,
            required String title,
            required String body,
            required String type,
            Value<String?> payload = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalNotificationsCompanion.insert(
            id: id,
            userId: userId,
            householdId: householdId,
            title: title,
            body: body,
            type: type,
            payload: payload,
            isRead: isRead,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalNotificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalNotificationsTable,
    LocalNotification,
    $$LocalNotificationsTableFilterComposer,
    $$LocalNotificationsTableOrderingComposer,
    $$LocalNotificationsTableAnnotationComposer,
    $$LocalNotificationsTableCreateCompanionBuilder,
    $$LocalNotificationsTableUpdateCompanionBuilder,
    (
      LocalNotification,
      BaseReferences<_$AppDatabase, $LocalNotificationsTable, LocalNotification>
    ),
    LocalNotification,
    PrefetchHooks Function()>;
typedef $$LocalFinancialInstitutionsTableCreateCompanionBuilder
    = LocalFinancialInstitutionsCompanion Function({
  required String id,
  required String name,
  required String slug,
  Value<String> country,
  required String brandColor,
  Value<String?> logoAsset,
  Value<String> institutionType,
  Value<bool> isCustom,
  required int createdAt,
  required int lastUpdate,
  Value<bool> isSynced,
  Value<int> rowid,
});
typedef $$LocalFinancialInstitutionsTableUpdateCompanionBuilder
    = LocalFinancialInstitutionsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> slug,
  Value<String> country,
  Value<String> brandColor,
  Value<String?> logoAsset,
  Value<String> institutionType,
  Value<bool> isCustom,
  Value<int> createdAt,
  Value<int> lastUpdate,
  Value<bool> isSynced,
  Value<int> rowid,
});

class $$LocalFinancialInstitutionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalFinancialInstitutionsTable> {
  $$LocalFinancialInstitutionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slug => $composableBuilder(
      column: $table.slug, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get country => $composableBuilder(
      column: $table.country, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brandColor => $composableBuilder(
      column: $table.brandColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoAsset => $composableBuilder(
      column: $table.logoAsset, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get institutionType => $composableBuilder(
      column: $table.institutionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));
}

class $$LocalFinancialInstitutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalFinancialInstitutionsTable> {
  $$LocalFinancialInstitutionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slug => $composableBuilder(
      column: $table.slug, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get country => $composableBuilder(
      column: $table.country, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brandColor => $composableBuilder(
      column: $table.brandColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoAsset => $composableBuilder(
      column: $table.logoAsset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get institutionType => $composableBuilder(
      column: $table.institutionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));
}

class $$LocalFinancialInstitutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalFinancialInstitutionsTable> {
  $$LocalFinancialInstitutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get brandColor => $composableBuilder(
      column: $table.brandColor, builder: (column) => column);

  GeneratedColumn<String> get logoAsset =>
      $composableBuilder(column: $table.logoAsset, builder: (column) => column);

  GeneratedColumn<String> get institutionType => $composableBuilder(
      column: $table.institutionType, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LocalFinancialInstitutionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalFinancialInstitutionsTable,
    LocalFinancialInstitution,
    $$LocalFinancialInstitutionsTableFilterComposer,
    $$LocalFinancialInstitutionsTableOrderingComposer,
    $$LocalFinancialInstitutionsTableAnnotationComposer,
    $$LocalFinancialInstitutionsTableCreateCompanionBuilder,
    $$LocalFinancialInstitutionsTableUpdateCompanionBuilder,
    (
      LocalFinancialInstitution,
      BaseReferences<_$AppDatabase, $LocalFinancialInstitutionsTable,
          LocalFinancialInstitution>
    ),
    LocalFinancialInstitution,
    PrefetchHooks Function()> {
  $$LocalFinancialInstitutionsTableTableManager(
      _$AppDatabase db, $LocalFinancialInstitutionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFinancialInstitutionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFinancialInstitutionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFinancialInstitutionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> slug = const Value.absent(),
            Value<String> country = const Value.absent(),
            Value<String> brandColor = const Value.absent(),
            Value<String?> logoAsset = const Value.absent(),
            Value<String> institutionType = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> lastUpdate = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFinancialInstitutionsCompanion(
            id: id,
            name: name,
            slug: slug,
            country: country,
            brandColor: brandColor,
            logoAsset: logoAsset,
            institutionType: institutionType,
            isCustom: isCustom,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String slug,
            Value<String> country = const Value.absent(),
            required String brandColor,
            Value<String?> logoAsset = const Value.absent(),
            Value<String> institutionType = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            required int createdAt,
            required int lastUpdate,
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFinancialInstitutionsCompanion.insert(
            id: id,
            name: name,
            slug: slug,
            country: country,
            brandColor: brandColor,
            logoAsset: logoAsset,
            institutionType: institutionType,
            isCustom: isCustom,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalFinancialInstitutionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalFinancialInstitutionsTable,
        LocalFinancialInstitution,
        $$LocalFinancialInstitutionsTableFilterComposer,
        $$LocalFinancialInstitutionsTableOrderingComposer,
        $$LocalFinancialInstitutionsTableAnnotationComposer,
        $$LocalFinancialInstitutionsTableCreateCompanionBuilder,
        $$LocalFinancialInstitutionsTableUpdateCompanionBuilder,
        (
          LocalFinancialInstitution,
          BaseReferences<_$AppDatabase, $LocalFinancialInstitutionsTable,
              LocalFinancialInstitution>
        ),
        LocalFinancialInstitution,
        PrefetchHooks Function()>;
typedef $$LocalCardsTableCreateCompanionBuilder = LocalCardsCompanion Function({
  required String id,
  required String accountId,
  required String network,
  required String last4,
  required int expiryMonth,
  required int expiryYear,
  required String cardholderName,
  Value<bool> isVirtual,
  Value<bool> isPrimary,
  Value<bool> isActive,
  Value<String?> ownerProfileId,
  Value<String?> color,
  Value<int> sortOrder,
  required int createdAt,
  required int lastUpdate,
  Value<bool> isSynced,
  Value<int> rowid,
});
typedef $$LocalCardsTableUpdateCompanionBuilder = LocalCardsCompanion Function({
  Value<String> id,
  Value<String> accountId,
  Value<String> network,
  Value<String> last4,
  Value<int> expiryMonth,
  Value<int> expiryYear,
  Value<String> cardholderName,
  Value<bool> isVirtual,
  Value<bool> isPrimary,
  Value<bool> isActive,
  Value<String?> ownerProfileId,
  Value<String?> color,
  Value<int> sortOrder,
  Value<int> createdAt,
  Value<int> lastUpdate,
  Value<bool> isSynced,
  Value<int> rowid,
});

final class $$LocalCardsTableReferences
    extends BaseReferences<_$AppDatabase, $LocalCardsTable, LocalCard> {
  $$LocalCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalBankAccountsTable _accountIdTable(_$AppDatabase db) =>
      db.localBankAccounts.createAlias($_aliasNameGenerator(
          db.localCards.accountId, db.localBankAccounts.id));

  $$LocalBankAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager =
        $$LocalBankAccountsTableTableManager($_db, $_db.localBankAccounts)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LocalCardsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCardsTable> {
  $$LocalCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get network => $composableBuilder(
      column: $table.network, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get last4 => $composableBuilder(
      column: $table.last4, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expiryMonth => $composableBuilder(
      column: $table.expiryMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expiryYear => $composableBuilder(
      column: $table.expiryYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cardholderName => $composableBuilder(
      column: $table.cardholderName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVirtual => $composableBuilder(
      column: $table.isVirtual, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerProfileId => $composableBuilder(
      column: $table.ownerProfileId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  $$LocalBankAccountsTableFilterComposer get accountId {
    final $$LocalBankAccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.localBankAccounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalBankAccountsTableFilterComposer(
              $db: $db,
              $table: $db.localBankAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCardsTable> {
  $$LocalCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get network => $composableBuilder(
      column: $table.network, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get last4 => $composableBuilder(
      column: $table.last4, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expiryMonth => $composableBuilder(
      column: $table.expiryMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expiryYear => $composableBuilder(
      column: $table.expiryYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cardholderName => $composableBuilder(
      column: $table.cardholderName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVirtual => $composableBuilder(
      column: $table.isVirtual, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerProfileId => $composableBuilder(
      column: $table.ownerProfileId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  $$LocalBankAccountsTableOrderingComposer get accountId {
    final $$LocalBankAccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.localBankAccounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalBankAccountsTableOrderingComposer(
              $db: $db,
              $table: $db.localBankAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCardsTable> {
  $$LocalCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get network =>
      $composableBuilder(column: $table.network, builder: (column) => column);

  GeneratedColumn<String> get last4 =>
      $composableBuilder(column: $table.last4, builder: (column) => column);

  GeneratedColumn<int> get expiryMonth => $composableBuilder(
      column: $table.expiryMonth, builder: (column) => column);

  GeneratedColumn<int> get expiryYear => $composableBuilder(
      column: $table.expiryYear, builder: (column) => column);

  GeneratedColumn<String> get cardholderName => $composableBuilder(
      column: $table.cardholderName, builder: (column) => column);

  GeneratedColumn<bool> get isVirtual =>
      $composableBuilder(column: $table.isVirtual, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get ownerProfileId => $composableBuilder(
      column: $table.ownerProfileId, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$LocalBankAccountsTableAnnotationComposer get accountId {
    final $$LocalBankAccountsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.accountId,
            referencedTable: $db.localBankAccounts,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LocalBankAccountsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.localBankAccounts,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$LocalCardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalCardsTable,
    LocalCard,
    $$LocalCardsTableFilterComposer,
    $$LocalCardsTableOrderingComposer,
    $$LocalCardsTableAnnotationComposer,
    $$LocalCardsTableCreateCompanionBuilder,
    $$LocalCardsTableUpdateCompanionBuilder,
    (LocalCard, $$LocalCardsTableReferences),
    LocalCard,
    PrefetchHooks Function({bool accountId})> {
  $$LocalCardsTableTableManager(_$AppDatabase db, $LocalCardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<String> network = const Value.absent(),
            Value<String> last4 = const Value.absent(),
            Value<int> expiryMonth = const Value.absent(),
            Value<int> expiryYear = const Value.absent(),
            Value<String> cardholderName = const Value.absent(),
            Value<bool> isVirtual = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> ownerProfileId = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> lastUpdate = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCardsCompanion(
            id: id,
            accountId: accountId,
            network: network,
            last4: last4,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
            cardholderName: cardholderName,
            isVirtual: isVirtual,
            isPrimary: isPrimary,
            isActive: isActive,
            ownerProfileId: ownerProfileId,
            color: color,
            sortOrder: sortOrder,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String accountId,
            required String network,
            required String last4,
            required int expiryMonth,
            required int expiryYear,
            required String cardholderName,
            Value<bool> isVirtual = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> ownerProfileId = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required int createdAt,
            required int lastUpdate,
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCardsCompanion.insert(
            id: id,
            accountId: accountId,
            network: network,
            last4: last4,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
            cardholderName: cardholderName,
            isVirtual: isVirtual,
            isPrimary: isPrimary,
            isActive: isActive,
            ownerProfileId: ownerProfileId,
            color: color,
            sortOrder: sortOrder,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalCardsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable:
                        $$LocalCardsTableReferences._accountIdTable(db),
                    referencedColumn:
                        $$LocalCardsTableReferences._accountIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LocalCardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalCardsTable,
    LocalCard,
    $$LocalCardsTableFilterComposer,
    $$LocalCardsTableOrderingComposer,
    $$LocalCardsTableAnnotationComposer,
    $$LocalCardsTableCreateCompanionBuilder,
    $$LocalCardsTableUpdateCompanionBuilder,
    (LocalCard, $$LocalCardsTableReferences),
    LocalCard,
    PrefetchHooks Function({bool accountId})>;
typedef $$LocalAccountMembersTableCreateCompanionBuilder
    = LocalAccountMembersCompanion Function({
  required String id,
  required String accountId,
  required String userId,
  Value<String> role,
  required int joinedAt,
  Value<int> rowid,
});
typedef $$LocalAccountMembersTableUpdateCompanionBuilder
    = LocalAccountMembersCompanion Function({
  Value<String> id,
  Value<String> accountId,
  Value<String> userId,
  Value<String> role,
  Value<int> joinedAt,
  Value<int> rowid,
});

final class $$LocalAccountMembersTableReferences extends BaseReferences<
    _$AppDatabase, $LocalAccountMembersTable, LocalAccountMember> {
  $$LocalAccountMembersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $LocalBankAccountsTable _accountIdTable(_$AppDatabase db) =>
      db.localBankAccounts.createAlias($_aliasNameGenerator(
          db.localAccountMembers.accountId, db.localBankAccounts.id));

  $$LocalBankAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager =
        $$LocalBankAccountsTableTableManager($_db, $_db.localBankAccounts)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LocalAccountMembersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAccountMembersTable> {
  $$LocalAccountMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnFilters(column));

  $$LocalBankAccountsTableFilterComposer get accountId {
    final $$LocalBankAccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.localBankAccounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalBankAccountsTableFilterComposer(
              $db: $db,
              $table: $db.localBankAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalAccountMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAccountMembersTable> {
  $$LocalAccountMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnOrderings(column));

  $$LocalBankAccountsTableOrderingComposer get accountId {
    final $$LocalBankAccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.localBankAccounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalBankAccountsTableOrderingComposer(
              $db: $db,
              $table: $db.localBankAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalAccountMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAccountMembersTable> {
  $$LocalAccountMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  $$LocalBankAccountsTableAnnotationComposer get accountId {
    final $$LocalBankAccountsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.accountId,
            referencedTable: $db.localBankAccounts,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LocalBankAccountsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.localBankAccounts,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$LocalAccountMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalAccountMembersTable,
    LocalAccountMember,
    $$LocalAccountMembersTableFilterComposer,
    $$LocalAccountMembersTableOrderingComposer,
    $$LocalAccountMembersTableAnnotationComposer,
    $$LocalAccountMembersTableCreateCompanionBuilder,
    $$LocalAccountMembersTableUpdateCompanionBuilder,
    (LocalAccountMember, $$LocalAccountMembersTableReferences),
    LocalAccountMember,
    PrefetchHooks Function({bool accountId})> {
  $$LocalAccountMembersTableTableManager(
      _$AppDatabase db, $LocalAccountMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAccountMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAccountMembersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAccountMembersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<int> joinedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalAccountMembersCompanion(
            id: id,
            accountId: accountId,
            userId: userId,
            role: role,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String accountId,
            required String userId,
            Value<String> role = const Value.absent(),
            required int joinedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalAccountMembersCompanion.insert(
            id: id,
            accountId: accountId,
            userId: userId,
            role: role,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalAccountMembersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable: $$LocalAccountMembersTableReferences
                        ._accountIdTable(db),
                    referencedColumn: $$LocalAccountMembersTableReferences
                        ._accountIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LocalAccountMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalAccountMembersTable,
    LocalAccountMember,
    $$LocalAccountMembersTableFilterComposer,
    $$LocalAccountMembersTableOrderingComposer,
    $$LocalAccountMembersTableAnnotationComposer,
    $$LocalAccountMembersTableCreateCompanionBuilder,
    $$LocalAccountMembersTableUpdateCompanionBuilder,
    (LocalAccountMember, $$LocalAccountMembersTableReferences),
    LocalAccountMember,
    PrefetchHooks Function({bool accountId})>;
typedef $$LocalShoppingSessionsTableCreateCompanionBuilder
    = LocalShoppingSessionsCompanion Function({
  required String id,
  required String householdId,
  required String ownerId,
  required String name,
  required String scope,
  required String status,
  Value<String?> templateId,
  Value<String?> bankAccountId,
  Value<String?> transactionSourceId,
  Value<String?> transactionId,
  required int startedAt,
  Value<int?> endedAt,
  Value<int?> paidAt,
  required int createdAt,
  required int lastUpdate,
  Value<bool> isSynced,
  Value<bool> isDirty,
  Value<int> rowid,
});
typedef $$LocalShoppingSessionsTableUpdateCompanionBuilder
    = LocalShoppingSessionsCompanion Function({
  Value<String> id,
  Value<String> householdId,
  Value<String> ownerId,
  Value<String> name,
  Value<String> scope,
  Value<String> status,
  Value<String?> templateId,
  Value<String?> bankAccountId,
  Value<String?> transactionSourceId,
  Value<String?> transactionId,
  Value<int> startedAt,
  Value<int?> endedAt,
  Value<int?> paidAt,
  Value<int> createdAt,
  Value<int> lastUpdate,
  Value<bool> isSynced,
  Value<bool> isDirty,
  Value<int> rowid,
});

final class $$LocalShoppingSessionsTableReferences extends BaseReferences<
    _$AppDatabase, $LocalShoppingSessionsTable, LocalShoppingSession> {
  $$LocalShoppingSessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocalShoppingSessionItemsTable,
      List<LocalShoppingSessionItem>> _localShoppingSessionItemsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.localShoppingSessionItems,
          aliasName: $_aliasNameGenerator(db.localShoppingSessions.id,
              db.localShoppingSessionItems.sessionId));

  $$LocalShoppingSessionItemsTableProcessedTableManager
      get localShoppingSessionItemsRefs {
    final manager = $$LocalShoppingSessionItemsTableTableManager(
            $_db, $_db.localShoppingSessionItems)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult
        .readTableOrNull(_localShoppingSessionItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LocalShoppingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalShoppingSessionsTable> {
  $$LocalShoppingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankAccountId => $composableBuilder(
      column: $table.bankAccountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionSourceId => $composableBuilder(
      column: $table.transactionSourceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paidAt => $composableBuilder(
      column: $table.paidAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  Expression<bool> localShoppingSessionItemsRefs(
      Expression<bool> Function(
              $$LocalShoppingSessionItemsTableFilterComposer f)
          f) {
    final $$LocalShoppingSessionItemsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.localShoppingSessionItems,
            getReferencedColumn: (t) => t.sessionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LocalShoppingSessionItemsTableFilterComposer(
                  $db: $db,
                  $table: $db.localShoppingSessionItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$LocalShoppingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalShoppingSessionsTable> {
  $$LocalShoppingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankAccountId => $composableBuilder(
      column: $table.bankAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionSourceId => $composableBuilder(
      column: $table.transactionSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paidAt => $composableBuilder(
      column: $table.paidAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));
}

class $$LocalShoppingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalShoppingSessionsTable> {
  $$LocalShoppingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => column);

  GeneratedColumn<String> get bankAccountId => $composableBuilder(
      column: $table.bankAccountId, builder: (column) => column);

  GeneratedColumn<String> get transactionSourceId => $composableBuilder(
      column: $table.transactionSourceId, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  Expression<T> localShoppingSessionItemsRefs<T extends Object>(
      Expression<T> Function(
              $$LocalShoppingSessionItemsTableAnnotationComposer a)
          f) {
    final $$LocalShoppingSessionItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.localShoppingSessionItems,
            getReferencedColumn: (t) => t.sessionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LocalShoppingSessionItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.localShoppingSessionItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$LocalShoppingSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalShoppingSessionsTable,
    LocalShoppingSession,
    $$LocalShoppingSessionsTableFilterComposer,
    $$LocalShoppingSessionsTableOrderingComposer,
    $$LocalShoppingSessionsTableAnnotationComposer,
    $$LocalShoppingSessionsTableCreateCompanionBuilder,
    $$LocalShoppingSessionsTableUpdateCompanionBuilder,
    (LocalShoppingSession, $$LocalShoppingSessionsTableReferences),
    LocalShoppingSession,
    PrefetchHooks Function({bool localShoppingSessionItemsRefs})> {
  $$LocalShoppingSessionsTableTableManager(
      _$AppDatabase db, $LocalShoppingSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalShoppingSessionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalShoppingSessionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalShoppingSessionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> scope = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> templateId = const Value.absent(),
            Value<String?> bankAccountId = const Value.absent(),
            Value<String?> transactionSourceId = const Value.absent(),
            Value<String?> transactionId = const Value.absent(),
            Value<int> startedAt = const Value.absent(),
            Value<int?> endedAt = const Value.absent(),
            Value<int?> paidAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> lastUpdate = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalShoppingSessionsCompanion(
            id: id,
            householdId: householdId,
            ownerId: ownerId,
            name: name,
            scope: scope,
            status: status,
            templateId: templateId,
            bankAccountId: bankAccountId,
            transactionSourceId: transactionSourceId,
            transactionId: transactionId,
            startedAt: startedAt,
            endedAt: endedAt,
            paidAt: paidAt,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            isDirty: isDirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String householdId,
            required String ownerId,
            required String name,
            required String scope,
            required String status,
            Value<String?> templateId = const Value.absent(),
            Value<String?> bankAccountId = const Value.absent(),
            Value<String?> transactionSourceId = const Value.absent(),
            Value<String?> transactionId = const Value.absent(),
            required int startedAt,
            Value<int?> endedAt = const Value.absent(),
            Value<int?> paidAt = const Value.absent(),
            required int createdAt,
            required int lastUpdate,
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalShoppingSessionsCompanion.insert(
            id: id,
            householdId: householdId,
            ownerId: ownerId,
            name: name,
            scope: scope,
            status: status,
            templateId: templateId,
            bankAccountId: bankAccountId,
            transactionSourceId: transactionSourceId,
            transactionId: transactionId,
            startedAt: startedAt,
            endedAt: endedAt,
            paidAt: paidAt,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            isSynced: isSynced,
            isDirty: isDirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalShoppingSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({localShoppingSessionItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localShoppingSessionItemsRefs) db.localShoppingSessionItems
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localShoppingSessionItemsRefs)
                    await $_getPrefetchedData<
                            LocalShoppingSession,
                            $LocalShoppingSessionsTable,
                            LocalShoppingSessionItem>(
                        currentTable: table,
                        referencedTable: $$LocalShoppingSessionsTableReferences
                            ._localShoppingSessionItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalShoppingSessionsTableReferences(
                                    db, table, p0)
                                .localShoppingSessionItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LocalShoppingSessionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalShoppingSessionsTable,
        LocalShoppingSession,
        $$LocalShoppingSessionsTableFilterComposer,
        $$LocalShoppingSessionsTableOrderingComposer,
        $$LocalShoppingSessionsTableAnnotationComposer,
        $$LocalShoppingSessionsTableCreateCompanionBuilder,
        $$LocalShoppingSessionsTableUpdateCompanionBuilder,
        (LocalShoppingSession, $$LocalShoppingSessionsTableReferences),
        LocalShoppingSession,
        PrefetchHooks Function({bool localShoppingSessionItemsRefs})>;
typedef $$LocalShoppingSessionItemsTableCreateCompanionBuilder
    = LocalShoppingSessionItemsCompanion Function({
  required String id,
  required String sessionId,
  required String name,
  Value<int> qty,
  Value<int> sortOrder,
  Value<bool> isChecked,
  Value<int?> checkedAt,
  required int createdAt,
  required int lastUpdate,
  Value<int> rowid,
});
typedef $$LocalShoppingSessionItemsTableUpdateCompanionBuilder
    = LocalShoppingSessionItemsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> name,
  Value<int> qty,
  Value<int> sortOrder,
  Value<bool> isChecked,
  Value<int?> checkedAt,
  Value<int> createdAt,
  Value<int> lastUpdate,
  Value<int> rowid,
});

final class $$LocalShoppingSessionItemsTableReferences extends BaseReferences<
    _$AppDatabase, $LocalShoppingSessionItemsTable, LocalShoppingSessionItem> {
  $$LocalShoppingSessionItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $LocalShoppingSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.localShoppingSessions.createAlias($_aliasNameGenerator(
          db.localShoppingSessionItems.sessionId, db.localShoppingSessions.id));

  $$LocalShoppingSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$LocalShoppingSessionsTableTableManager(
            $_db, $_db.localShoppingSessions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LocalShoppingSessionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalShoppingSessionItemsTable> {
  $$LocalShoppingSessionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isChecked => $composableBuilder(
      column: $table.isChecked, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get checkedAt => $composableBuilder(
      column: $table.checkedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnFilters(column));

  $$LocalShoppingSessionsTableFilterComposer get sessionId {
    final $$LocalShoppingSessionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sessionId,
            referencedTable: $db.localShoppingSessions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LocalShoppingSessionsTableFilterComposer(
                  $db: $db,
                  $table: $db.localShoppingSessions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$LocalShoppingSessionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalShoppingSessionItemsTable> {
  $$LocalShoppingSessionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isChecked => $composableBuilder(
      column: $table.isChecked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get checkedAt => $composableBuilder(
      column: $table.checkedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnOrderings(column));

  $$LocalShoppingSessionsTableOrderingComposer get sessionId {
    final $$LocalShoppingSessionsTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sessionId,
            referencedTable: $db.localShoppingSessions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LocalShoppingSessionsTableOrderingComposer(
                  $db: $db,
                  $table: $db.localShoppingSessions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$LocalShoppingSessionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalShoppingSessionItemsTable> {
  $$LocalShoppingSessionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isChecked =>
      $composableBuilder(column: $table.isChecked, builder: (column) => column);

  GeneratedColumn<int> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => column);

  $$LocalShoppingSessionsTableAnnotationComposer get sessionId {
    final $$LocalShoppingSessionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sessionId,
            referencedTable: $db.localShoppingSessions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LocalShoppingSessionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.localShoppingSessions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$LocalShoppingSessionItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalShoppingSessionItemsTable,
    LocalShoppingSessionItem,
    $$LocalShoppingSessionItemsTableFilterComposer,
    $$LocalShoppingSessionItemsTableOrderingComposer,
    $$LocalShoppingSessionItemsTableAnnotationComposer,
    $$LocalShoppingSessionItemsTableCreateCompanionBuilder,
    $$LocalShoppingSessionItemsTableUpdateCompanionBuilder,
    (LocalShoppingSessionItem, $$LocalShoppingSessionItemsTableReferences),
    LocalShoppingSessionItem,
    PrefetchHooks Function({bool sessionId})> {
  $$LocalShoppingSessionItemsTableTableManager(
      _$AppDatabase db, $LocalShoppingSessionItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalShoppingSessionItemsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalShoppingSessionItemsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalShoppingSessionItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> qty = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isChecked = const Value.absent(),
            Value<int?> checkedAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> lastUpdate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalShoppingSessionItemsCompanion(
            id: id,
            sessionId: sessionId,
            name: name,
            qty: qty,
            sortOrder: sortOrder,
            isChecked: isChecked,
            checkedAt: checkedAt,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String name,
            Value<int> qty = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isChecked = const Value.absent(),
            Value<int?> checkedAt = const Value.absent(),
            required int createdAt,
            required int lastUpdate,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalShoppingSessionItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            name: name,
            qty: qty,
            sortOrder: sortOrder,
            isChecked: isChecked,
            checkedAt: checkedAt,
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalShoppingSessionItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable: $$LocalShoppingSessionItemsTableReferences
                        ._sessionIdTable(db),
                    referencedColumn: $$LocalShoppingSessionItemsTableReferences
                        ._sessionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LocalShoppingSessionItemsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalShoppingSessionItemsTable,
        LocalShoppingSessionItem,
        $$LocalShoppingSessionItemsTableFilterComposer,
        $$LocalShoppingSessionItemsTableOrderingComposer,
        $$LocalShoppingSessionItemsTableAnnotationComposer,
        $$LocalShoppingSessionItemsTableCreateCompanionBuilder,
        $$LocalShoppingSessionItemsTableUpdateCompanionBuilder,
        (LocalShoppingSessionItem, $$LocalShoppingSessionItemsTableReferences),
        LocalShoppingSessionItem,
        PrefetchHooks Function({bool sessionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalTransactionsTableTableManager get localTransactions =>
      $$LocalTransactionsTableTableManager(_db, _db.localTransactions);
  $$LocalCategoriesTableTableManager get localCategories =>
      $$LocalCategoriesTableTableManager(_db, _db.localCategories);
  $$LocalBankAccountsTableTableManager get localBankAccounts =>
      $$LocalBankAccountsTableTableManager(_db, _db.localBankAccounts);
  $$LocalGoalsTableTableManager get localGoals =>
      $$LocalGoalsTableTableManager(_db, _db.localGoals);
  $$LocalNotificationsTableTableManager get localNotifications =>
      $$LocalNotificationsTableTableManager(_db, _db.localNotifications);
  $$LocalFinancialInstitutionsTableTableManager
      get localFinancialInstitutions =>
          $$LocalFinancialInstitutionsTableTableManager(
              _db, _db.localFinancialInstitutions);
  $$LocalCardsTableTableManager get localCards =>
      $$LocalCardsTableTableManager(_db, _db.localCards);
  $$LocalAccountMembersTableTableManager get localAccountMembers =>
      $$LocalAccountMembersTableTableManager(_db, _db.localAccountMembers);
  $$LocalShoppingSessionsTableTableManager get localShoppingSessions =>
      $$LocalShoppingSessionsTableTableManager(_db, _db.localShoppingSessions);
  $$LocalShoppingSessionItemsTableTableManager get localShoppingSessionItems =>
      $$LocalShoppingSessionItemsTableTableManager(
          _db, _db.localShoppingSessionItems);
}
