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
  final BehaviorSubject<List<Appointment>> _subject = BehaviorSubject.seeded(const []);

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
      if (row == null) return (null, const ServerFailure('Appointment not found'));
      return (row.toAppointment(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<(Appointment?, Failure?)> create(Appointment appointment) async {
    try {
      final row = await _service.create(appointment);
      var saved = row.toAppointment();

      // Push to Google Calendar if linked.
      if (await _gcal.isLinked()) {
        try {
          final eventId = await _gcal.createEvent(saved);
          if (eventId != null) {
            await _service.upsertGoogleEventId(saved.id, eventId);
            saved = saved.copyWith(googleEventId: eventId);
          }
        } catch (_) {/* GCal failure shouldn't block local create */}
      }

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
      if (saved.googleEventId != null && await _gcal.isLinked()) {
        try {
          await _gcal.updateEvent(saved);
        } catch (_) {}
      }
      final list = _subject.value
          .map((a) => a.id == saved.id ? saved : a)
          .toList();
      _subject.add(list);
      return (saved, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<Failure?> delete(String id) async {
    try {
      final existing = _subject.value.where((a) => a.id == id).cast<Appointment?>().firstOrNull;
      await _service.delete(id);
      if (existing?.googleEventId != null && await _gcal.isLinked()) {
        try {
          await _gcal.deleteEvent(existing!.googleEventId!);
        } catch (_) {}
      }
      _subject.add(_subject.value.where((a) => a.id != id).toList());
      return null;
    } on ServerException catch (e) {
      return ServerFailure(e.message);
    }
  }

  @override
  Future<Failure?> syncWithGoogle({required String userId}) async {
    if (!await _gcal.isLinked()) return null;
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 30));
    final to = now.add(const Duration(days: 365));

    try {
      final remote = await _gcal.listRange(from, to);
      final (local, _) = await getRange(userId: userId, from: from, to: to);
      final localByGoogle = {
        for (final a in local)
          if (a.googleEventId != null) a.googleEventId!: a
      };

      // Pull side: insert/update local from remote.
      for (final ev in remote) {
        if (ev.id == null || ev.start?.dateTime == null || ev.end?.dateTime == null) {
          continue;
        }
        final existing = localByGoogle[ev.id];
        final data = Appointment(
          id: existing?.id ?? '',
          userId: userId,
          householdId: existing?.householdId,
          title: ev.summary ?? '(untitled)',
          notes: ev.description,
          location: ev.location,
          startsAt: ev.start!.dateTime!.toLocal(),
          duration:
              ev.end!.dateTime!.difference(ev.start!.dateTime!),
          category: existing?.category ?? AppointmentCategory.other,
          reminderOffsets: existing?.reminderOffsets ?? const [Duration(hours: 1)],
          googleEventId: ev.id,
          createdAt: existing?.createdAt ?? DateTime.now(),
        );
        if (existing == null) {
          await _service.create(data);
        } else {
          await _service.update(data);
        }
      }
      await _refresh(userId: userId, from: from, to: to);
      return null;
    } on ServerException catch (e) {
      return ServerFailure(e.message);
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

extension _ListExt<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
