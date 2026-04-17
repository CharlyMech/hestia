import 'package:drift/drift.dart';

class LocalMoneySources extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get ownerType => text()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get institution => text().nullable()();
  TextColumn get accountType => text()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  RealColumn get initialBalance => real()();
  RealColumn get currentBalance => real()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get lastUpdate => integer()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
