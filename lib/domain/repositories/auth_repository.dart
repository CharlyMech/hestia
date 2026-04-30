import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/profile.dart';

abstract class AuthRepository {
  /// Current user ID, null if not authenticated
  String? get currentUserId;

  /// Sign in with Apple
  Future<(Profile?, Failure?)> signInWithApple();

  /// Sign in with email + password
  Future<(Profile?, Failure?)> signInWithEmail(String email, String password);

  /// Sign out
  Future<Failure?> signOut();

  /// Check if session is valid
  Future<bool> hasValidSession();

  /// Get current profile
  Future<(Profile?, Failure?)> getCurrentProfile();

  /// Authenticate with biometrics
  Future<(bool, Failure?)> authenticateWithBiometrics();

  /// Superuser-only: create a new user account.
  /// Backed by a server-side admin endpoint in supabase flavor.
  Future<(Profile?, Failure?)> createUser({
    required String email,
    required String password,
    String? displayName,
  });
}
