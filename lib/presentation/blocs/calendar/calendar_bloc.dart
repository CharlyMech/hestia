import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/repositories/appointment_repository.dart';
import 'package:hestia/domain/repositories/household_repository.dart';
import 'package:hestia/domain/repositories/transaction_repository.dart';

/// Unified item shown in the calendar agenda — either an appointment
/// ("evento") or a recurring transaction ("movimiento").
sealed class CalendarItem extends Equatable {
  DateTime get when;
  String get id;
}

class AppointmentItem extends CalendarItem {
  final Appointment appointment;
  AppointmentItem(this.appointment);
  @override
  DateTime get when => appointment.startsAt;
  @override
  String get id => appointment.id;
  @override
  List<Object?> get props => [appointment];
}

class TransactionItem extends CalendarItem {
  final Transaction transaction;
  TransactionItem(this.transaction);
  @override
  DateTime get when => transaction.date;
  @override
  String get id => transaction.id;
  @override
  List<Object?> get props => [transaction];
}

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();
  @override
  List<Object?> get props => const [];
}

class CalendarLoad extends CalendarEvent {
  final String userId;
  final String householdId;
  final DateTime month;
  const CalendarLoad({
    required this.userId,
    required this.householdId,
    required this.month,
  });
  @override
  List<Object?> get props => [userId, householdId, month];
}

class CalendarSelectDate extends CalendarEvent {
  final DateTime date;
  const CalendarSelectDate(this.date);
  @override
  List<Object?> get props => [date];
}

class CalendarToggleEventos extends CalendarEvent {
  const CalendarToggleEventos();
}

class CalendarToggleMovimientos extends CalendarEvent {
  const CalendarToggleMovimientos();
}

class CalendarMonthChanged extends CalendarEvent {
  final DateTime month;
  const CalendarMonthChanged(this.month);
  @override
  List<Object?> get props => [month];
}

class CalendarAppointmentAdded extends CalendarEvent {
  const CalendarAppointmentAdded();
}

class CalendarAppointmentUpdated extends CalendarEvent {
  final Appointment appointment;
  const CalendarAppointmentUpdated(this.appointment);
  @override
  List<Object?> get props => [appointment];
}

class CalendarDeleteAppointment extends CalendarEvent {
  final String appointmentId;
  const CalendarDeleteAppointment(this.appointmentId);
  @override
  List<Object?> get props => [appointmentId];
}

class CalendarRefresh extends CalendarEvent {
  final int _nonce;
  CalendarRefresh() : _nonce = DateTime.now().microsecondsSinceEpoch;
  @override
  List<Object?> get props => [_nonce];
}

class CalendarMarkAllDay extends CalendarEvent {
  final String appointmentId;
  const CalendarMarkAllDay(this.appointmentId);
  @override
  List<Object?> get props => [appointmentId];
}

/// Triggers an on-demand pull from Google Calendar then refreshes the range.
class CalendarGoogleSyncRequested extends CalendarEvent {
  final String userId;
  const CalendarGoogleSyncRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

/// Toggles a specific user's events in/out of the visible set.
/// When [userId] is already in [CalendarState.visibleUserIds] it is removed;
/// otherwise it is added. At least one user always stays visible.
class CalendarToggleUser extends CalendarEvent {
  final String userId;
  const CalendarToggleUser(this.userId);
  @override
  List<Object?> get props => [userId];
}

class CalendarState extends Equatable {
  final DateTime selectedDate;
  final DateTime visibleMonth;
  final List<Appointment> appointments;
  final List<Transaction> recurringTx;
  final bool showAppointments;
  final bool showTransactions;
  final bool loading;
  final String? error;
  final Set<String> allDayAppointmentIds;
  /// userId → hex color string (e.g. '#42A5F5'). Loaded from household profiles.
  final Map<String, String> ownerColors;
  /// All household member profiles — used to render per-member filter chips.
  final List<Profile> memberProfiles;
  /// Which user IDs are currently visible. Null means "show all" (legacy path).
  /// After load this is always initialized to {currentUserId}.
  final Set<String>? visibleUserIds;

  const CalendarState({
    required this.selectedDate,
    required this.visibleMonth,
    this.appointments = const [],
    this.recurringTx = const [],
    this.showAppointments = true,
    this.showTransactions = true,
    this.loading = false,
    this.error,
    this.allDayAppointmentIds = const {},
    this.ownerColors = const {},
    this.memberProfiles = const [],
    this.visibleUserIds,
  });

  /// All items in the visible month, post-filter.
  List<CalendarItem> visibleItemsFor(String? userId) {
    final ids = visibleUserIds;
    final items = <CalendarItem>[];
    if (showAppointments) {
      var appts = appointments;
      if (ids != null) appts = appts.where((a) => ids.contains(a.userId)).toList();
      items.addAll(appts.map(AppointmentItem.new));
    }
    if (showTransactions) {
      var txs = recurringTx;
      if (ids != null) txs = txs.where((t) => ids.contains(t.userId)).toList();
      items.addAll(txs.map(TransactionItem.new));
    }
    items.sort((a, b) => a.when.compareTo(b.when));
    return items;
  }

  /// Backwards-compat shortcut (no filter).
  List<CalendarItem> get visibleItems => visibleItemsFor(null);

  List<CalendarItem> itemsForDay(DateTime day) {
    return visibleItems
        .where((it) =>
            it.when.year == day.year &&
            it.when.month == day.month &&
            it.when.day == day.day)
        .toList();
  }

  /// Days in current month that have at least one (filtered) item — used
  /// by the calendar grid to render dot markers.
  Set<DateTime> get markedDays {
    final out = <DateTime>{};
    for (final it in visibleItems) {
      out.add(DateTime(it.when.year, it.when.month, it.when.day));
    }
    return out;
  }

  CalendarState copyWith({
    DateTime? selectedDate,
    DateTime? visibleMonth,
    List<Appointment>? appointments,
    List<Transaction>? recurringTx,
    bool? showAppointments,
    bool? showTransactions,
    bool? loading,
    String? error,
    bool clearError = false,
    Set<String>? allDayAppointmentIds,
    Map<String, String>? ownerColors,
    List<Profile>? memberProfiles,
    Set<String>? visibleUserIds,
    bool clearVisibleUserIds = false,
  }) =>
      CalendarState(
        selectedDate: selectedDate ?? this.selectedDate,
        visibleMonth: visibleMonth ?? this.visibleMonth,
        appointments: appointments ?? this.appointments,
        recurringTx: recurringTx ?? this.recurringTx,
        showAppointments: showAppointments ?? this.showAppointments,
        showTransactions: showTransactions ?? this.showTransactions,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        allDayAppointmentIds: allDayAppointmentIds ?? this.allDayAppointmentIds,
        ownerColors: ownerColors ?? this.ownerColors,
        memberProfiles: memberProfiles ?? this.memberProfiles,
        visibleUserIds:
            clearVisibleUserIds ? null : (visibleUserIds ?? this.visibleUserIds),
      );

  @override
  List<Object?> get props => [
        selectedDate,
        visibleMonth,
        appointments,
        recurringTx,
        showAppointments,
        showTransactions,
        loading,
        error,
        allDayAppointmentIds,
        ownerColors,
        memberProfiles,
        visibleUserIds,
      ];

  /// Filter helper for callers that already know the active user id.
  List<CalendarItem> itemsForDayFor(DateTime day, String? userId) {
    return visibleItemsFor(userId)
        .where((it) =>
            it.when.year == day.year &&
            it.when.month == day.month &&
            it.when.day == day.day)
        .toList();
  }
}

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final AppointmentRepository _appointmentRepo;
  final TransactionRepository _transactionRepo;
  final HouseholdRepository _householdRepo;
  String? _userId;
  String? _householdId;

  CalendarBloc({
    required AppointmentRepository appointmentRepository,
    required TransactionRepository transactionRepository,
    required HouseholdRepository householdRepository,
    DateTime? initialDate,
  })  : _appointmentRepo = appointmentRepository,
        _transactionRepo = transactionRepository,
        _householdRepo = householdRepository,
        super(CalendarState(
          selectedDate: _stripTime(initialDate ?? DateTime.now()),
          visibleMonth: DateTime(initialDate?.year ?? DateTime.now().year,
              initialDate?.month ?? DateTime.now().month),
        )) {
    on<CalendarLoad>(_onLoad);
    on<CalendarSelectDate>(_onSelectDate);
    on<CalendarToggleEventos>(_onToggleEventos);
    on<CalendarToggleMovimientos>(_onToggleMovimientos);
    on<CalendarMonthChanged>(_onMonthChanged);
    on<CalendarAppointmentAdded>(_onAppointmentAdded);
    on<CalendarAppointmentUpdated>(_onAppointmentUpdated);
    on<CalendarDeleteAppointment>(_onDeleteAppointment);
    on<CalendarMarkAllDay>(_onMarkAllDay);
    on<CalendarToggleUser>((e, emit) {
      final current = state.visibleUserIds ?? {};
      final next = current.contains(e.userId)
          ? current.difference({e.userId})
          : {...current, e.userId};
      // Always keep at least one user visible.
      if (next.isEmpty) return;
      emit(state.copyWith(visibleUserIds: next));
    });
    on<CalendarRefresh>(_onRefresh);
    on<CalendarGoogleSyncRequested>(_onGoogleSyncRequested);
  }

  Future<void> _onLoad(CalendarLoad e, Emitter<CalendarState> emit) async {
    _userId = e.userId;
    _householdId = e.householdId;
    emit(state.copyWith(
      loading: true,
      visibleMonth: DateTime(e.month.year, e.month.month),
      clearError: true,
    ));
    await _fetchOwnerColors(emit);
    await _fetch(emit);
  }

  Future<void> _fetchOwnerColors(Emitter<CalendarState> emit) async {
    final userId = _userId;
    if (userId == null) return;
    final (household, _) = await _householdRepo.getCurrentHousehold(userId);
    if (household == null) return;
    final (profiles, _) = await _householdRepo.getMemberProfiles(household.id);
    final colors = <String, String>{
      for (final p in profiles)
        if (p.calendarColor != null) p.id: p.calendarColor!,
    };
    // Default: show only the current user's items.
    final visible = state.visibleUserIds ?? {userId};
    emit(state.copyWith(
      ownerColors: colors,
      memberProfiles: profiles,
      visibleUserIds: visible,
    ));
  }

  Future<void> _fetch(Emitter<CalendarState> emit) async {
    final userId = _userId;
    final householdId = _householdId;
    if (userId == null || householdId == null) {
      emit(state.copyWith(loading: false));
      return;
    }
    final from = DateTime(state.visibleMonth.year, state.visibleMonth.month, 1)
        .subtract(const Duration(days: 7));
    final to =
        DateTime(state.visibleMonth.year, state.visibleMonth.month + 1, 1)
            .add(const Duration(days: 7));

    final (appts, apptFail) = await _appointmentRepo.getRange(
      userId: userId,
      from: from,
      to: to,
    );
    final (txs, txFail) = await _transactionRepo.getTransactions(
      householdId: householdId,
      viewMode: ViewMode.household,
      userId: userId,
      startDate: from,
      endDate: to,
      limit: 200,
    );

    emit(state.copyWith(
      loading: false,
      appointments: appts,
      recurringTx: txs.where((t) => t.isRecurring).toList(),
      error: apptFail?.message ?? txFail?.message,
    ));
  }

  Future<void> _onSelectDate(
      CalendarSelectDate e, Emitter<CalendarState> emit) async {
    emit(state.copyWith(selectedDate: _stripTime(e.date)));
  }

  Future<void> _onToggleEventos(
      CalendarToggleEventos e, Emitter<CalendarState> emit) async {
    emit(state.copyWith(showAppointments: !state.showAppointments));
  }

  Future<void> _onToggleMovimientos(
      CalendarToggleMovimientos e, Emitter<CalendarState> emit) async {
    emit(state.copyWith(showTransactions: !state.showTransactions));
  }

  Future<void> _onMonthChanged(
      CalendarMonthChanged e, Emitter<CalendarState> emit) async {
    final newMonth = DateTime(e.month.year, e.month.month);
    // Keep same day-of-month, clamped to last day of the new month.
    final lastDay = DateTime(e.month.year, e.month.month + 1, 0).day;
    final clampedDay = state.selectedDate.day.clamp(1, lastDay);
    final newSelected = DateTime(e.month.year, e.month.month, clampedDay);
    emit(state.copyWith(
      visibleMonth: newMonth,
      selectedDate: newSelected,
      loading: true,
    ));
    await _fetch(emit);
  }

  Future<void> _onAppointmentAdded(
      CalendarAppointmentAdded e, Emitter<CalendarState> emit) async {
    emit(state.copyWith(loading: true));
    await _fetch(emit);
  }

  Future<void> _onAppointmentUpdated(
      CalendarAppointmentUpdated e, Emitter<CalendarState> emit) async {
    emit(state.copyWith(loading: true));
    await _appointmentRepo.update(e.appointment);
    await _fetch(emit);
  }

  Future<void> _onDeleteAppointment(
      CalendarDeleteAppointment e, Emitter<CalendarState> emit) async {
    emit(state.copyWith(loading: true));
    await _appointmentRepo.delete(e.appointmentId);
    await _fetch(emit);
  }

  Future<void> _onRefresh(
      CalendarRefresh e, Emitter<CalendarState> emit) async {
    emit(state.copyWith(loading: true));
    await _fetch(emit);
  }

  Future<void> _onMarkAllDay(
      CalendarMarkAllDay e, Emitter<CalendarState> emit) async {
    emit(state.copyWith(
      allDayAppointmentIds: {...state.allDayAppointmentIds, e.appointmentId},
    ));
  }

  Future<void> _onGoogleSyncRequested(
      CalendarGoogleSyncRequested e, Emitter<CalendarState> emit) async {
    emit(state.copyWith(loading: true));
    await _appointmentRepo.syncWithGoogle(userId: e.userId);
    await _fetch(emit);
  }

  static DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);
}
