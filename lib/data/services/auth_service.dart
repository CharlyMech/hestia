import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import 'package:hestia/core/error/exceptions.dart';
import 'supabase_service.dart';

class AuthService extends SupabaseService {
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  AuthService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
    super.client,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  /// Sign in with Apple via Supabase
  Future<AuthResponse> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException('Apple Sign-In returned no identity token');
      }

      final response = await auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );

      if (response.session != null) {
        await _persistSession(response.session!);
      }

      return response;
    } on SignInWithAppleAuthorizationException catch (e) {
      throw AuthException('Apple Sign-In cancelled or failed: ${e.message}');
    } on AuthApiException catch (e) {
      throw AuthException(e.message, code: e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Sign-in failed: $e');
    }
  }

  /// Sign out and clear stored session
  Future<void> signOut() async {
    try {
      await auth.signOut();
      await _secureStorage.delete(key: 'session_access_token');
      await _secureStorage.delete(key: 'session_refresh_token');
    } catch (e) {
      throw AuthException('Sign-out failed: $e');
    }
  }

  /// Check if a valid session exists
  Future<bool> hasValidSession() async {
    final session = currentSession;
    if (session == null) return false;

    // Check if token is expired
    if (session.isExpired) {
      // Try to refresh
      try {
        final refreshed = await auth.refreshSession();
        if (refreshed.session != null) {
          await _persistSession(refreshed.session!);
          return true;
        }
        return false;
      } catch (_) {
        return false;
      }
    }

    return true;
  }

  /// Authenticate with Face ID / biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        // Device doesn't support biometrics — allow through
        return true;
      }

      return await _localAuth.authenticate(
        localizedReason: AppConstants.biometricReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      throw AuthException('Biometric authentication error: $e');
    }
  }

  /// Get current user's profile data from auth metadata
  User? get currentUser => auth.currentUser;

  /// Persist session tokens securely
  Future<void> _persistSession(Session session) async {
    await _secureStorage.write(
      key: 'session_access_token',
      value: session.accessToken,
    );
    if (session.refreshToken != null) {
      await _secureStorage.write(
        key: 'session_refresh_token',
        value: session.refreshToken!,
      );
    }
  }
}
