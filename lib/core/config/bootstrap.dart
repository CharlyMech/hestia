import 'package:flutter/cupertino.dart';
import 'package:hestia/app.dart';
import 'package:hestia/core/config/database.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/env.dart';
import 'package:hestia/core/config/flavor.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/presentation/pages/error/global_error_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  const flavorRaw = String.fromEnvironment('FLAVOR', defaultValue: 'mock');
  FlavorConfig.current = AppFlavor.fromString(flavorRaw);
  logger.i('Flavor: ${FlavorConfig.current.name}');

  await Env.load();

  if (FlavorConfig.isSupabase) {
    if (!Env.isConfigured) {
      runApp(const GlobalErrorApp(
        title: 'Configuration missing',
        message:
            'Supabase env not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY to your .env file and relaunch.',
      ));
      return;
    }
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      logger.e('Supabase init failed', error: e);
      runApp(GlobalErrorApp(
        title: 'Connection failed',
        message: 'Could not reach Supabase backend.\n\n$e',
      ));
      return;
    }
  }

  final database = await openDatabase();
  await AppDependencies.initialize(FlavorConfig.current);

  logger.i('App initialized');
  runApp(HestiaApp(database: database));
}
