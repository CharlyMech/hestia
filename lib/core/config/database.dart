import 'dart:io';

import 'package:drift/native.dart';
import 'package:hestia/data/local/drift/app_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the Drift database. Called once at app startup.
Future<AppDatabase> openDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'hestia.db'));

  final database = AppDatabase(
    NativeDatabase.createInBackground(file),
  );

  return database;
}
