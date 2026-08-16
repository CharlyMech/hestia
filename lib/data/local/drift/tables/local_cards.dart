import 'package:drift/drift.dart';

import 'local_bank_accounts.dart';

class LocalCards extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text().references(LocalBankAccounts, #id)();
  TextColumn get network => text()();
  TextColumn get last4 => text()();
  IntColumn get expiryMonth => integer()();
  IntColumn get expiryYear => integer()();
  TextColumn get cardholderName => text()();
  BoolColumn get isVirtual => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get lastUpdate => integer()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
