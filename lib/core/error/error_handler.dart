import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import 'package:hestia/core/config/crashlytics.dart';
import 'exceptions.dart';
import 'failures.dart';

/// App-wide logger. Debug builds log everything; release keeps warnings/errors.
final logger = Logger(
  level: kReleaseMode ? Level.warning : Level.debug,
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);

/// Logs an error, records it to Crashlytics (non-fatal), and returns a typed
/// [Failure] for the UI. The one-liner every repository catch should use:
///   `catch (e, st) { return reportError(e, st, reason: 'getX'); }`
Failure reportError(Object error, StackTrace stackTrace, {String? reason}) {
  logger.e(reason ?? 'Error', error: error, stackTrace: stackTrace);
  recordNonFatalError(error, stackTrace, reason: reason);
  return mapExceptionToFailure(error);
}

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

  if (error is FormatException) {
    return ServerFailure(error.message);
  }

  logger.e('Unhandled error', error: error);
  recordNonFatalError(
    error,
    StackTrace.current,
    reason: 'mapExceptionToFailure unhandled',
  );
  return ServerFailure(error.toString());
}
