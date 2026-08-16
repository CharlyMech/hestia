import 'package:drift/drift.dart';

import 'local_bank_accounts.dart';

class LocalAccountMembers extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text().references(LocalBankAccounts, #id)();
  TextColumn get userId => text()();
  TextColumn get role => text().withDefault(const Constant('owner'))();
  IntColumn get joinedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
