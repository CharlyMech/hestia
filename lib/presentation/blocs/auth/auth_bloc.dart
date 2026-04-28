import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/repositories/auth_repository.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthCheckSession>(_onCheckSession);
    on<AuthSignInWithApple>(_onSignInWithApple);
    on<AuthSignOut>(_onSignOut);
    on<AuthBiometricCheck>(_onBiometricCheck);
  }

  Future<void> _onCheckSession(
      AuthCheckSession event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(message: 'Checking session...'));

    final hasSession = await _authRepository.hasValidSession();
    if (!hasSession) {
      emit(const AuthUnauthenticated());
      return;
    }

    emit(const AuthBiometricRequired());
  }

  Future<void> _onBiometricCheck(
      AuthBiometricCheck event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(message: 'Verifying identity...'));

    final (passed, bioFailure) =
        await _authRepository.authenticateWithBiometrics();
    if (bioFailure != null || !passed) {
      emit(const AuthUnauthenticated());
      return;
    }

    emit(const AuthLoading(message: 'Loading profile...'));
    final (profile, profileFailure) = await _authRepository.getCurrentProfile();
    if (profileFailure != null || profile == null) {
      emit(AuthError(profileFailure ?? const AuthFailure('No profile found')));
      return;
    }

    emit(AuthAuthenticated(profile));
  }

  Future<void> _onSignInWithApple(
      AuthSignInWithApple event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(message: 'Signing in...'));

    final (profile, failure) = await _authRepository.signInWithApple();
    if (failure != null || profile == null) {
      emit(AuthError(failure ?? const AuthFailure('Sign-in failed')));
      return;
    }

    emit(AuthAuthenticated(profile));
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final failure = await _authRepository.signOut();
    if (failure != null) {
      emit(AuthError(failure));
      return;
    }

    emit(const AuthUnauthenticated());
  }
}
