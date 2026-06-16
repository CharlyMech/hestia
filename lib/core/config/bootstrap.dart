import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hestia/app.dart';
import 'package:hestia/core/config/crashlytics.dart';
import 'package:hestia/core/config/database.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/env.dart';
import 'package:hestia/core/config/firebase_options.dart';
import 'package:hestia/core/config/flavor.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/utils/app_info.dart';
import 'package:hestia/presentation/pages/error/global_error_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Boots the app inside a guarded zone so async errors reach Crashlytics.
/// [WidgetsFlutterBinding.ensureInitialized] and [runApp] must run in the
/// same zone (see Flutter binding zone checks).
Future<void> bootstrap() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await Env.load();
    await AppInfo.load();

    if (Env.isFirebaseConfigured) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await configureCrashlytics();
    } else {
      logger.w(
        'Firebase not configured — Crashlytics and native Firebase features disabled. '
        'Add FIREBASE_* keys to .env (see .env.example).',
      );
    }

    await _startApp();
  }, reportUncaughtAsyncError);
}

Future<void> _startApp() async {
  const flavorRaw = String.fromEnvironment('FLAVOR', defaultValue: 'supabase');
  FlavorConfig.current = AppFlavor.fromString(flavorRaw);
  logger.i('Flavor: ${FlavorConfig.current.name}');

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
  await AppDependencies.initialize(FlavorConfig.current, database: database);

  logger.i('App initialized');
  runApp(HestiaApp(database: database));
}
