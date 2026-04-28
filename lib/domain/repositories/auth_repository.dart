import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/profile.dart';

abstract class AuthRepository {
  /// Current user ID, null if not authenticated
  String? get currentUserId;

  /// Sign in with Apple
  Future<(Profile?, Failure?)> signInWithApple();

  /// Sign out
  Future<Failure?> signOut();

  /// Check if session is valid
  Future<bool> hasValidSession();

  /// Get current profile
  Future<(Profile?, Failure?)> getCurrentProfile();

  /// Authenticate with biometrics
  Future<(bool, Failure?)> authenticateWithBiometrics();
}
