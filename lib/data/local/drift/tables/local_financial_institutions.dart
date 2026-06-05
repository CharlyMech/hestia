import 'package:drift/drift.dart';

class LocalFinancialInstitutions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get slug => text().unique()();
  TextColumn get country => text().withDefault(const Constant(''))();
  TextColumn get brandColor => text()();
  TextColumn get logoAsset => text().nullable()();
  TextColumn get institutionType => text().withDefault(const Constant('bank'))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get lastUpdate => integer()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
