import 'package:drift/drift.dart';

/// Local mirror of an active shopping session.
///
/// Personal sessions live ONLY here while active (zero Supabase writes until
/// finish). [isSynced] is false until the session has been pushed to Supabase;
/// [isDirty] flags a finished-but-not-yet-pushed session for retry-on-launch.
class LocalShoppingSessions extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text()();
  TextColumn get scope => text()(); // personal | shared
  TextColumn get status => text()(); // active | completed | cancelled
  TextColumn get templateId => text().nullable()();
  TextColumn get bankAccountId => text().nullable()();
  TextColumn get transactionSourceId => text().nullable()();
  TextColumn get transactionId => text().nullable()();
  IntColumn get startedAt => integer()();
  IntColumn get endedAt => integer().nullable()();
  IntColumn get paidAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get lastUpdate => integer()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
