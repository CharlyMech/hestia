import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/appointment.dart';

abstract class AppointmentRepository {
  /// Stream the user's appointments overlapping [from, to].
  Stream<List<Appointment>> watchRange({
    required String userId,
    required DateTime from,
    required DateTime to,
  });

  Future<(List<Appointment>, Failure?)> getRange({
    required String userId,
    required DateTime from,
    required DateTime to,
  });

  Future<(Appointment?, Failure?)> getById(String id);

  Future<(Appointment?, Failure?)> create(Appointment appointment);

  Future<(Appointment?, Failure?)> update(Appointment appointment);

  Future<Failure?> delete(String id);

  /// Sync local state with Google Calendar. No-op on mock flavor.
  Future<Failure?> syncWithGoogle({required String userId});

  /// Whether Google Calendar is currently linked (mock returns false).
  Future<bool> isGoogleLinked();

  /// Initiate Google Calendar OAuth flow. Mock no-ops.
  Future<Failure?> linkGoogle();

  /// Revoke Google Calendar link.
  Future<Failure?> unlinkGoogle();
}
