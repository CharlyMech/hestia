import 'package:drift/drift.dart';

import 'tables/local_transactions.dart';
import 'tables/local_categories.dart';
import 'tables/local_money_sources.dart';
import 'tables/local_goals.dart';
import 'tables/local_notifications.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  LocalTransactions,
  LocalCategories,
  LocalMoneySources,
  LocalGoals,
  LocalNotifications,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
      },
    );
  }
}
