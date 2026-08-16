import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:hestia/core/config/env.dart';

/// Builds [FirebaseOptions] from the Dart configuration in `env.dart`.
///
/// Run `flutterfire configure` for native files, then copy the public client
/// values into `env.dart`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!Env.isFirebaseConfigured) {
      throw StateError(
        'Firebase is not configured. Add its public client values to env.dart.',
      );
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase web is not configured. Run flutterfire configure for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        throw UnsupportedError(
          'Firebase Android is not configured. Run flutterfire configure.',
        );
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase is not configured for $defaultTargetPlatform.',
        );
      default:
        throw UnsupportedError(
          'Firebase is not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: Env.firebaseApiKey,
        appId: Env.firebaseAppId,
        messagingSenderId: Env.firebaseMessagingSenderId,
        projectId: Env.firebaseProjectId,
        storageBucket: Env.firebaseStorageBucket,
        iosBundleId: Env.firebaseIosBundleId,
      );
}
