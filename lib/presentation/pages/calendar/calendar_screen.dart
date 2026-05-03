import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:hestia/domain/entities/appointment.dart';
// ignore: implementation_imports
import 'package:forui/src/widgets/line_calendar/line_calendar.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/calendar/calendar_bloc.dart';
import 'package:hestia/presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'package:hestia/presentation/widgets/calendar/appointment_form_content.dart';
import 'package:hestia/presentation/widgets/calendar/day_view.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Bell, Calendar, Plus;

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const _SignedOut();
    }
    final profile = auth.profile;

    return BlocProvider(
      create: (_) {
        final deps = AppDependencies.instance;
        return CalendarBloc(
          appointmentRepository: deps.appointmentRepository,
          transactionRepository: deps.transactionRepository,
        )..add(CalendarLoad(
            userId: profile.id,
            householdId: '',
            month: DateTime.now(),
          ));
      },
      child: _Body(userId: profile.id),
    );
  }
}

class _Body extends StatefulWidget {
  final String userId;
  const _Body({required this.userId});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final FCalendarController<DateTime?> _lineController;

  @override
  void initState() {
    super.initState();
    final today = _utc(DateTime.now());
    _lineController = FCalendarController.date(initialSelection: today);
    _lineController.addListener(_onLineControllerChanged);
  }

  void _onLineControllerChanged() {
    final d = _lineController.value;
    if (d == null) return;
    final local = DateTime(d.year, d.month, d.day);
    final bloc = context.read<CalendarBloc>();
    if (bloc.state.selectedDate != local) {
      bloc.add(CalendarSelectDate(local));
    }
  }

  @override
  void dispose() {
    _lineController.removeListener(_onLineControllerChanged);
    _lineController.dispose();
    super.dispose();
  }

  Future<void> _showMonthPicker(
      BuildContext context, CalendarState state) async {
    final theme = context.myTheme;
    final surface = _c(theme.surfaceColor);
    final fg = _c(theme.onBackgroundColor);
    final accent = _c(theme.primaryColor);
    final startDay = context.read<UserPrefsBloc>().state.startDay;
    DateTime selected = state.selectedDate;

    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) {
        final ctrl = FCalendarController.date(
          initialSelection: _utc(state.selectedDate),
        );
        final calStyle = FCalendarStyle.inherit(
          colorScheme: context.theme.colorScheme,
          typography: context.theme.typography,
          style: context.theme.style,
        ).copyWith(
          dayPickerStyle: FCalendarDayPickerStyle.inherit(
            colorScheme: context.theme.colorScheme,
            typography: context.theme.typography,
          ).copyWith(startDayOfWeek: startDay),
        );
        return Container(
          height: 420,
          color: surface,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Cancel',
                          style: AppFonts.body(fontSize: 15, color: fg)),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(selected),
                      child: Text('Done',
                          style: AppFonts.body(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: accent)),
                    ),
                  ],
                ),
                Expanded(
                  child: FCalendar(
                    controller: ctrl,
                    style: calStyle,
                    start: DateTime.utc(2020),
                    end: DateTime.utc(2035),
                    today: _utc(DateTime.now()),
                    initialMonth: _utc(state.visibleMonth),
                    onPress: (d) {
                      selected = DateTime(d.year, d.month, d.day);
                    },
                    onMonthChange: (d) {
                      selected = DateTime(d.year, d.month, d.day);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null && context.mounted) {
      context.read<CalendarBloc>().add(CalendarSelectDate(picked));
      context.read<CalendarBloc>().add(
            CalendarMonthChanged(DateTime(picked.year, picked.month)),
          );
      final utc = _utc(picked);
      if (_lineController.value != utc) {
        _lineController.select(utc);
      }
    }
  }

  DateTime _utc(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  void _openAddSheet(BuildContext context, DateTime defaultDate) {
    final prefs = context.read<UserPrefsBloc>().state;
    showAppBottomSheet<void>(
      context: context,
      title: 'New appointment',
      heightFactor: 0.92,
      expand: true,
      child: AppointmentFormContent(
        defaultDate: defaultDate,
        userId: widget.userId,
        use24h: prefs.use24h,
        startDayOfWeek: prefs.startDay,
        onSaved: (id, isAllDay) {
          if (isAllDay && id.isNotEmpty) {
            context.read<CalendarBloc>().add(CalendarMarkAllDay(id));
          }
          context.read<CalendarBloc>().add(const CalendarAppointmentAdded());
        },
      ),
    );
  }

  Future<void> _openAppointmentInfoSheet(
      BuildContext context, Appointment appointment) async {
    final title = TextEditingController(text: appointment.title);
    final notes = TextEditingController(text: appointment.notes ?? '');
    final theme = context.myTheme;
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);

    await showAppBottomSheet<void>(
      context: context,
      title: 'Appointment',
      child: StatefulBuilder(
        builder: (context, setLocalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: AppFonts.body(fontSize: 14, color: fg)),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      onPressed: () async {
                        final updated = appointment.copyWith(
                          title: title.text.trim().isEmpty
                              ? appointment.title
                              : title.text.trim(),
                          notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
                          lastUpdate: DateTime.now(),
                        );
                        await AppDependencies.instance.appointmentRepository
                            .update(updated);
                        if (!context.mounted) return;
                        context
                            .read<CalendarBloc>()
                            .add(const CalendarAppointmentAdded());
                        Navigator.of(context).pop();
                      },
                      child: Text('Done',
                          style: AppFonts.body(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: fg)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: title,
                  placeholder: 'Title',
                  style: AppFonts.body(fontSize: 14, color: fg),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  onChanged: (_) => setLocalState(() {}),
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  controller: notes,
                  minLines: 3,
                  maxLines: 5,
                  placeholder: 'Notes',
                  style: AppFonts.body(fontSize: 14, color: fg),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  onChanged: (_) => setLocalState(() {}),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${appointment.startsAt} · ${appointment.duration.inMinutes} min',
                    style: AppFonts.body(fontSize: 12, color: muted),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: () async {
                      final updated = appointment.copyWith(
                        title: title.text.trim().isEmpty
                            ? appointment.title
                            : title.text.trim(),
                        notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
                        lastUpdate: DateTime.now(),
                      );
                      await AppDependencies.instance.appointmentRepository
                          .update(updated);
                      if (!context.mounted) return;
                      context
                          .read<CalendarBloc>()
                          .add(const CalendarAppointmentAdded());
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    title.dispose();
    notes.dispose();
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: SizedBox.expand(
        child: BlocListener<CalendarBloc, CalendarState>(
        listenWhen: (p, n) => p.selectedDate != n.selectedDate,
        listener: (context, state) {
          final utc = _utc(state.selectedDate);
          if (_lineController.value != utc) {
            _lineController.select(utc);
          }
        },
        child: BlocBuilder<UserPrefsBloc, UserPrefsState>(
          builder: (context, prefs) => BlocBuilder<CalendarBloc, CalendarState>(
          buildWhen: (p, n) =>
              p.selectedDate != n.selectedDate ||
              p.appointments != n.appointments ||
              p.recurringTx != n.recurringTx ||
              p.showAppointments != n.showAppointments ||
              p.showTransactions != n.showTransactions ||
              p.visibleMonth != n.visibleMonth ||
              p.allDayAppointmentIds != n.allDayAppointmentIds,
          builder: (context, state) {
            final dayItems = state.itemsForDay(state.selectedDate);
            final dayAppts = dayItems.whereType<AppointmentItem>().toList();
            final dayTxs = dayItems.whereType<TransactionItem>().toList();

            return SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () {
                      final bloc = context.read<CalendarBloc>();
                      final completer = Completer<void>();
                      late StreamSubscription<CalendarState> sub;
                      sub = bloc.stream.listen((s) {
                        if (!s.loading) {
                          if (!completer.isCompleted) {
                            completer.complete();
                          }
                          sub.cancel();
                        }
                      });
                      bloc.add(CalendarRefresh());
                      return completer.future;
                    },
                  ),
                  SliverToBoxAdapter(
                    child: _FixedTopBar(
                      state: state,
                      lineController: _lineController,
                      fg: fg,
                      muted: muted,
                      accent: accent,
                      surface: surface,
                      border: border,
                      bg: bg,
                      onAddTap: () =>
                          _openAddSheet(context, state.selectedDate),
                      onMonthTap: () => _showMonthPicker(context, state),
                      onTodayTap: () {
                        final today = DateTime.now();
                        final local =
                            DateTime(today.year, today.month, today.day);
                        context
                            .read<CalendarBloc>()
                            .add(CalendarSelectDate(local));
                        context.read<CalendarBloc>().add(CalendarMonthChanged(
                            DateTime(local.year, local.month)));
                      },
                      onToggleAppointments: () => context
                          .read<CalendarBloc>()
                          .add(const CalendarToggleEventos()),
                      onToggleTransactions: () => context
                          .read<CalendarBloc>()
                          .add(const CalendarToggleMovimientos()),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.02, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: DayView(
                        key: ValueKey(state.selectedDate),
                        date: state.selectedDate,
                        appointments: dayAppts,
                        transactions: dayTxs,
                        showAppointments: state.showAppointments,
                        showTransactions: state.showTransactions,
                        allDayIds: state.allDayAppointmentIds,
                        use24h: prefs.use24h,
                        onTapSlot: (dt) => _openAddSheet(context, dt),
                        onTapAppointment: (a) =>
                            _openAppointmentInfoSheet(context, a),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        ),
      ),
      ),
    );
  }
}

// ── Fixed top bar ─────────────────────────────────────────────────────────────

class _FixedTopBar extends StatelessWidget {
  final CalendarState state;
  final FCalendarController<DateTime?> lineController;
  final Color fg;
  final Color muted;
  final Color accent;
  final Color surface;
  final Color border;
  final Color bg;
  final VoidCallback onAddTap;
  final VoidCallback onMonthTap;
  final VoidCallback onTodayTap;
  final VoidCallback onToggleAppointments;
  final VoidCallback onToggleTransactions;

  const _FixedTopBar({
    required this.state,
    required this.lineController,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.surface,
    required this.border,
    required this.bg,
    required this.onAddTap,
    required this.onMonthTap,
    required this.onTodayTap,
    required this.onToggleAppointments,
    required this.onToggleTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          // Title row + add button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'Calendar',
                      style: AppFonts.heading(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    Text(
                      _monthYear(state.visibleMonth),
                      style: AppFonts.body(fontSize: 13, color: muted),
                    ),
                  ],
                ),
              ),
              IconBtn(
                icon: Plus(width: 16, height: 16, color: fg),
                surface: surface,
                border: border,
                onTap: onAddTap,
                size: 36,
                radius: 10,
              ),
            ],
          ),
          // Month picker trigger
          Row(
            children: [
              GestureDetector(
                onTap: onMonthTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Text(
                      _monthYear(state.visibleMonth),
                      style: AppFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                    ChevronIcon(color: accent),
                  ],
                ),
              ),
              const Spacer(),
              CupertinoButton(
                minimumSize: const Size(44, 30),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: surface,
                onPressed: onTodayTap,
                child: Text('Today', style: AppFonts.body(fontSize: 12, color: fg)),
              ),
            ],
          ),
          // FLineCalendar — style must be passed explicitly (forui 0.7.0 bug: style! crashes if null)
          SizedBox(
            height: 84,
            child: FLineCalendar(
              controller: lineController,
              style: FLineCalendarStyle.inherit(
                colorScheme: context.theme.colorScheme,
                typography: context.theme.typography,
                style: context.theme.style,
              ),
              start: DateTime.utc(2020),
              end: DateTime.utc(2035),
              today: DateTime.utc(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ),
            ),
          ),
          // Filters
          _Filters(
            showAppointments: state.showAppointments,
            showTransactions: state.showTransactions,
            accent: accent,
            surface: surface,
            border: border,
            fg: fg,
            muted: muted,
            onToggleAppointments: onToggleAppointments,
            onToggleTransactions: onToggleTransactions,
          ),
        ],
      ),
    );
  }

  String _monthYear(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

// ── Filters ───────────────────────────────────────────────────────────────────

class _Filters extends StatelessWidget {
  final bool showAppointments;
  final bool showTransactions;
  final Color accent;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final VoidCallback onToggleAppointments;
  final VoidCallback onToggleTransactions;

  const _Filters({
    required this.showAppointments,
    required this.showTransactions,
    required this.accent,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.onToggleAppointments,
    required this.onToggleTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: _FilterChip(
            label: 'Eventos',
            icon: Calendar(
                width: 14,
                height: 14,
                color: showAppointments ? accent : muted),
            active: showAppointments,
            accent: accent,
            surface: surface,
            border: border,
            fg: fg,
            muted: muted,
            onTap: onToggleAppointments,
          ),
        ),
        Expanded(
          child: _FilterChip(
            label: 'Movimientos',
            icon: Bell(
                width: 14,
                height: 14,
                color: showTransactions ? accent : muted),
            active: showTransactions,
            accent: accent,
            surface: surface,
            border: border,
            fg: fg,
            muted: muted,
            onTap: onToggleTransactions,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool active;
  final Color accent;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.accent,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: active ? accent.withValues(alpha: 0.14) : surface,
          border: Border.all(
            color: active ? accent : border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            icon,
            Text(
              label,
              style: AppFonts.body(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? accent : muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── Signed out ────────────────────────────────────────────────────────────────

class _SignedOut extends StatelessWidget {
  const _SignedOut();

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = Color(int.parse(theme.backgroundColor.replaceFirst('#', '0xff')));
    final muted =
        Color(int.parse(theme.onInactiveColor.replaceFirst('#', '0xff')));
    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Center(
        child: Text(
          'Sign in to view calendar',
          style: AppFonts.body(fontSize: 14, color: muted),
        ),
      ),
    );
  }
}
