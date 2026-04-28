import 'package:flutter/cupertino.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/config/database.dart';
import 'core/error/error_handler.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // Open local database
  final database = await openDatabase();

  // Initialize dependency graph
  await AppDependencies.initialize();

  logger.i('App initialized');

  runApp(HestiaApp(database: database));
}
