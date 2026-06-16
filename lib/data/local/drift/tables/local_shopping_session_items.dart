import 'package:drift/drift.dart';

import 'local_shopping_sessions.dart';

/// Local mirror of a shopping session line item.
class LocalShoppingSessionItems extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(LocalShoppingSessions, #id)();
  TextColumn get name => text()();
  IntColumn get qty => integer().withDefault(const Constant(1))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  IntColumn get checkedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get lastUpdate => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
