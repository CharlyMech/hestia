import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/domain/repositories/appointment_repository.dart';
import 'package:uuid/uuid.dart';

abstract class AppointmentFormEvent extends Equatable {
  const AppointmentFormEvent();
  @override
  List<Object?> get props => const [];
}

class FormInit extends AppointmentFormEvent {
  final Appointment? existing;
  final DateTime? defaultDate;
  final String userId;
  final String? householdId;
  const FormInit({
    this.existing,
    this.defaultDate,
    required this.userId,
    this.householdId,
  });
  @override
  List<Object?> get props => [existing, defaultDate, userId, householdId];
}

class FormTitleChanged extends AppointmentFormEvent {
  final String title;
  const FormTitleChanged(this.title);
  @override
  List<Object?> get props => [title];
}

class FormNotesChanged extends AppointmentFormEvent {
  final String notes;
  const FormNotesChanged(this.notes);
  @override
  List<Object?> get props => [notes];
}

class FormLocationChanged extends AppointmentFormEvent {
  final String location;
  const FormLocationChanged(this.location);
  @override
  List<Object?> get props => [location];
}

class FormStartChanged extends AppointmentFormEvent {
  final DateTime startsAt;
  const FormStartChanged(this.startsAt);
  @override
  List<Object?> get props => [startsAt];
}

class FormDurationChanged extends AppointmentFormEvent {
  final Duration duration;
  const FormDurationChanged(this.duration);
  @override
  List<Object?> get props => [duration];
}

class FormCategoryChanged extends AppointmentFormEvent {
  final AppointmentCategory category;
  const FormCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}

class FormToggleReminder extends AppointmentFormEvent {
  final Duration offset;
  const FormToggleReminder(this.offset);
  @override
  List<Object?> get props => [offset];
}

class FormSubmit extends AppointmentFormEvent {
  const FormSubmit();
}

class FormDelete extends AppointmentFormEvent {
  const FormDelete();
}

class AppointmentFormState extends Equatable {
  final String userId;
  final String? householdId;
  final String? id;
  final String title;
  final String notes;
  final String location;
  final DateTime startsAt;
  final Duration duration;
  final AppointmentCategory category;
  final List<Duration> reminderOffsets;
  final String? googleEventId;
  final DateTime createdAt;

  final bool submitting;
  final bool saved;
  final bool deleted;
  final String? error;

  const AppointmentFormState({
    required this.userId,
    this.householdId,
    this.id,
    this.title = '',
    this.notes = '',
    this.location = '',
    required this.startsAt,
    this.duration = const Duration(hours: 1),
    this.category = AppointmentCategory.other,
    this.reminderOffsets = const [Duration(hours: 1)],
    this.googleEventId,
    required this.createdAt,
    this.submitting = false,
    this.saved = false,
    this.deleted = false,
    this.error,
  });

  bool get isEdit => id != null;
  bool get titleValid => title.trim().isNotEmpty;

  AppointmentFormState copyWith({
    String? title,
    String? notes,
    String? location,
    DateTime? startsAt,
    Duration? duration,
    AppointmentCategory? category,
    List<Duration>? reminderOffsets,
    bool? submitting,
    bool? saved,
    bool? deleted,
    String? error,
    bool clearError = false,
  }) =>
      AppointmentFormState(
        userId: userId,
        householdId: householdId,
        id: id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        location: location ?? this.location,
        startsAt: startsAt ?? this.startsAt,
        duration: duration ?? this.duration,
        category: category ?? this.category,
        reminderOffsets: reminderOffsets ?? this.reminderOffsets,
        googleEventId: googleEventId,
        createdAt: createdAt,
        submitting: submitting ?? this.submitting,
        saved: saved ?? this.saved,
        deleted: deleted ?? this.deleted,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [
        userId,
        householdId,
        id,
        title,
        notes,
        location,
        startsAt,
        duration,
        category,
        reminderOffsets,
        googleEventId,
        createdAt,
        submitting,
        saved,
        deleted,
        error,
      ];
}

class AppointmentFormBloc
    extends Bloc<AppointmentFormEvent, AppointmentFormState> {
  final AppointmentRepository _repo;
  static const _uuid = Uuid();

  AppointmentFormBloc({
    required AppointmentRepository repository,
    required String userId,
    String? householdId,
    Appointment? existing,
    DateTime? defaultDate,
  })  : _repo = repository,
        super(AppointmentFormState(
          userId: userId,
          householdId: householdId,
          id: existing?.id,
          title: existing?.title ?? '',
          notes: existing?.notes ?? '',
          location: existing?.location ?? '',
          startsAt: existing?.startsAt ??
              _defaultStart(defaultDate ?? DateTime.now()),
          duration: existing?.duration ?? const Duration(hours: 1),
          category: existing?.category ?? AppointmentCategory.other,
          reminderOffsets:
              existing?.reminderOffsets ?? const [Duration(hours: 1)],
          createdAt: existing?.createdAt ?? DateTime.now(),
        )) {
    on<FormTitleChanged>((e, emit) => emit(state.copyWith(title: e.title)));
    on<FormNotesChanged>((e, emit) => emit(state.copyWith(notes: e.notes)));
    on<FormLocationChanged>(
        (e, emit) => emit(state.copyWith(location: e.location)));
    on<FormStartChanged>(
        (e, emit) => emit(state.copyWith(startsAt: e.startsAt)));
    on<FormDurationChanged>(
        (e, emit) => emit(state.copyWith(duration: e.duration)));
    on<FormCategoryChanged>(
        (e, emit) => emit(state.copyWith(category: e.category)));
    on<FormToggleReminder>(_onToggleReminder);
    on<FormSubmit>(_onSubmit);
    on<FormDelete>(_onDelete);
  }

  static DateTime _defaultStart(DateTime base) {
    // Round up to next quarter hour, default 9:00 if base is midnight.
    final stripped =
        DateTime(base.year, base.month, base.day, base.hour, base.minute);
    if (stripped.hour == 0 && stripped.minute == 0) {
      return DateTime(base.year, base.month, base.day, 9);
    }
    final rem = stripped.minute % 15;
    return rem == 0
        ? stripped
        : stripped.add(Duration(minutes: 15 - rem));
  }

  void _onToggleReminder(
      FormToggleReminder e, Emitter<AppointmentFormState> emit) {
    final list = List<Duration>.from(state.reminderOffsets);
    if (list.any((d) => d.inMinutes == e.offset.inMinutes)) {
      list.removeWhere((d) => d.inMinutes == e.offset.inMinutes);
    } else {
      list.add(e.offset);
    }
    list.sort((a, b) => a.compareTo(b));
    emit(state.copyWith(reminderOffsets: list));
  }

  Future<void> _onSubmit(
      FormSubmit e, Emitter<AppointmentFormState> emit) async {
    if (!state.titleValid) {
      emit(state.copyWith(error: 'Title is required'));
      return;
    }
    emit(state.copyWith(submitting: true, clearError: true));

    final appt = Appointment(
      id: state.id ?? _uuid.v4(),
      userId: state.userId,
      householdId: state.householdId,
      title: state.title.trim(),
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
      location: state.location.trim().isEmpty ? null : state.location.trim(),
      startsAt: state.startsAt,
      duration: state.duration,
      category: state.category,
      reminderOffsets: state.reminderOffsets,
      googleEventId: state.googleEventId,
      createdAt: state.createdAt,
    );

    final result = state.isEdit
        ? await _repo.update(appt)
        : await _repo.create(appt);

    if (result.$2 != null) {
      emit(state.copyWith(submitting: false, error: result.$2!.message));
      return;
    }
    emit(state.copyWith(submitting: false, saved: true));
  }

  Future<void> _onDelete(
      FormDelete e, Emitter<AppointmentFormState> emit) async {
    if (state.id == null) return;
    emit(state.copyWith(submitting: true, clearError: true));
    final fail = await _repo.delete(state.id!);
    if (fail != null) {
      emit(state.copyWith(submitting: false, error: fail.message));
      return;
    }
    emit(state.copyWith(submitting: false, deleted: true));
  }
}
