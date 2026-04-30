import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_seed.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/household.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/domain/repositories/auth_repository.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';

class MockAuthRepository implements AuthRepository {
  final LocalAuthentication _localAuth;

  MockAuthRepository({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  @override
  String? get currentUserId => MockStore.instance.currentProfile?.id;

  @override
  Future<(Profile?, Failure?)> signInWithApple() async {
    MockSeed.load();
    final store = MockStore.instance;
    store.authenticated = true;
    return (store.currentProfile, null);
  }

  @override
  Future<(Profile?, Failure?)> signInWithEmail(
      String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return (null, const AuthFailure('Email and password are required'));
    }
    MockSeed.load();
    final store = MockStore.instance;
    store.authenticated = true;
    return (store.currentProfile, null);
  }

  @override
  Future<Failure?> signOut() async {
    MockStore.instance.authenticated = false;
    return null;
  }

  @override
  Future<bool> hasValidSession() async {
    return MockStore.instance.authenticated;
  }

  @override
  Future<(Profile?, Failure?)> getCurrentProfile() async {
    MockSeed.load();
    return (MockStore.instance.currentProfile, null);
  }

  @override
  Future<(Profile?, Failure?)> createUser({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return (null, const AuthFailure('Email and password are required'));
    }
    final store = MockStore.instance;
    if (store.profiles.any((p) => p.email == email)) {
      return (null, const AuthFailure('User with that email already exists'));
    }
    final now = DateTime.now();
    final newUser = Profile(
      id: const Uuid().v4(),
      email: email,
      displayName: displayName,
      preferredCurrency: 'EUR',
      createdAt: now,
      lastUpdate: now,
    );
    store.profiles.add(newUser);
    if (store.household != null) {
      store.members.add(HouseholdMember(
        id: const Uuid().v4(),
        userId: newUser.id,
        householdId: store.household!.id,
        role: 'member',
        createdAt: now,
      ));
    }
    return (newUser, null);
  }

  @override
  Future<(bool, Failure?)> authenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      if (!canCheck || !supported) return (true, null);
      final ok = await _localAuth.authenticate(
        localizedReason: AppConstants.biometricReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return (ok, null);
    } catch (e) {
      return (false, mapExceptionToFailure(e));
    }
  }
}
