import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Calendar;

/// Horizontal scrollable week strip.
///
/// Shows Mon–Sun (or startDay preference) for the current week. Each day cell
/// displays event dots and opens an FPopover on tap with that day's items.
/// A "See all →" button at the trailing end pushes the calendar route.
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

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  String _dayLabel(DateTime d) {
    // 1=Mon → index 0, 7=Sun → index 6
    return _dayLabels[(d.weekday - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());

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
                        return FPopover.tappable(
                          followerBuilder: (ctx, _, __) => _DayPopover(
                            day: day,
                            appointments: appts,
                            transactions: txs,
                            accent: widget.accent,
                            fg: widget.fg,
                            muted: widget.muted,
                            surface: widget.surface,
                            income: widget.income,
                          ),
                          target: _DayCell(
                            day: day,
                            isToday: isToday,
                            hasAppt: appts.isNotEmpty,
                            hasTx: txs.isNotEmpty,
                            dayLabel: _dayLabel(day),
                            accent: widget.accent,
                            fg: widget.fg,
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
        // "See all →" sub-label
        GestureDetector(
          onTap: () => context.push(AppRoutes.calendarScreen),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                Calendar(width: 12, height: 12, color: widget.muted),
                Text(
                  'See all →',
                  style: AppFonts.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: widget.muted,
                    height: 1.0,
                  ),
                ),
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
  final bool hasAppt;
  final bool hasTx;
  final String dayLabel;
  final Color accent;
  final Color fg;
  final Color muted;
  final Color surface;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.hasAppt,
    required this.hasTx,
    required this.dayLabel,
    required this.accent,
    required this.fg,
    required this.muted,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 64,
      decoration: BoxDecoration(
        color: isToday ? accent.withValues(alpha: 0.12) : surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? accent.withValues(alpha: 0.5) : surface,
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
              color: muted,
              height: 1.0,
            ),
          ),
          Text(
            '${day.day}',
            style: AppFonts.body(
              fontSize: 16,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color: isToday ? accent : fg,
              height: 1.0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasAppt)
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
              if (hasAppt && hasTx) const SizedBox(width: 3),
              if (hasTx)
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CB782),
                    shape: BoxShape.circle,
                  ),
                ),
              if (!hasAppt && !hasTx) const SizedBox(width: 5, height: 5),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayPopover extends StatelessWidget {
  final DateTime day;
  final List<Appointment> appointments;
  final List<Transaction> transactions;
  final Color accent;
  final Color fg;
  final Color muted;
  final Color surface;
  final Color income;

  const _DayPopover({
    required this.day,
    required this.appointments,
    required this.transactions,
    required this.accent,
    required this.fg,
    required this.muted,
    required this.surface,
    required this.income,
  });

  @override
  Widget build(BuildContext context) {
    final hasAny = appointments.isNotEmpty || transactions.isNotEmpty;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280, maxHeight: 320),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _dayTitle(day),
            style: AppFonts.body(
                fontSize: 13, fontWeight: FontWeight.w700, color: fg),
          ),
          const SizedBox(height: 10),
          if (!hasAny)
            Text('No events', style: AppFonts.body(fontSize: 12, color: muted))
          else ...[
            for (final a in appointments) ...[
              _ApptRow(appt: a, accent: accent, fg: fg, muted: muted),
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

  static String _dayTitle(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

class _ApptRow extends StatelessWidget {
  final Appointment appt;
  final Color accent;
  final Color fg;
  final Color muted;

  const _ApptRow({
    required this.appt,
    required this.accent,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    final h = appt.startsAt.hour.toString().padLeft(2, '0');
    final m = appt.startsAt.minute.toString().padLeft(2, '0');
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
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
          '$h:$m',
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
