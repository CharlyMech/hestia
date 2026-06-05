import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/calendar/calendar_bloc.dart';
import 'package:hestia/presentation/widgets/calendar/day_event_block.dart';
import 'package:hestia/presentation/widgets/calendar/day_view_layout.dart';

const double _hourHeight = 64.0;
const double _timeColWidth = 52.0;
const double _totalGridHeight = 24 * _hourHeight; // 1536

class DayView extends StatefulWidget {
  final DateTime date;
  final List<AppointmentItem> appointments;
  final List<TransactionItem> transactions;
  final bool showAppointments;
  final bool showTransactions;
  final Set<String> allDayIds;
  final ValueChanged<DateTime> onTapSlot;
  final ValueChanged<Appointment> onTapAppointment;
  final bool use24h;
  final double bottomPadding;
  final Future<void> Function()? onRefresh;

  /// Map of `userId` → hex color used to tint appointment blocks by owner
  /// instead of by category. Falls back to category tints when missing.
  final Map<String, String> ownerColors;

  const DayView({
    super.key,
    required this.date,
    required this.appointments,
    required this.transactions,
    required this.showAppointments,
    required this.showTransactions,
    required this.allDayIds,
    required this.onTapSlot,
    required this.onTapAppointment,
    this.use24h = true,
    this.bottomPadding = 110,
    this.onRefresh,
    this.ownerColors = const {},
  });

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
  }

  void _scrollToNow() {
    if (!_scrollController.hasClients) return;
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    final offset =
        (minutes / 60.0 * _hourHeight - 200).clamp(0.0, _totalGridHeight);
    _scrollController.jumpTo(offset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final border = hexToColor(theme.borderColor);
    final surface = hexToColor(theme.surfaceColor);
    final tints = theme.categoryTints
        .map((h) => Color(int.parse(h.replaceFirst('#', '0xff'))))
        .toList();

    final visibleAppts = widget.showAppointments
        ? widget.appointments.map((i) => i.appointment).toList()
        : <Appointment>[];

    final positionedEvents = resolveLayout(visibleAppts, widget.allDayIds);

    final allDayAppts = widget.showAppointments
        ? widget.appointments
            .where((i) =>
                isAllDayAppointment(i.appointment) ||
                widget.allDayIds.contains(i.id))
            .toList()
        : <AppointmentItem>[];

    final visibleTx =
        widget.showTransactions ? widget.transactions : <TransactionItem>[];

    final isToday = _sameDay(widget.date, DateTime.now());

    return Column(
      children: [
        _AllDayOverlay(
          appointments: allDayAppts,
          transactions: visibleTx,
          accent: accent,
          categoryTints: tints,
          surface: surface,
          border: border,
          fg: fg,
          muted: muted,
          onTapAppointment: widget.onTapAppointment,
          onLongPressAppointment: _confirmDelete,
        ),
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              if (widget.onRefresh != null)
                CupertinoSliverRefreshControl(onRefresh: widget.onRefresh),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: _totalGridHeight + widget.bottomPadding,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final laneWidth = constraints.maxWidth - _timeColWidth;
                      return Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: _HourGrid(
                              fg: fg,
                              muted: muted,
                              border: border,
                              use24h: widget.use24h,
                            ),
                          ),
                          Positioned(
                            left: _timeColWidth,
                            top: 0,
                            width: laneWidth,
                            height: _totalGridHeight,
                            child: _TapLayer(
                              date: widget.date,
                              onTapSlot: widget.onTapSlot,
                            ),
                          ),
                          Positioned(
                            left: _timeColWidth,
                            top: 0,
                            width: laneWidth,
                            height: _totalGridHeight,
                            child: IgnorePointer(
                              ignoring: !widget.showAppointments,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutCubic,
                                opacity: widget.showAppointments ? 1 : 0,
                                child: Stack(
                                  children: [
                                    for (final e in positionedEvents)
                                      Positioned(
                                        top: e.topOffset(_hourHeight),
                                        left: e.columnIndex /
                                            e.totalColumns *
                                            laneWidth,
                                        width: laneWidth / e.totalColumns,
                                        height: e.blockHeight(_hourHeight),
                                        child: TweenAnimationBuilder<double>(
                                          key: ValueKey(
                                              '${e.appointment.id}-${widget.showAppointments}'),
                                          tween: Tween(begin: 0.95, end: 1),
                                          duration:
                                              const Duration(milliseconds: 240),
                                          curve: Curves.easeOutBack,
                                          builder: (context, scale, child) =>
                                              Transform.scale(
                                            scale: scale,
                                            alignment: Alignment.topCenter,
                                            child: child,
                                          ),
                                          child: DayEventBlock(
                                            event: e,
                                            hourHeight: _hourHeight,
                                            color: _ownerOrCategoryColor(
                                                e.appointment, tints),
                                            onTap: () =>
                                                widget.onTapAppointment(
                                                    e.appointment),
                                            onLongPress: () =>
                                                _confirmDelete(
                                                    context, e.appointment),
                                            use24h: widget.use24h,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (isToday)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: _totalGridHeight,
                              child:
                                  Stack(children: [_NowLine(accent: accent)]),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Color _ownerOrCategoryColor(Appointment a, List<Color> tints) {
    if (a.color != null) return hexToColor(a.color!);
    final ownerHex = widget.ownerColors[a.userId];
    if (ownerHex != null) return hexToColor(ownerHex);
    return categoryColor(a.category, tints);
  }

  void _confirmDelete(BuildContext context, Appointment appointment) {
    final l10n = AppLocalizations.of(context);
    showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(l10n.calendar_deleteEvent),
        content: Text(l10n.calendar_deleteEventConfirm),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.common_delete),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context
            .read<CalendarBloc>()
            .add(CalendarDeleteAppointment(appointment.id));
      }
    });
  }
}

// ── Hour grid ────────────────────────────────────────────────────────────────

class _HourGrid extends StatelessWidget {
  final Color fg;
  final Color muted;
  final Color border;
  final bool use24h;

  const _HourGrid({
    required this.fg,
    required this.muted,
    required this.border,
    required this.use24h,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _totalGridHeight,
      child: Column(
        children: List.generate(24, (hour) {
          return SizedBox(
            height: _hourHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _timeColWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, right: 8),
                    child: Text(
                      _label(hour),
                      textAlign: TextAlign.right,
                      style: AppFonts.body(fontSize: 10, color: muted),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: border, width: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _label(int hour) {
    if (use24h) return '${hour.toString().padLeft(2, '0')}:00';
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}

// ── Tap layer ────────────────────────────────────────────────────────────────

class _TapLayer extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onTapSlot;

  const _TapLayer({required this.date, required this.onTapSlot});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: (details) {
        final minute = (details.localPosition.dy / _hourHeight * 60).floor();
        final snapped = (minute ~/ 15) * 15;
        final hour = snapped ~/ 60;
        final min = snapped % 60;
        onTapSlot(DateTime(date.year, date.month, date.day, hour, min));
      },
    );
  }
}

// ── Now indicator ────────────────────────────────────────────────────────────

class _NowLine extends StatelessWidget {
  final Color accent;

  const _NowLine({required this.accent});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    final top = minutes / 60.0 * _hourHeight;

    return Positioned(
      top: top - 1,
      left: _timeColWidth - 4,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(height: 1.5, color: accent),
          ),
        ],
      ),
    );
  }
}

// ── All-day overlay (fixed above hour grid) ─────────────────────────────────

class _AllDayOverlay extends StatelessWidget {
  final List<AppointmentItem> appointments;
  final List<TransactionItem> transactions;
  final Color accent;
  final List<Color> categoryTints;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final ValueChanged<Appointment> onTapAppointment;
  final void Function(BuildContext, Appointment) onLongPressAppointment;

  const _AllDayOverlay({
    required this.appointments,
    required this.transactions,
    required this.accent,
    required this.categoryTints,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.onTapAppointment,
    required this.onLongPressAppointment,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = appointments.isNotEmpty || transactions.isNotEmpty;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.30),
        border: Border(
          bottom: BorderSide(color: accent.withValues(alpha: 0.8), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: hasItems
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...appointments.map((item) {
                    final appt = item.appointment;
                    final chipColor = appt.color != null
                        ? Color(
                            int.parse(appt.color!.replaceFirst('#', '0xff')))
                        : categoryColor(appt.category, categoryTints);
                    return _AllDayChip(
                      label: appt.title,
                      color: chipColor,
                      onTap: () => onTapAppointment(appt),
                      onLongPress: () =>
                          onLongPressAppointment(context, appt),
                    );
                  }),
                  ...transactions.map((item) {
                    final t = item.transaction;
                    final sign = t.isExpense ? '-' : '+';
                    final txColor = t.categoryColor != null
                        ? Color(int.parse(
                            t.categoryColor!.replaceFirst('#', '0xff')))
                        : accent;
                    return _AllDayChip(
                      label:
                          '${t.note ?? t.categoryName ?? 'Recurring'} $sign${t.amount.abs().toStringAsFixed(0)}',
                      color: txColor,
                      onTap: () =>
                          context.push(AppRoutes.editTransaction, extra: t),
                    );
                  }),
                ],
              )
            : const SizedBox(width: double.infinity, height: 44),
      ),
    );
  }
}

class _AllDayChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _AllDayChip({
    required this.label,
    required this.color,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppFonts.body(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
