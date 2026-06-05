import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'tables/local_transactions.dart';
import 'tables/local_categories.dart';
import 'tables/local_bank_accounts.dart';
import 'tables/local_goals.dart';
import 'tables/local_notifications.dart';
import 'tables/local_financial_institutions.dart';
import 'tables/local_cards.dart';
import 'tables/local_account_members.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  LocalTransactions,
  LocalCategories,
  LocalBankAccounts,
  LocalGoals,
  LocalNotifications,
  LocalFinancialInstitutions,
  LocalCards,
  LocalAccountMembers,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 4;

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
        if (from < 3) {
          // v2 → v3: add FinancialInstitution, Card, AccountMember tables
          // and new columns on existing tables. Using raw SQL pre-codegen;
          // generated accessors (localFinancialInstitutions etc.) are available
          // after `dart run build_runner build`.
          await customStatement('''
            CREATE TABLE IF NOT EXISTS local_financial_institutions (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              slug TEXT NOT NULL UNIQUE,
              country TEXT NOT NULL DEFAULT '',
              brand_color TEXT NOT NULL,
              logo_asset TEXT,
              institution_type TEXT NOT NULL DEFAULT 'bank',
              is_custom INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL,
              last_update INTEGER NOT NULL,
              is_synced INTEGER NOT NULL DEFAULT 1
            )
          ''');
          await customStatement('''
            CREATE TABLE IF NOT EXISTS local_cards (
              id TEXT NOT NULL PRIMARY KEY,
              account_id TEXT NOT NULL REFERENCES local_bank_accounts(id),
              network TEXT NOT NULL,
              last4 TEXT NOT NULL,
              expiry_month INTEGER NOT NULL,
              expiry_year INTEGER NOT NULL,
              cardholder_name TEXT NOT NULL,
              is_virtual INTEGER NOT NULL DEFAULT 0,
              is_active INTEGER NOT NULL DEFAULT 1,
              color TEXT,
              sort_order INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL,
              last_update INTEGER NOT NULL,
              is_synced INTEGER NOT NULL DEFAULT 1
            )
          ''');
          await customStatement('''
            CREATE TABLE IF NOT EXISTS local_account_members (
              id TEXT NOT NULL PRIMARY KEY,
              account_id TEXT NOT NULL REFERENCES local_bank_accounts(id),
              user_id TEXT NOT NULL,
              role TEXT NOT NULL DEFAULT 'owner',
              joined_at INTEGER NOT NULL
            )
          ''');
          await customStatement(
            'ALTER TABLE local_bank_accounts ADD COLUMN institution_id TEXT',
          );
          await customStatement(
            'ALTER TABLE local_transactions ADD COLUMN payment_card_id TEXT',
          );
        }
        if (from < 4) {
          // v3 → v4: add optional IBAN on bank accounts.
          await customStatement(
            'ALTER TABLE local_bank_accounts ADD COLUMN iban TEXT',
          );
        }
      },
      beforeOpen: (details) async {
        if (kDebugMode && details.wasCreated) {
          final migrator = createMigrator();
          await migrator.createAll();
        }
      },
    );
  }
}
