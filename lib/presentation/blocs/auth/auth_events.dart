import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckSession extends AuthEvent {
  const AuthCheckSession();
}

class AuthSignInWithApple extends AuthEvent {
  const AuthSignInWithApple();
}

class AuthSignInWithEmail extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInWithEmail(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class AuthSignOut extends AuthEvent {
  const AuthSignOut();
}

class AuthBiometricCheck extends AuthEvent {
  const AuthBiometricCheck();
}

class AuthDevBypass extends AuthEvent {
  const AuthDevBypass();
}
