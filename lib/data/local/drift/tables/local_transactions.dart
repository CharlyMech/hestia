import 'package:drift/drift.dart';

class LocalTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get userId => text()();
  TextColumn get categoryId => text()();
  TextColumn get moneySourceId => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'income' | 'expense'
  TextColumn get note => text().nullable()();
  IntColumn get date => integer()(); // unix seconds
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringRule => text().nullable()(); // json string
  IntColumn get createdAt => integer()();
  IntColumn get lastUpdate => integer()();

  // Sync tracking
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
