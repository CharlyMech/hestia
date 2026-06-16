import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show MaterialLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/calendar/calendar_bloc.dart';
import 'package:hestia/presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'package:hestia/presentation/widgets/appointments/appointment_sheet_form.dart';
import 'package:hestia/presentation/widgets/calendar/day_view.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/layout/cupertino_pushed_route_shell.dart';

import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show
        Bell,
        Calendar,
        Plus,
        NavArrowLeft,
        NavArrowRight,
        ArrowSeparateVertical,
        ArrowUnionVertical;

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
          householdRepository: deps.householdRepository,
          petRepository: deps.petRepository,
          carRepository: deps.carRepository,
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

class _Body extends StatelessWidget {
  final String userId;
  const _Body({required this.userId});

  void _openAddSheet(BuildContext context, DateTime defaultDate) {
    final prefs = context.read<UserPrefsBloc>().state;
    showAppBottomSheet<void>(
      context: context,
      title: AppLocalizations.of(context).calendar_newAppointment,
      child: AppointmentSheetForm(
        defaultDate: defaultDate,
        userId: userId,
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

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final income = hexToColor(theme.colorGreen);
    final primary = hexToColor(theme.primaryColor);
    final onPrimary = hexToColor(theme.onPrimaryColor);
    final l10n = AppLocalizations.of(context);

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: l10n.calendar_title,
      // Caller owns the scroll view (custom CustomScrollView with its own
      // refresh control + Skeletonizer driven by the inner CalendarBloc state).
      childIsScrollable: true,
      trailing: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            // Today-jump button: only visible when the selected date is not today.
            BlocSelector<CalendarBloc, CalendarState, bool>(
              selector: (s) {
                final today = DateTime.now();
                final sel = s.selectedDate;
                return sel.year == today.year &&
                    sel.month == today.month &&
                    sel.day == today.day;
              },
              builder: (context, isToday) => AnimatedOpacity(
                opacity: isToday ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: isToday,
                  child: AnimatedButton(
                    size: 32,
                    padding: const EdgeInsets.all(4),
                    onTap: () {
                      final today = DateTime.now();
                      final bloc = context.read<CalendarBloc>();
                      bloc.add(CalendarSelectDate(today));
                      bloc.add(CalendarMonthChanged(
                          DateTime(today.year, today.month)));
                    },
                    child: Calendar(width: 20, height: 20, color: fg),
                  ),
                ),
              ),
            ),
            AnimatedButton(
              size: 32,
              padding: const EdgeInsets.all(4),
              backgroundColor: primary,
              onTap: () {
                final state = context.read<CalendarBloc>().state;
                _openAddSheet(context, state.selectedDate);
              },
              child: Plus(width: 22, height: 22, color: onPrimary),
            ),
          ],
        ),
      ),
      child: BlocBuilder<UserPrefsBloc, UserPrefsState>(
        builder: (context, prefs) => BlocBuilder<CalendarBloc, CalendarState>(
          buildWhen: (p, n) =>
              p.loading != n.loading ||
              p.selectedDate != n.selectedDate ||
              p.appointments != n.appointments ||
              p.recurringTx != n.recurringTx ||
              p.showAppointments != n.showAppointments ||
              p.showTransactions != n.showTransactions ||
              p.visibleMonth != n.visibleMonth ||
              p.allDayAppointmentIds != n.allDayAppointmentIds ||
              p.visibleUserIds != n.visibleUserIds ||
              p.memberProfiles != n.memberProfiles ||
              p.ownerColors != n.ownerColors ||
              p.filterPetIds != n.filterPetIds ||
              p.filterCarIds != n.filterCarIds ||
              p.availablePets != n.availablePets ||
              p.availableCars != n.availableCars,
          builder: (context, state) {
            final dayItems = state.itemsForDayFor(state.selectedDate, userId);
            final dayAppts = dayItems.whereType<AppointmentItem>().toList();
            final dayTxs = dayItems.whereType<TransactionItem>().toList();

            return Skeletonizer(
              enabled: state.loading,
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
                        userId: userId,
                        startDayOfWeek: prefs.startDay,
                        surface: surface,
                        fg: fg,
                        onPrimary: onPrimary,
                        muted: muted,
                        accent: accent,
                        income: income,
                        border: border,
                      ),
                    ),
                  ),
                  // Filter row
                  SliverToBoxAdapter(
                    child: _FilterRow(
                      state: state,
                      accent: accent,
                      fg: fg,
                      muted: muted,
                      surface: surface,
                      border: border,
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
                        ownerColors: state.ownerColors,
                        onTapSlot: (dt) => _openAddSheet(context, dt),
                        // Read-first: open the detail screen (it has an Edit
                        // affordance) rather than an inline edit form.
                        onTapAppointment: (a) =>
                            context.push(AppRoutes.appointmentDetail, extra: a),
                      ),
                    ),
                  ),
                ],
              ),
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
  final Color onPrimary;
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
    required this.onPrimary,
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
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _viewMonth = DateTime(
      widget.state.visibleMonth.year,
      widget.state.visibleMonth.month,
    );
  }

  @override
  void didUpdateWidget(_MonthGrid old) {
    super.didUpdateWidget(old);
    // Follow external month changes (e.g. the "today" action in the app bar).
    final vm = widget.state.visibleMonth;
    if (vm.year != _viewMonth.year || vm.month != _viewMonth.month) {
      _viewMonth = DateTime(vm.year, vm.month);
    }
  }

  List<DateTime?> _visibleCells(List<DateTime?> all, DateTime selected) {
    if (_expanded) return all;
    final sel = _dayOnly(selected);
    for (var row = 0; row < all.length; row += 7) {
      final week = all.sublist(row, row + 7);
      if (week.any((d) => d != null && _dayOnly(d) == sel)) return week;
    }
    return all.take(7).toList();
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
    final allCells = _cellsForMonth(_viewMonth, widget.startDayOfWeek);
    final cells = _visibleCells(allCells, state.selectedDate);
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cell =
            (constraints.maxWidth / DateTime.daysPerWeek).clamp(42.0, 64.0);
        final cellH = cell;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                spacing: 8,
                children: [
                  AnimatedButton(
                    padding: EdgeInsets.all(6),
                    backgroundColor: surface,
                    onTap: state.loading ? null : () => _shiftMonth(-1),
                    child: NavArrowLeft(
                      width: 24,
                      height: 24,
                      color: state.loading ? widget.muted : widget.fg,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.surface,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  ),
                  AnimatedButton(
                    padding: EdgeInsets.all(6),
                    backgroundColor: surface,
                    onTap: state.loading ? null : () => _shiftMonth(1),
                    child: NavArrowRight(
                      width: 24,
                      height: 24,
                      color: state.loading ? widget.muted : widget.fg,
                    ),
                  ),
                  AnimatedButton(
                    padding: EdgeInsets.all(6),
                    backgroundColor: surface,
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: _expanded
                        ? ArrowUnionVertical(
                            width: 24, height: 24, color: widget.fg)
                        : ArrowSeparateVertical(
                            width: 24, height: 24, color: widget.fg),
                  ),
                ],
              ),
            ),
            Row(
              children: List.generate(7, (col) {
                final w = ((widget.startDayOfWeek - 1 + col) % 7) + 1;
                final idx = w % 7;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: cellH,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: cells.length,
                itemBuilder: (context, i) {
                  final day = cells[i];
                  if (day == null) {
                    return SizedBox(width: cell, height: cellH);
                  }
                  final inMonth = day.month == _viewMonth.month;
                  final items = state.itemsForDayFor(day, widget.userId);
                  final appts = items
                      .whereType<AppointmentItem>()
                      .map((e) => e.appointment)
                      .toList();
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
                        // Transparent fill (except the selected highlight) with
                        // a visible border outline on every cell.
                        color: isSelected
                            ? widget.accent
                            : widget.surface.withValues(alpha: 0.6),
                        border: Border.all(
                          color: isToday
                              ? widget.accent.withValues(alpha: 0.55)
                              : isSelected
                                  ? widget.accent.withValues(alpha: 0.4)
                                  : widget.border,
                          width: (isToday || isSelected) ? 1.4 : 0.8,
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
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? widget.onPrimary
                                  : !inMonth
                                      ? widget.muted.withValues(alpha: 0.2)
                                      : widget.fg,
                            ),
                          ),
                          SizedBox(height: cell * 0.06),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var j = 0;
                                  j < appts.length.clamp(0, 3);
                                  j++) ...[
                                if (j > 0) const SizedBox(width: 2),
                                _EventDot(
                                  color: appts[j].color != null
                                      ? hexToColor(appts[j].color!)
                                      : widget.accent,
                                  dim: isPast ? 0.45 : (isFuture ? 0.85 : 1.0),
                                ),
                              ],
                              if (appts.isNotEmpty && hasTx)
                                const SizedBox(width: 3),
                              if (hasTx)
                                _EventDot(
                                  color: widget.income,
                                  dim: isPast ? 0.45 : (isFuture ? 0.85 : 1.0),
                                ),
                              if (appts.isEmpty && !hasTx)
                                SizedBox(height: cell * 0.1),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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

// ── Filter row (replaces inline filter chips) ─────────────────────────────────

class _FilterRow extends StatelessWidget {
  final CalendarState state;
  final Color accent, fg, muted, surface, border;

  const _FilterRow({
    required this.state,
    required this.accent,
    required this.fg,
    required this.muted,
    required this.surface,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = state.activeFilterCount;
    final hasFilters = state.hasActiveFilters;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedButton(
            onTap: () => _openSheet(context),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            backgroundColor:
                hasFilters ? accent.withValues(alpha: 0.12) : surface,
            borderColor: hasFilters ? accent : border,
            borderWidth: hasFilters ? 1.2 : 0.8,
            borderRadius: AppRadii.full,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                if (count > 0)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: AppFonts.body(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: fg,
                        height: 1,
                      ),
                    ),
                  ),
                Text(
                  l10n.calendar_showFilters,
                  style: AppFonts.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: hasFilters ? accent : muted,
                  ),
                ),
              ],
            ),
          ),
          if (hasFilters) ...[
            const Spacer(),
            AnimatedButton(
              onTap: () => context
                  .read<CalendarBloc>()
                  .add(const CalendarClearFilters()),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              borderRadius: AppRadii.full,
              child: Text(
                l10n.calendar_clearFilters,
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: muted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openSheet(BuildContext context) {
    final bloc = context.read<CalendarBloc>();
    showAppBottomSheet(
      context: context,
      title: AppLocalizations.of(context).calendar_filters,
      child: BlocProvider.value(
        value: bloc,
        child: _CalendarFilterSheet(
          accent: accent,
          fg: fg,
          muted: muted,
          surface: surface,
          border: border,
        ),
      ),
    );
  }
}

// ── Filter sheet content ──────────────────────────────────────────────────────

class _CalendarFilterSheet extends StatelessWidget {
  final Color accent, fg, muted, surface, border;

  const _CalendarFilterSheet({
    required this.accent,
    required this.fg,
    required this.muted,
    required this.surface,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        final bloc = context.read<CalendarBloc>();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              // ── Type ──────────────────────────────────────────────────────
              _SheetSection(
                label: l10n.calendar_filterType,
                fg: fg,
                muted: muted,
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: _ToggleChip(
                        label: l10n.calendar_eventos,
                        icon: Calendar(
                            width: 13,
                            height: 13,
                            color: state.showAppointments ? accent : muted),
                        active: state.showAppointments,
                        accent: accent,
                        surface: surface,
                        border: border,
                        muted: muted,
                        onTap: () => bloc.add(const CalendarToggleEventos()),
                      ),
                    ),
                    Expanded(
                      child: _ToggleChip(
                        label: l10n.calendar_movimientos,
                        icon: Bell(
                            width: 13,
                            height: 13,
                            color: state.showTransactions ? accent : muted),
                        active: state.showTransactions,
                        accent: accent,
                        surface: surface,
                        border: border,
                        muted: muted,
                        onTap: () =>
                            bloc.add(const CalendarToggleMovimientos()),
                      ),
                    ),
                  ],
                ),
              ),

              // ── People ────────────────────────────────────────────────────
              if (state.memberProfiles.length > 1)
                _SheetSection(
                  label: l10n.calendar_filterPeople,
                  fg: fg,
                  muted: muted,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in state.memberProfiles)
                        _MemberChip(
                          profile: p,
                          active: state.visibleUserIds == null ||
                              state.visibleUserIds!.contains(p.id),
                          ownerColor: state.ownerColors[p.id] != null
                              ? hexToColor(state.ownerColors[p.id]!)
                              : accent,
                          surface: surface,
                          border: border,
                          muted: muted,
                          onTap: () => bloc.add(CalendarToggleUser(p.id)),
                        ),
                    ],
                  ),
                ),

              // ── Pets ──────────────────────────────────────────────────────
              if (state.availablePets.isNotEmpty)
                _SheetSection(
                  label: l10n.calendar_filterPets,
                  fg: fg,
                  muted: muted,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final pet in state.availablePets)
                        _ToggleChip(
                          label: pet.name,
                          active: state.filterPetIds.contains(pet.id),
                          accent: accent,
                          surface: surface,
                          border: border,
                          muted: muted,
                          onTap: () => bloc.add(CalendarTogglePet(pet.id)),
                        ),
                    ],
                  ),
                ),

              // ── Cars ──────────────────────────────────────────────────────
              if (state.availableCars.isNotEmpty)
                _SheetSection(
                  label: l10n.calendar_filterVehicles,
                  fg: fg,
                  muted: muted,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final car in state.availableCars)
                        _ToggleChip(
                          label: car.name,
                          active: state.filterCarIds.contains(car.id),
                          accent: accent,
                          surface: surface,
                          border: border,
                          muted: muted,
                          onTap: () => bloc.add(CalendarToggleCar(car.id)),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetSection extends StatelessWidget {
  final String label;
  final Widget child;
  final Color fg, muted;

  const _SheetSection({
    required this.label,
    required this.child,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          label.toUpperCase(),
          style: AppFonts.body(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: muted,
            letterSpacing: 0.8,
          ),
        ),
        child,
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final Widget? icon;
  final bool active;
  final Color accent, surface, border, muted;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.active,
    required this.accent,
    required this.surface,
    required this.border,
    required this.muted,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
        decoration: BoxDecoration(
          color: active ? accent.withValues(alpha: 0.14) : surface,
          border: Border.all(
            color: active ? accent : border,
            width: active ? 1.2 : 0.8,
          ),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 6,
          children: [
            if (icon != null) icon!,
            Text(
              label,
              style: AppFonts.body(
                fontSize: 12,
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

class _MemberChip extends StatelessWidget {
  final Profile profile;
  final bool active;
  final Color ownerColor;
  final Color surface;
  final Color border;
  final Color muted;
  final VoidCallback onTap;

  const _MemberChip({
    required this.profile,
    required this.active,
    required this.ownerColor,
    required this.surface,
    required this.border,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName ?? profile.email;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final chipColor = ownerColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? chipColor.withValues(alpha: 0.14) : surface,
          border: Border.all(
            color: active ? chipColor : border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: active ? 1.0 : 0.4),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: AppFonts.body(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                  height: 1.0,
                ),
              ),
            ),
            Text(
              name,
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? chipColor : muted,
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
    final bg = hexToColor(theme.backgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Center(
        child: Text(
          AppLocalizations.of(context).profile_signInPrompt,
          style: AppFonts.body(fontSize: 14, color: muted),
        ),
      ),
    );
  }
}
