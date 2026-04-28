import 'package:equatable/equatable.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/profile.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});
  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  final Profile profile;
  const AuthAuthenticated(this.profile);
  @override
  List<Object?> get props => [profile];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthBiometricRequired extends AuthState {
  const AuthBiometricRequired();
}

class AuthError extends AuthState {
  final Failure failure;
  const AuthError(this.failure);
  @override
  List<Object?> get props => [failure];
}
