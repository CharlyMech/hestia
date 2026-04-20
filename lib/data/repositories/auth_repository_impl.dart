import 'package:home_expenses/core/constants/supabase_tables.dart';
import 'package:home_expenses/core/error/error_handler.dart';
import 'package:home_expenses/core/error/failures.dart';
import 'package:home_expenses/core/utils/date_utils.dart';
import 'package:home_expenses/data/services/auth_service.dart';
import 'package:home_expenses/domain/entities/profile.dart';
import 'package:home_expenses/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  String? get currentUserId => _authService.currentUserIdOrNull;

  @override
  Future<(Profile?, Failure?)> signInWithApple() async {
    try {
      final response = await _authService.signInWithApple();
      if (response.user == null) {
        return (null, const AuthFailure('Sign-in returned no user'));
      }

      final profile = await _fetchOrCreateProfile(response.user!.id);
      return (profile, null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }

  @override
  Future<Failure?> signOut() async {
    try {
      await _authService.signOut();
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<bool> hasValidSession() async {
    try {
      return await _authService.hasValidSession();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<(Profile?, Failure?)> getCurrentProfile() async {
    try {
      final userId = _authService.currentUserId;
      final profile = await _fetchOrCreateProfile(userId);
      return (profile, null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }

  @override
  Future<(bool, Failure?)> authenticateWithBiometrics() async {
    try {
      final result = await _authService.authenticateWithBiometrics();
      return (result, null);
    } catch (e) {
      return (false, mapExceptionToFailure(e));
    }
  }

  Future<Profile> _fetchOrCreateProfile(String userId) async {
    final response = await _authService
        .from(SupabaseTables.profiles)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      // Profile should be auto-created by trigger, but just in case
      final user = _authService.currentUser!;
      final now = DateTime.now().toUnix;
      await _authService.from(SupabaseTables.profiles).insert({
        'id': userId,
        'email': user.email ?? '',
        'created_at': now,
        'last_update': now,
      });

      return Profile(
        id: userId,
        email: user.email ?? '',
        createdAt: DateTime.now(),
        lastUpdate: DateTime.now(),
      );
    }

    return Profile(
      id: response['id'] as String,
      email: response['email'] as String,
      displayName: response['display_name'] as String?,
      avatarUrl: response['avatar_url'] as String?,
      createdAt: (response['created_at'] as int).fromUnix,
      lastUpdate: (response['last_update'] as int).fromUnix,
    );
  }
}
