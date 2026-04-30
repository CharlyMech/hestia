import 'dart:async';

import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/domain/repositories/appointment_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class MockAppointmentRepository implements AppointmentRepository {
  final BehaviorSubject<List<Appointment>> _subject =
      BehaviorSubject.seeded(const []);
  static const _uuid = Uuid();

  MockAppointmentRepository() {
    _emit();
  }

  void _emit() => _subject.add(List.unmodifiable(MockStore.instance.appointments));

  @override
  Stream<List<Appointment>> watchRange({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) =>
      _subject.stream.map((all) => all
          .where((a) => a.userId == userId)
          .where((a) => a.endsAt.isAfter(from) && a.startsAt.isBefore(to))
          .toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt)));

  @override
  Future<(List<Appointment>, Failure?)> getRange({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final list = MockStore.instance.appointments
        .where((a) => a.userId == userId)
        .where((a) => a.endsAt.isAfter(from) && a.startsAt.isBefore(to))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return (list, null);
  }

  @override
  Future<(Appointment?, Failure?)> getById(String id) async {
    final found = MockStore.instance.appointments
        .where((a) => a.id == id)
        .cast<Appointment?>()
        .firstWhere((_) => true, orElse: () => null);
    if (found == null) return (null, const ServerFailure('Appointment not found'));
    return (found, null);
  }

  @override
  Future<(Appointment?, Failure?)> create(Appointment appointment) async {
    final saved = appointment.copyWith(
      id: appointment.id.isEmpty ? _uuid.v4() : appointment.id,
      createdAt: appointment.createdAt,
    );
    MockStore.instance.appointments.add(saved);
    _emit();
    return (saved, null);
  }

  @override
  Future<(Appointment?, Failure?)> update(Appointment appointment) async {
    final list = MockStore.instance.appointments;
    final i = list.indexWhere((a) => a.id == appointment.id);
    if (i < 0) return (null, const ServerFailure('Appointment not found'));
    final updated = appointment.copyWith(lastUpdate: DateTime.now());
    list[i] = updated;
    _emit();
    return (updated, null);
  }

  @override
  Future<Failure?> delete(String id) async {
    final list = MockStore.instance.appointments;
    final before = list.length;
    list.removeWhere((a) => a.id == id);
    if (list.length == before) return const ServerFailure('Appointment not found');
    _emit();
    return null;
  }

  @override
  Future<Failure?> syncWithGoogle({required String userId}) async => null;

  @override
  Future<bool> isGoogleLinked() async => false;

  @override
  Future<Failure?> linkGoogle() async => null;

  @override
  Future<Failure?> unlinkGoogle() async => null;
}
