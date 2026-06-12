import 'package:equatable/equatable.dart';

enum AppointmentCategory { health, vehicle, beauty, work, personal, other }

class Appointment extends Equatable {
  final String id;
  final String userId;
  final String? householdId;
  final String title;
  final String? notes;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime startsAt;
  final Duration duration;
  final AppointmentCategory category;

  /// Reminder offsets relative to [startsAt]. e.g. 1h, 24h, 1 week before.
  final List<Duration> reminderOffsets;

  /// Set when synced with Google Calendar (prod flavor only).
  final String? googleEventId;

  /// Optional pet/car links for calendar integration.
  ///
  /// [petIds] is the source of truth for related pets (multi-select, persisted
  /// via the `appointment_pets` join). [petId] is the first of [petIds], kept
  /// for single-link integrations (e.g. Google Calendar sync).
  final List<String> petIds;
  final String? carId;

  String? get petId => petIds.isEmpty ? null : petIds.first;

  /// All-day events are shown at the top of the day view.
  final bool isAllDay;

  /// When true, other household members can see this event. When false it
  /// stays private to [userId]. Lets housemates know each other's plans.
  final bool isShared;

  /// Optional hex color string (e.g. '#42A5F5'). When null the UI falls back
  /// to the owner's calendarColor, then the category tint.
  final String? color;

  final DateTime createdAt;
  final DateTime? lastUpdate;

  const Appointment({
    required this.id,
    required this.userId,
    this.householdId,
    required this.title,
    this.notes,
    this.location,
    this.latitude,
    this.longitude,
    required this.startsAt,
    this.duration = const Duration(hours: 1),
    this.category = AppointmentCategory.other,
    this.reminderOffsets = const [Duration(hours: 1)],
    this.googleEventId,
    this.petIds = const [],
    this.carId,
    this.isAllDay = false,
    this.isShared = true,
    this.color,
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
    double? latitude,
    double? longitude,
    bool clearLocationCoords = false,
    DateTime? startsAt,
    Duration? duration,
    AppointmentCategory? category,
    List<Duration>? reminderOffsets,
    String? googleEventId,
    List<String>? petIds,
    String? carId,
    bool? isAllDay,
    bool? isShared,
    String? color,
    bool clearColor = false,
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
        latitude: clearLocationCoords ? null : (latitude ?? this.latitude),
        longitude: clearLocationCoords ? null : (longitude ?? this.longitude),
        startsAt: startsAt ?? this.startsAt,
        duration: duration ?? this.duration,
        category: category ?? this.category,
        reminderOffsets: reminderOffsets ?? this.reminderOffsets,
        googleEventId: googleEventId ?? this.googleEventId,
        petIds: petIds ?? this.petIds,
        carId: carId ?? this.carId,
        isAllDay: isAllDay ?? this.isAllDay,
        isShared: isShared ?? this.isShared,
        color: clearColor ? null : (color ?? this.color),
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
        latitude,
        longitude,
        startsAt,
        duration,
        category,
        reminderOffsets,
        googleEventId,
        petIds,
        carId,
        isAllDay,
        isShared,
        color,
        createdAt,
        lastUpdate,
      ];
}
