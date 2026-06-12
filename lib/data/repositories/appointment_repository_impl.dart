import 'dart:async';

import 'package:hestia/core/error/exceptions.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/services/appointment_service.dart';
import 'package:hestia/data/services/google_calendar_service.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/domain/repositories/appointment_repository.dart';
import 'package:rxdart/rxdart.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentService _service;
  final GoogleCalendarService _gcal;
  final BehaviorSubject<List<Appointment>> _subject =
      BehaviorSubject.seeded(const []);

  AppointmentRepositoryImpl(this._service, this._gcal);

  @override
  Stream<List<Appointment>> watchRange({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) {
    // Initial fetch primes the subject; callers should refresh on writes.
    unawaited(_refresh(userId: userId, from: from, to: to));
    return _subject.stream.map((all) => all
        .where((a) => a.endsAt.isAfter(from) && a.startsAt.isBefore(to))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt)));
  }

  Future<void> _refresh({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final rows =
          await _service.getRange(userId: userId, fromDate: from, toDate: to);
      _subject.add(rows.map((r) => r.toAppointment()).toList());
    } catch (_) {
      // Swallow — UI will show last good snapshot.
    }
  }

  @override
  Future<(List<Appointment>, Failure?)> getRange({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final rows = await _service.getRange(
        userId: userId,
        fromDate: from,
        toDate: to,
      );
      return (rows.map((r) => r.toAppointment()).toList(), null);
    } on ServerException catch (e) {
      return (<Appointment>[], ServerFailure(e.message));
    }
  }

  @override
  Future<(Appointment?, Failure?)> getById(String id) async {
    try {
      final row = await _service.getById(id);
      if (row == null) {
        return (null, const ServerFailure('Appointment not found'));
      }
      return (row.toAppointment(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<(Appointment?, Failure?)> create(Appointment appointment) async {
    try {
      // upsert-appointment edge fn mirrors to GCal server-side.
      final row = await _service.create(appointment);
      final saved = row.toAppointment();
      _subject.add([..._subject.value, saved]);
      return (saved, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<(Appointment?, Failure?)> update(Appointment appointment) async {
    try {
      final row = await _service.update(appointment);
      final saved = row.toAppointment();
      final list =
          _subject.value.map((a) => a.id == saved.id ? saved : a).toList();
      _subject.add(list);
      return (saved, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<Failure?> delete(String id) async {
    try {
      // delete-appointment edge fn removes GCal event + reminders server-side.
      await _service.delete(id);
      _subject.add(_subject.value.where((a) => a.id != id).toList());
      return null;
    } on ServerException catch (e) {
      return ServerFailure(e.message);
    }
  }

  @override
  Future<Failure?> syncWithGoogle({
    required String userId,
    String? defaultColor,
  }) async {
    // google-calendar-sync edge fn handles pull server-side (also called by
    // pg_cron every 15 min). On-demand trigger; result reflected on next
    // watchRange emission after refresh.
    try {
      await _service.client.functions.invoke(
        'google-calendar-sync',
        body: {'user_id': userId},
      );
      final now = DateTime.now();
      await _refresh(
        userId: userId,
        from: now.subtract(const Duration(days: 30)),
        to: now.add(const Duration(days: 365)),
      );
      return null;
    } catch (e) {
      return ServerFailure('Google Calendar sync failed: $e');
    }
  }

  @override
  Future<bool> isGoogleLinked() => _gcal.isLinked();

  @override
  Future<Failure?> linkGoogle() async {
    final ok = await _gcal.link();
    return ok ? null : const AuthFailure('Google sign-in cancelled');
  }

  @override
  Future<Failure?> unlinkGoogle() async {
    await _gcal.unlink();
    return null;
  }
}

