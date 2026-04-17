/// Thrown by services. Caught by repositories and mapped to Failures.
class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException(this.message, {this.code});

  @override
  String toString() => 'ServerException($code): $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException($code): $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;

  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class BiometricException implements Exception {
  final String message;

  const BiometricException([this.message = 'Biometric authentication failed']);

  @override
  String toString() => 'BiometricException: $message';
}
