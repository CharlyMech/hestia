import 'package:flutter/cupertino.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/config/database.dart';
import 'core/error/error_handler.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase only when env is configured. Placeholder values
  // would cause initialize() to hang on DNS resolution and freeze the
  // native splash forever.
  if (!Env.supabaseUrl.contains('YOUR_PROJECT') &&
      !Env.supabaseAnonKey.contains('YOUR_ANON_KEY')) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      logger.w('Supabase init failed or timed out: $e');
    }
  } else {
    logger.w('Supabase env not configured — running without backend');
  }

  // Open local database
  final database = await openDatabase();

  // Initialize dependency graph
  await AppDependencies.initialize();

  logger.i('App initialized');

  runApp(HestiaApp(database: database));
}
