import 'package:drift/drift.dart';

import 'tables/local_transactions.dart';
import 'tables/local_categories.dart';
import 'tables/local_bank_accounts.dart';
import 'tables/local_goals.dart';
import 'tables/local_notifications.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  LocalTransactions,
  LocalCategories,
  LocalBankAccounts,
  LocalGoals,
  LocalNotifications,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // v1 → v2: rename `local_money_sources` → `local_bank_accounts` and
          // `transactions.money_source_id` → `transactions.bank_account_id`.
          await m.deleteTable('local_money_sources');
          await m.deleteTable('local_transactions');
          await m.createAll();
        }
      },
    );
  }
}
