import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import 'exceptions.dart';
import 'failures.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);

/// Maps raw exceptions to typed Failures for the UI layer.
Failure mapExceptionToFailure(Object error) {
  if (error is AuthException) {
    return AuthFailure(error.message, code: error.code);
  }

  if (error is ServerException) {
    return ServerFailure(error.message, code: error.code);
  }

  if (error is CacheException) {
    return CacheFailure(error.message);
  }

  if (error is NetworkException) {
    return NetworkFailure(error.message);
  }

  if (error is ValidationException) {
    return ValidationFailure(error.message);
  }

  if (error is BiometricException) {
    return BiometricFailure(error.message);
  }

  if (error is AuthApiException) {
    return AuthFailure(error.message, code: error.statusCode?.toString());
  }

  if (error is PostgrestException) {
    return ServerFailure(error.message, code: error.code);
  }

  logger.e('Unhandled error', error: error);
  return ServerFailure(error.toString());
}
