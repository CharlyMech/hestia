import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hestia/core/config/env.dart';
import 'package:hestia/core/error/error_handler.dart';

bool get isCrashlyticsEnabled => Env.isFirebaseConfigured && !kDebugMode;

/// Configures Firebase Crashlytics after [Firebase.initializeApp].
/// No-op when Firebase is not configured or the app runs in debug mode.
Future<void> configureCrashlytics() async {
  if (!Env.isFirebaseConfigured) {
    logger.w('Crashlytics skipped: Firebase env not configured');
    return;
  }

  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (isCrashlyticsEnabled) {
      crashlytics.recordFlutterFatalError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (isCrashlyticsEnabled) {
      crashlytics.recordError(error, stack, fatal: true);
    }
    return true;
  };
}

void reportUncaughtAsyncError(Object error, StackTrace stack) {
  logger.e('Uncaught async error', error: error, stackTrace: stack);
  if (isCrashlyticsEnabled) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  }
}

/// Records a non-fatal error for Crashlytics (no-op in debug / without Firebase).
void recordNonFatalError(
  Object error,
  StackTrace stack, {
  String? reason,
}) {
  if (!isCrashlyticsEnabled) return;
  FirebaseCrashlytics.instance.recordError(
    error,
    stack,
    reason: reason,
    fatal: false,
  );
}

/// Associates Crashlytics reports with the signed-in user (hashed id only).
Future<void> setCrashlyticsUser(String? userId) async {
  if (!Env.isFirebaseConfigured) return;
  await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
}
