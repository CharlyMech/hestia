import 'package:equatable/equatable.dart';

/// Base failure class. Every error surfaces to the UI as a Failure.
sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class BiometricFailure extends Failure {
  const BiometricFailure([super.message = 'Biometric authentication failed']);
}
