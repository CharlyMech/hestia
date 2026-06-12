import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/widgets/calendar/day_event_block.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Calendar, NavArrowRight, Plus;

/// Horizontal scrollable week strip.
///
/// Shows Mon–Sun (or startDay preference) for the current week. Each day cell
/// displays event dots and opens an FPopover on tap with that day's items.
/// A "View all" link switches to the Calendar tab in [MainTabShell].
class WeekCalendarStrip extends StatefulWidget {
  final List<Appointment> appointments;
  final List<Transaction> transactions;
  final Color accent;
  final Color fg;
  final Color muted;
  final Color surface;
  final Color income;
  final int startDay; // DateTime.monday = 1

  const WeekCalendarStrip({
    super.key,
    required this.appointments,
    required this.transactions,
    required this.accent,
    required this.fg,
    required this.muted,
    required this.surface,
    required this.income,
    this.startDay = DateTime.monday,
  });

  @override
  State<WeekCalendarStrip> createState() => _WeekCalendarStripState();
}

class _WeekCalendarStripState extends State<WeekCalendarStrip> {
  late final List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    _days = _weekDays(widget.startDay);
  }

  static List<DateTime> _weekDays(int startDay) {
    final today = _dateOnly(DateTime.now());
    // Find Monday of this week (or preferred start day)
    final dow = today.weekday; // 1=Mon..7=Sun
    final offset = (dow - startDay + 7) % 7;
    final weekStart = today.subtract(Duration(days: offset));
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static Color _apptColor(Appointment a, List<Color> categoryTints) {
    if (a.color != null) return hexToColor(a.color!);
    return categoryColor(a.category, categoryTints);
  }

  List<Appointment> _apptsForDay(DateTime day) => widget.appointments
      .where((a) =>
          a.startsAt.year == day.year &&
          a.startsAt.month == day.month &&
          a.startsAt.day == day.day)
      .toList();

  List<Transaction> _txForDay(DateTime day) => widget.transactions
      .where((t) =>
          t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day)
      .toList();

  static const _dayLabelsEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _dayLabelsEs = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  String _dayLabel(BuildContext context, DateTime d) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final labels = languageCode == 'es' ? _dayLabelsEs : _dayLabelsEn;
    // 1=Mon → index 0, 7=Sun → index 6
    return labels[(d.weekday - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final l10n = AppLocalizations.of(context);
    final categoryTints = context.myTheme.categoryTints.map(hexToColor).toList();
    final onPrimary = hexToColor(context.myTheme.onPrimaryColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Day cells — fill full width equally
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellW =
                  (constraints.maxWidth - 8 * 6) / 7; // 6 gaps between 7 cells
              return Row(
                children: [
                  for (var i = 0; i < _days.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    SizedBox(
                      width: cellW,
                      child: () {
                        final day = _days[i];
                        final isToday = day == today;
                        final appts = _apptsForDay(day);
                        final txs = _txForDay(day);
                        final apptColors = appts
                            .map((a) => _apptColor(a, categoryTints))
                            .toList();
                        return FPopover.tappable(
                          followerBuilder: (ctx, _, __) => _DayPopover(
                            day: day,
                            appointments: appts,
                            transactions: txs,
                            categoryTints: categoryTints,
                            fg: widget.fg,
                            muted: widget.muted,
                            income: widget.income,
                          ),
                          target: _DayCell(
                            day: day,
                            isToday: isToday,
                            appointmentColors: apptColors,
                            dayLabel: _dayLabel(context, day),
                            accent: widget.accent,
                            fg: widget.fg,
                            onPrimary: onPrimary,
                            muted: widget.muted,
                            surface: widget.surface,
                          ),
                        );
                      }(),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => context.push(AppRoutes.calendarScreen),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 4,
              children: [
                Calendar(width: 12, height: 12, color: widget.muted),
                Text(
                  l10n.common_viewAll,
                  style: AppFonts.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: widget.muted,
                    height: 1.0,
                  ),
                ),
                NavArrowRight(width: 12, height: 12, color: widget.muted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final List<Color> appointmentColors;
  final String dayLabel;
  final Color accent;
  final Color fg;
  final Color onPrimary;
  final Color muted;
  final Color surface;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.appointmentColors,
    required this.dayLabel,
    required this.accent,
    required this.fg,
    required this.onPrimary,
    required this.muted,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    // Today's cell is filled with the accent pill → its text must use
    // onPrimary so it reads on light themes.
    final dayNumColor = isToday ? onPrimary : fg;
    final labelFg = isToday ? onPrimary : muted;
    final visibleAppointmentColors = appointmentColors.take(3).toList();
    final hasMoreAppointments = appointmentColors.length > 3;
    final hasIndicators = appointmentColors.isNotEmpty;

    return Container(
      width: 44,
      height: 64,
      decoration: BoxDecoration(
        color: isToday ? accent : surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: isToday ? accent : surface,
          width: isToday ? 1.2 : 0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 4,
        children: [
          Text(
            dayLabel,
            style: AppFonts.body(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: labelFg,
              height: 1.0,
            ),
          ),
          Text(
            '${day.day}',
            style: AppFonts.body(
              fontSize: 16,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color: dayNumColor,
              height: 1.0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < visibleAppointmentColors.length; i++) ...[
                if (i > 0) const SizedBox(width: 3),
                _EventDot(color: visibleAppointmentColors[i], size: 5),
              ],
              if (hasMoreAppointments) ...[
                if (visibleAppointmentColors.isNotEmpty)
                  const SizedBox(width: 3),
                Plus(width: 6, height: 6, color: isToday ? onPrimary : accent),
              ],
              if (!hasIndicators) const SizedBox(width: 5, height: 5),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventDot extends StatelessWidget {
  final Color color;
  final double size;

  const _EventDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DayPopover extends StatelessWidget {
  final DateTime day;
  final List<Appointment> appointments;
  final List<Transaction> transactions;
  final List<Color> categoryTints;
  final Color fg;
  final Color muted;
  final Color income;

  const _DayPopover({
    required this.day,
    required this.appointments,
    required this.transactions,
    required this.categoryTints,
    required this.fg,
    required this.muted,
    required this.income,
  });

  String _localizedDayTitle(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dayName = DateFormat('EEE', locale).format(day);
    final dayNum = day.day;
    final month = DateFormat('MMMM', locale).format(day);
    if (locale.startsWith('es')) {
      return '$dayName, $dayNum de $month';
    }
    return '$dayName, $month $dayNum';
  }

  @override
  Widget build(BuildContext context) {
    final hasAny = appointments.isNotEmpty || transactions.isNotEmpty;
    final l10n = AppLocalizations.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 280, maxHeight: 320),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localizedDayTitle(context),
            style: AppFonts.body(
                fontSize: 13, fontWeight: FontWeight.w700, color: fg),
          ),
          const SizedBox(height: 10),
          if (!hasAny)
            Text(l10n.calendar_noEvents,
                style: AppFonts.body(fontSize: 12, color: muted))
          else ...[
            for (final a in appointments) ...[
              _ApptRow(
                appt: a,
                color: _WeekCalendarStripState._apptColor(a, categoryTints),
                allDayLabel: l10n.calendar_allDay,
                fg: fg,
                muted: muted,
              ),
              const SizedBox(height: 6),
            ],
            for (final t in transactions) ...[
              _TxMiniRow(tx: t, income: income, muted: muted, fg: fg),
              const SizedBox(height: 6),
            ],
          ],
        ],
      ),
    );
  }
}

class _ApptRow extends StatelessWidget {
  final Appointment appt;
  final Color color;
  final String allDayLabel;
  final Color fg;
  final Color muted;

  const _ApptRow({
    required this.appt,
    required this.color,
    required this.allDayLabel,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    final h = appt.startsAt.hour.toString().padLeft(2, '0');
    final m = appt.startsAt.minute.toString().padLeft(2, '0');
    final timeLabel = appt.isAllDay ? allDayLabel : '$h:$m';
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            appt.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(fontSize: 12, color: fg),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          timeLabel,
          style: AppFonts.numeric(fontSize: 11, color: muted),
        ),
      ],
    );
  }
}

class _TxMiniRow extends StatelessWidget {
  final Transaction tx;
  final Color income;
  final Color muted;
  final Color fg;

  const _TxMiniRow({
    required this.tx,
    required this.income,
    required this.muted,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.isIncome;
    final amtStr =
        '${isIncome ? '+' : '-'}€${tx.amount.abs().toStringAsFixed(2)}';
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: income,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            tx.note ?? tx.categoryName ?? 'Transaction',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(fontSize: 12, color: fg),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          amtStr,
          style: AppFonts.numeric(
            fontSize: 11,
            color: isIncome ? income : muted,
          ),
        ),
      ],
    );
  }
}
