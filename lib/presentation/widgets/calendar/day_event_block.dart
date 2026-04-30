import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/presentation/widgets/calendar/day_view_layout.dart';

class DayEventBlock extends StatelessWidget {
  final PositionedEvent event;
  final double hourHeight;
  final Color color;
  final VoidCallback onTap;
  final bool use24h;

  const DayEventBlock({
    super.key,
    required this.event,
    required this.hourHeight,
    required this.color,
    required this.onTap,
    this.use24h = true,
  });

  @override
  Widget build(BuildContext context) {
    final height = event.blockHeight(hourHeight);
    final tall = height >= 40;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        scale: 1,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          opacity: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: color, width: 3),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(6, 3, 4, 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.appointment.title,
                  style: AppFonts.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tall) ...[
                  Text(
                    _timeRange(),
                    style: AppFonts.body(
                      fontSize: 10,
                      color: color.withValues(alpha: 0.75),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _timeRange() {
    final a = event.appointment;
    return '${_fmt(a.startsAt)} – ${_fmt(a.endsAt)}';
  }

  String _fmt(DateTime t) {
    final mm = t.minute.toString().padLeft(2, '0');
    if (use24h) {
      return '${t.hour.toString().padLeft(2, '0')}:$mm';
    }
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final period = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$mm $period';
  }
}

/// Returns the color for a given [AppointmentCategory] from [categoryTints].
Color categoryColor(AppointmentCategory cat, List<Color> tints) {
  return switch (cat) {
    AppointmentCategory.health => tints[0],
    AppointmentCategory.vehicle => tints[1],
    AppointmentCategory.beauty => tints[2],
    AppointmentCategory.work => tints[3],
    AppointmentCategory.personal => tints[4],
    AppointmentCategory.other => tints[5 % tints.length],
  };
}
