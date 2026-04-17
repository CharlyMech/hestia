abstract final class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_ANON_KEY',
  );

  /// Apple Sign-In
  static const appleClientId = String.fromEnvironment(
    'APPLE_CLIENT_ID',
    defaultValue: 'com.yourdomain.homeexpenses',
  );

  static const appleRedirectUri = String.fromEnvironment(
    'APPLE_REDIRECT_URI',
    defaultValue: 'https://YOUR_PROJECT.supabase.co/auth/v1/callback',
  );
}
