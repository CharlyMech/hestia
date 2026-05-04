import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/repositories/appointment_repository.dart';
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

class CalendarToggleOnlyMine extends CalendarEvent {
  const CalendarToggleOnlyMine();
}

class CalendarState extends Equatable {
  final DateTime selectedDate;
  final DateTime visibleMonth;
  final List<Appointment> appointments;
  final List<Transaction> recurringTx;
  final bool showAppointments;
  final bool showTransactions;
  final bool onlyMine;
  final bool loading;
  final String? error;
  final Set<String> allDayAppointmentIds;

  const CalendarState({
    required this.selectedDate,
    required this.visibleMonth,
    this.appointments = const [],
    this.recurringTx = const [],
    this.showAppointments = true,
    this.showTransactions = true,
    this.onlyMine = false,
    this.loading = false,
    this.error,
    this.allDayAppointmentIds = const {},
  });

  /// All items in the visible month, post-filter.
  List<CalendarItem> visibleItemsFor(String? userId) {
    final items = <CalendarItem>[];
    final myId = userId;
    if (showAppointments) {
      var appts = appointments;
      if (onlyMine && myId != null) {
        appts = appts.where((a) => a.userId == myId).toList();
      }
      items.addAll(appts.map(AppointmentItem.new));
    }
    if (showTransactions) {
      var txs = recurringTx;
      if (onlyMine && myId != null) {
        txs = txs.where((t) => t.userId == myId).toList();
      }
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
    bool? onlyMine,
    bool? loading,
    String? error,
    bool clearError = false,
    Set<String>? allDayAppointmentIds,
  }) =>
      CalendarState(
        selectedDate: selectedDate ?? this.selectedDate,
        visibleMonth: visibleMonth ?? this.visibleMonth,
        appointments: appointments ?? this.appointments,
        recurringTx: recurringTx ?? this.recurringTx,
        showAppointments: showAppointments ?? this.showAppointments,
        showTransactions: showTransactions ?? this.showTransactions,
        onlyMine: onlyMine ?? this.onlyMine,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        allDayAppointmentIds: allDayAppointmentIds ?? this.allDayAppointmentIds,
      );

  @override
  List<Object?> get props => [
        selectedDate,
        visibleMonth,
        appointments,
        recurringTx,
        showAppointments,
        showTransactions,
        onlyMine,
        loading,
        error,
        allDayAppointmentIds,
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
  String? _userId;
  String? _householdId;

  CalendarBloc({
    required AppointmentRepository appointmentRepository,
    required TransactionRepository transactionRepository,
    DateTime? initialDate,
  })  : _appointmentRepo = appointmentRepository,
        _transactionRepo = transactionRepository,
        super(CalendarState(
          selectedDate: _stripTime(initialDate ?? DateTime.now()),
          visibleMonth:
              DateTime(initialDate?.year ?? DateTime.now().year,
                  initialDate?.month ?? DateTime.now().month),
        )) {
    on<CalendarLoad>(_onLoad);
    on<CalendarSelectDate>(_onSelectDate);
    on<CalendarToggleEventos>(_onToggleEventos);
    on<CalendarToggleMovimientos>(_onToggleMovimientos);
    on<CalendarMonthChanged>(_onMonthChanged);
    on<CalendarAppointmentAdded>(_onAppointmentAdded);
    on<CalendarMarkAllDay>(_onMarkAllDay);
    on<CalendarToggleOnlyMine>(
        (e, emit) => emit(state.copyWith(onlyMine: !state.onlyMine)));
    on<CalendarRefresh>(_onRefresh);
  }

  Future<void> _onLoad(CalendarLoad e, Emitter<CalendarState> emit) async {
    _userId = e.userId;
    _householdId = e.householdId;
    emit(state.copyWith(
      loading: true,
      visibleMonth: DateTime(e.month.year, e.month.month),
      clearError: true,
    ));
    await _fetch(emit);
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
    emit(state.copyWith(
      visibleMonth: DateTime(e.month.year, e.month.month),
      loading: true,
    ));
    await _fetch(emit);
  }

  Future<void> _onAppointmentAdded(
      CalendarAppointmentAdded e, Emitter<CalendarState> emit) async {
    emit(state.copyWith(loading: true));
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

  static DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);
}
