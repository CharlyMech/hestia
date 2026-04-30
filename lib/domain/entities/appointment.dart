import 'package:equatable/equatable.dart';

enum AppointmentCategory { health, vehicle, beauty, work, personal, other }

class Appointment extends Equatable {
  final String id;
  final String userId;
  final String? householdId;
  final String title;
  final String? notes;
  final String? location;
  final DateTime startsAt;
  final Duration duration;
  final AppointmentCategory category;

  /// Reminder offsets relative to [startsAt]. e.g. 1h, 24h, 1 week before.
  final List<Duration> reminderOffsets;

  /// Set when synced with Google Calendar (prod flavor only).
  final String? googleEventId;

  final DateTime createdAt;
  final DateTime? lastUpdate;

  const Appointment({
    required this.id,
    required this.userId,
    this.householdId,
    required this.title,
    this.notes,
    this.location,
    required this.startsAt,
    this.duration = const Duration(hours: 1),
    this.category = AppointmentCategory.other,
    this.reminderOffsets = const [Duration(hours: 1)],
    this.googleEventId,
    required this.createdAt,
    this.lastUpdate,
  });

  DateTime get endsAt => startsAt.add(duration);

  Appointment copyWith({
    String? id,
    String? userId,
    String? householdId,
    String? title,
    String? notes,
    String? location,
    DateTime? startsAt,
    Duration? duration,
    AppointmentCategory? category,
    List<Duration>? reminderOffsets,
    String? googleEventId,
    DateTime? createdAt,
    DateTime? lastUpdate,
  }) =>
      Appointment(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        householdId: householdId ?? this.householdId,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        location: location ?? this.location,
        startsAt: startsAt ?? this.startsAt,
        duration: duration ?? this.duration,
        category: category ?? this.category,
        reminderOffsets: reminderOffsets ?? this.reminderOffsets,
        googleEventId: googleEventId ?? this.googleEventId,
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        householdId,
        title,
        notes,
        location,
        startsAt,
        duration,
        category,
        reminderOffsets,
        googleEventId,
        createdAt,
        lastUpdate,
      ];
}
