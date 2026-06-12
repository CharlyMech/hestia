import 'package:google_sign_in/google_sign_in.dart';

/// Handles Google sign-in for Calendar OAuth.
/// GCal write operations (create/update/delete events) and read sync
/// are handled server-side by edge functions (upsert-appointment,
/// delete-appointment, google-calendar-sync). This service only covers
/// the client-side sign-in needed to obtain a serverAuthCode that is
/// exchanged server-side via google-oauth-exchange.
class GoogleCalendarService {
  // calendar.events scope needed so the resulting refresh_token can
  // manage calendar events server-side.
  static const _scopes = ['https://www.googleapis.com/auth/calendar.events'];

  final GoogleSignIn _signIn;

  /// [serverClientId] must be the Web OAuth client ID (not the iOS client ID).
  /// Defaults to the --dart-define GOOGLE_WEB_CLIENT_ID build variable.
  /// The serverAuthCode returned by signIn() is exchanged server-side for
  /// a refresh_token via the google-oauth-exchange edge function.
  GoogleCalendarService({
    String? serverClientId,
  }) : _signIn = GoogleSignIn(
          scopes: _scopes,
          serverClientId: serverClientId ??
              const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
        );

  /// Signs in interactively and returns the serverAuthCode to be exchanged
  /// server-side. Returns null if the user cancelled or serverClientId unset.
  Future<String?> signInForServerAuthCode() async {
    final account = await _signIn.signIn();
    return account?.serverAuthCode;
  }

  /// Signs in silently (re-auth after app restart).
  Future<String?> signInSilentlyForServerAuthCode() async {
    final account = await _signIn.signInSilently();
    return account?.serverAuthCode;
  }

  /// Returns the signed-in Google account email, or null if not signed in.
  Future<String?> currentEmail() async => _signIn.currentUser?.email;

  /// Signs out from Google on this device (does NOT revoke server-side token —
  /// that is done via the google-oauth-exchange edge fn with action='unlink').
  Future<void> signOut() => _signIn.signOut();

  /// Revokes the OAuth grant on the device (also triggers server-side cleanup).
  Future<void> disconnect() => _signIn.disconnect();
}
