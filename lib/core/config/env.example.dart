// Copy this file to `env.dart` and replace every placeholder.
// Never put server credentials or database passwords in a Flutter app.
abstract final class Env {
  static const supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const supabaseAnonKey = 'YOUR_ANON_KEY';

  static const appleClientId = 'com.yourdomain.hestia';
  static const appleRedirectUri =
      'https://YOUR_PROJECT.supabase.co/auth/v1/callback';

  static const magicLaneApiKey = 'YOUR_MAGICLANE_API_KEY';

  static const firebaseApiKey = 'YOUR_FIREBASE_API_KEY';
  static const firebaseAppId = 'YOUR_FIREBASE_APP_ID';
  static const firebaseMessagingSenderId = 'YOUR_FIREBASE_SENDER_ID';
  static const firebaseProjectId = 'YOUR_FIREBASE_PROJECT_ID';
  static const firebaseStorageBucket = 'YOUR_FIREBASE_STORAGE_BUCKET';
  static const firebaseIosBundleId = 'com.yourdomain.hestia';

  static bool get isConfigured =>
      _hasValue(supabaseUrl) && _hasValue(supabaseAnonKey);

  static bool get isFirebaseConfigured =>
      _hasValue(firebaseApiKey) &&
      _hasValue(firebaseAppId) &&
      _hasValue(firebaseMessagingSenderId) &&
      _hasValue(firebaseProjectId) &&
      _hasValue(firebaseStorageBucket) &&
      _hasValue(firebaseIosBundleId);

  static bool _hasValue(String value) =>
      value.isNotEmpty &&
      !value.contains('YOUR_') &&
      !value.startsWith('your_');
}
