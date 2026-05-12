import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show MaterialLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/appointment.dart';
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
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Bell, Calendar, Plus, User;

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
  Map<String, String> _ownerColors = const {};

  @override
  void initState() {
    super.initState();
    _loadOwnerColors();
  }

  Future<void> _loadOwnerColors() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final deps = AppDependencies.instance;
    final (household, _) =
        await deps.householdRepository.getCurrentHousehold(auth.profile.id);
    if (household == null) return;
    final (profiles, _) =
        await deps.householdRepository.getMemberProfiles(household.id);
    if (!mounted) return;
    setState(() {
      _ownerColors = {
        for (final p in profiles)
          if (p.calendarColor != null) p.id: p.calendarColor!,
      };
    });
  }

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
                      child: Text('Cancel',
                          style: AppFonts.body(fontSize: 14, color: fg)),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      onPressed: () async {
                        final updated = appointment.copyWith(
                          title: title.text.trim().isEmpty
                              ? appointment.title
                              : title.text.trim(),
                          notes: notes.text.trim().isEmpty
                              ? null
                              : notes.text.trim(),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        notes: notes.text.trim().isEmpty
                            ? null
                            : notes.text.trim(),
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
    final income = _c(theme.colorGreen);
    final l10n = AppLocalizations.of(context);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: bg,
        border: Border(
          bottom: BorderSide(color: border.withValues(alpha: 0.5), width: 0.5),
        ),
        middle: Text(
          l10n.calendar_title,
          style: AppFonts.heading(
              fontSize: 17, fontWeight: FontWeight.w600, color: fg),
        ),
        trailing: GestureDetector(
          onTap: () {
            final state = context.read<CalendarBloc>().state;
            _openAddSheet(context, state.selectedDate);
          },
          behavior: HitTestBehavior.opaque,
          child: IconBtn(
            icon: Plus(width: 16, height: 16, color: fg),
            surface: surface,
            border: border,
            size: 32,
            radius: 9,
          ),
        ),
      ),
      child: BlocBuilder<UserPrefsBloc, UserPrefsState>(
        builder: (context, prefs) => BlocBuilder<CalendarBloc, CalendarState>(
          buildWhen: (p, n) =>
              p.selectedDate != n.selectedDate ||
              p.appointments != n.appointments ||
              p.recurringTx != n.recurringTx ||
              p.showAppointments != n.showAppointments ||
              p.showTransactions != n.showTransactions ||
              p.visibleMonth != n.visibleMonth ||
              p.allDayAppointmentIds != n.allDayAppointmentIds ||
              p.onlyMine != n.onlyMine,
          builder: (context, state) {
            final dayItems =
                state.itemsForDayFor(state.selectedDate, widget.userId);
            final dayAppts = dayItems.whereType<AppointmentItem>().toList();
            final dayTxs = dayItems.whereType<TransactionItem>().toList();

            return CustomScrollView(
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
                        if (!completer.isCompleted) completer.complete();
                        sub.cancel();
                      }
                    });
                    bloc.add(CalendarRefresh());
                    return completer.future;
                  },
                ),
                // Month grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _MonthGrid(
                      state: state,
                      userId: widget.userId,
                      startDayOfWeek: prefs.startDay,
                      surface: surface,
                      fg: fg,
                      muted: muted,
                      accent: accent,
                      income: income,
                      border: border,
                    ),
                  ),
                ),
                // Filters
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _Filters(
                      showAppointments: state.showAppointments,
                      showTransactions: state.showTransactions,
                      onlyMine: state.onlyMine,
                      accent: accent,
                      surface: surface,
                      border: border,
                      fg: fg,
                      muted: muted,
                      onToggleAppointments: () => context
                          .read<CalendarBloc>()
                          .add(const CalendarToggleEventos()),
                      onToggleTransactions: () => context
                          .read<CalendarBloc>()
                          .add(const CalendarToggleMovimientos()),
                      onToggleOnlyMine: () => context
                          .read<CalendarBloc>()
                          .add(const CalendarToggleOnlyMine()),
                    ),
                  ),
                ),
                // Day view
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
                      ownerColors: _ownerColors,
                      onTapSlot: (dt) => _openAddSheet(context, dt),
                      onTapAppointment: (a) =>
                          _openAppointmentInfoSheet(context, a),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Inline month grid ─────────────────────────────────────────────────────────

class _MonthGrid extends StatefulWidget {
  final CalendarState state;
  final String userId;
  final int startDayOfWeek;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color accent;
  final Color income;
  final Color border;

  const _MonthGrid({
    required this.state,
    required this.userId,
    required this.startDayOfWeek,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.income,
    required this.border,
  });

  @override
  State<_MonthGrid> createState() => _MonthGridState();
}

class _MonthGridState extends State<_MonthGrid> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _viewMonth = DateTime(
      widget.state.visibleMonth.year,
      widget.state.visibleMonth.month,
    );
  }

  void _shiftMonth(int delta) {
    final n = DateTime(_viewMonth.year, _viewMonth.month + delta);
    setState(() => _viewMonth = n);
    context.read<CalendarBloc>().add(CalendarMonthChanged(n));
  }

  static int _leadingBlanks(DateTime firstOfMonth, int startDay) {
    final wd = firstOfMonth.weekday % 7;
    final sd = startDay % 7;
    return (wd - sd + 7) % 7;
  }

  static List<DateTime?> _cellsForMonth(DateTime month, int startDay) {
    final first = DateTime(month.year, month.month, 1);
    final lead = _leadingBlanks(first, startDay);
    final dim = DateTime(month.year, month.month + 1, 0).day;
    final out = <DateTime?>[];
    for (var i = 0; i < lead; i++) {
      out.add(null);
    }
    for (var d = 1; d <= dim; d++) {
      out.add(DateTime(month.year, month.month, d));
    }
    while (out.length % 7 != 0) {
      out.add(null);
    }
    return out;
  }

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthTitle = DateFormat.yMMMM(locale).format(_viewMonth);
    final loc = MaterialLocalizations.of(context);
    final state = widget.state;
    final today = _dayOnly(DateTime.now());
    final selected = _dayOnly(state.selectedDate);
    final cells = _cellsForMonth(_viewMonth, widget.startDayOfWeek);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cell =
            (constraints.maxWidth / DateTime.daysPerWeek).clamp(44.0, 64.0);
        final cellH = cell * 1.12;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Month navigation header
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: state.loading ? null : () => _shiftMonth(-1),
                    child: Icon(
                      CupertinoIcons.chevron_back,
                      size: 20,
                      color: state.loading ? widget.muted : widget.fg,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      monthTitle,
                      textAlign: TextAlign.center,
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: widget.accent,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: state.loading ? null : () => _shiftMonth(1),
                    child: Icon(
                      CupertinoIcons.chevron_forward,
                      size: 20,
                      color: state.loading ? widget.muted : widget.fg,
                    ),
                  ),
                ],
              ),
            ),
            // Weekday headers
            Row(
              children: List.generate(7, (col) {
                final w = ((widget.startDayOfWeek - 1 + col) % 7) + 1;
                final idx = w % 7;
                return SizedBox(
                  width: cell,
                  child: Center(
                    child: Text(
                      loc.narrowWeekdays[idx],
                      style: AppFonts.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.muted,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            if (state.loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: CupertinoActivityIndicator(color: widget.accent),
                ),
              ),
            // Day grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: cellH,
              ),
              itemCount: cells.length,
              itemBuilder: (context, i) {
                final day = cells[i];
                if (day == null) {
                  return SizedBox(width: cell, height: cellH);
                }
                final inMonth = day.month == _viewMonth.month;
                final items = state.itemsForDayFor(day, widget.userId);
                final hasAppt = items.any((e) => e is AppointmentItem);
                final hasTx = items.any((e) => e is TransactionItem);
                final isToday = _dayOnly(day) == today;
                final isSelected = _dayOnly(day) == selected;
                final dOnly = _dayOnly(day);
                final isPast = dOnly.isBefore(today);
                final isFuture = dOnly.isAfter(today);

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.read<CalendarBloc>().add(CalendarSelectDate(day));
                    if (day.month != _viewMonth.month) {
                      final newMonth = DateTime(day.year, day.month);
                      setState(() => _viewMonth = newMonth);
                      context
                          .read<CalendarBloc>()
                          .add(CalendarMonthChanged(newMonth));
                    }
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.accent.withValues(alpha: 0.12)
                          : widget.surface,
                      border: Border.all(
                        color: isToday
                            ? widget.accent.withValues(alpha: 0.55)
                            : isSelected
                                ? widget.accent.withValues(alpha: 0.4)
                                : const Color(0x00000000),
                        width: (isToday || isSelected) ? 1.4 : 0.6,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: !inMonth
                                ? widget.muted.withValues(alpha: 0.4)
                                : isSelected
                                    ? widget.accent
                                    : widget.fg,
                          ),
                        ),
                        SizedBox(height: cell * 0.06),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasAppt)
                              _EventDot(
                                color: widget.accent,
                                dim: isPast ? 0.45 : (isFuture ? 0.85 : 1.0),
                              ),
                            if (hasAppt && hasTx) const SizedBox(width: 3),
                            if (hasTx)
                              _EventDot(
                                color: widget.income,
                                dim: isPast ? 0.45 : (isFuture ? 0.85 : 1.0),
                              ),
                            if (!hasAppt && !hasTx)
                              SizedBox(height: cell * 0.1),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _EventDot extends StatelessWidget {
  final Color color;
  final double dim;

  const _EventDot({required this.color, required this.dim});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dim.clamp(0.2, 1.0),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

// ── Filters ───────────────────────────────────────────────────────────────────

class _Filters extends StatelessWidget {
  final bool showAppointments;
  final bool showTransactions;
  final bool onlyMine;
  final Color accent;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final VoidCallback onToggleAppointments;
  final VoidCallback onToggleTransactions;
  final VoidCallback onToggleOnlyMine;

  const _Filters({
    required this.showAppointments,
    required this.showTransactions,
    required this.onlyMine,
    required this.accent,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.onToggleAppointments,
    required this.onToggleTransactions,
    required this.onToggleOnlyMine,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: _FilterChip(
            label: 'Events',
            icon: Calendar(
                width: 13,
                height: 13,
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
            label: 'Transactions',
            icon: Bell(
                width: 13,
                height: 13,
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
        Expanded(
          child: _FilterChip(
            label: 'Only mine',
            icon: User(width: 13, height: 13, color: onlyMine ? accent : muted),
            active: onlyMine,
            accent: accent,
            surface: surface,
            border: border,
            fg: fg,
            muted: muted,
            onTap: onToggleOnlyMine,
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
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
        decoration: BoxDecoration(
          color: active ? accent.withValues(alpha: 0.14) : surface,
          border: Border.all(
            color: active ? accent : const Color(0x00000000),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 6,
          children: [
            icon,
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? accent : muted,
                ),
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
    final bg =
        Color(int.parse(theme.backgroundColor.replaceFirst('#', '0xff')));
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
