import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/services/auth_service.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/domain/repositories/auth_repository.dart';

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
  Future<(Profile?, Failure?)> signInWithEmail(
      String email, String password) async {
    try {
      final response = await _authService.signInWithEmail(email, password);
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

  @override
  Future<(Profile?, Failure?)> createUser({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Calls a Supabase Edge Function that uses the service role key
      // server-side. The function checks `is_superuser` on the caller's
      // profile before creating the user. App-side stub: no client-side
      // service-role calls — that key must never live in the app.
      final response = await _authService.client.functions.invoke(
        'admin-create-user',
        body: {
          'email': email,
          'password': password,
          if (displayName != null) 'display_name': displayName,
        },
      );
      if (response.status >= 400) {
        return (
          null,
          AuthFailure(
            (response.data is Map ? response.data['error'] : null)?.toString() ??
                'Create user failed (${response.status})',
          ),
        );
      }
      final data = response.data as Map<String, dynamic>;
      return (
        Profile(
          id: data['id'] as String,
          email: data['email'] as String,
          displayName: data['display_name'] as String?,
          preferredCurrency: (data['preferred_currency'] as String?) ?? 'EUR',
          createdAt: DateTime.now(),
          lastUpdate: DateTime.now(),
        ),
        null,
      );
    } catch (e) {
      return (null, mapExceptionToFailure(e));
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
        preferredCurrency: 'EUR',
        createdAt: DateTime.now(),
        lastUpdate: DateTime.now(),
      );
    }

    return Profile(
      id: response['id'] as String,
      email: response['email'] as String,
      displayName: response['display_name'] as String?,
      avatarUrl: response['avatar_url'] as String?,
      preferredCurrency: (response['preferred_currency'] as String?) ?? 'EUR',
      calendarColor: response['calendar_color'] as String?,
      isSuperuser: (response['is_superuser'] as bool?) ?? false,
      createdAt: (response['created_at'] as int).fromUnix,
      lastUpdate: (response['last_update'] as int).fromUnix,
    );
  }

  @override
  Future<(Profile?, Failure?)> updateProfile(Profile profile) async {
    try {
      final now = DateTime.now().toUnix;
      await _authService.from(SupabaseTables.profiles).update({
        'display_name': profile.displayName,
        'avatar_url': profile.avatarUrl,
        'preferred_currency': profile.preferredCurrency,
        'calendar_color': profile.calendarColor,
        'last_update': now,
      }).eq('id', profile.id);
      return (profile.copyWith(lastUpdate: DateTime.now()), null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }
}
