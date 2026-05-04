import 'package:drift/drift.dart';

class LocalGoals extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get scope => text()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get bankAccountId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get goalType => text()();
  RealColumn get targetAmount => real().nullable()();
  RealColumn get monthlyTarget => real().nullable()();
  RealColumn get currentAmount => real().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  IntColumn get startDate => integer()();
  IntColumn get endDate => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get lastUpdate => integer()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
