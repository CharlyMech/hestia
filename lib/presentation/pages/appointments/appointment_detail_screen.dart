import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Bell, Cut, Cutlery, Heart, MapPin, Sparks, Suitcase;

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;
  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final tints = theme.categoryTints.map(_c).toList();

    final color = switch (appointment.category) {
      AppointmentCategory.health => tints[0],
      AppointmentCategory.vehicle => tints[1],
      AppointmentCategory.beauty => tints[2],
      AppointmentCategory.work => tints[3],
      AppointmentCategory.personal => tints[4],
      AppointmentCategory.other => tints[5 % tints.length],
    };

    Widget icon = switch (appointment.category) {
      AppointmentCategory.health =>
        Heart(width: 20, height: 20, color: CupertinoColors.white),
      AppointmentCategory.vehicle =>
        Cutlery(width: 20, height: 20, color: CupertinoColors.white),
      AppointmentCategory.beauty =>
        Cut(width: 20, height: 20, color: CupertinoColors.white),
      AppointmentCategory.work =>
        Suitcase(width: 20, height: 20, color: CupertinoColors.white),
      AppointmentCategory.personal ||
      AppointmentCategory.other =>
        Sparks(width: 20, height: 20, color: CupertinoColors.white),
    };

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Appointment',
      trailing: GestureDetector(
        onTap: () => context.push(
          AppRoutes.editAppointment,
          extra: appointment,
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            'Edit',
            style: AppFonts.body(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
            Row(
              children: [
                CatTile(icon: icon, color: color, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.title,
                        style: AppFonts.heading(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _categoryLabel(appointment.category),
                        style: AppFonts.body(fontSize: 13, color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _Card(
              surface: surface,
              border: border,
              children: [
                _Row(
                  label: 'Starts',
                  value: _fmtDateTime(appointment.startsAt),
                  fg: fg,
                  muted: muted,
                ),
                _Row(
                  label: 'Ends',
                  value: _fmtDateTime(appointment.endsAt),
                  fg: fg,
                  muted: muted,
                ),
                _Row(
                  label: 'Duration',
                  value: _fmtDuration(appointment.duration),
                  fg: fg,
                  muted: muted,
                  showDivider: false,
                ),
              ],
            ),
            if (appointment.location != null &&
                appointment.location!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _Card(
                surface: surface,
                border: border,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        MapPin(width: 18, height: 18, color: muted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            appointment.location!,
                            style: AppFonts.body(fontSize: 14, color: fg),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (appointment.notes != null &&
                appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionLabel('Notes', color: muted),
              const SizedBox(height: 10),
              _Card(
                surface: surface,
                border: border,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      appointment.notes!,
                      style: AppFonts.body(
                          fontSize: 14, color: fg, height: 1.5),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SectionLabel('Reminders', color: muted),
            const SizedBox(height: 10),
            _Card(
              surface: surface,
              border: border,
              children: [
                if (appointment.reminderOffsets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No reminders set',
                      style: AppFonts.body(fontSize: 13, color: muted),
                    ),
                  )
                else
                  for (var i = 0; i < appointment.reminderOffsets.length; i++)
                    _ReminderRow(
                      offset: appointment.reminderOffsets[i],
                      fg: fg,
                      muted: muted,
                      showDivider:
                          i < appointment.reminderOffsets.length - 1,
                    ),
              ],
            ),
            if (appointment.googleEventId != null) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.link,
                        size: 14, color: accent),
                    const SizedBox(width: 8),
                    Text(
                      'Synced with Google Calendar',
                      style: AppFonts.label(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
    );
  }

  String _categoryLabel(AppointmentCategory c) => switch (c) {
        AppointmentCategory.health => 'Health',
        AppointmentCategory.vehicle => 'Vehicle',
        AppointmentCategory.beauty => 'Beauty',
        AppointmentCategory.work => 'Work',
        AppointmentCategory.personal => 'Personal',
        AppointmentCategory.other => 'Other',
      };

  String _fmtDateTime(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} · $hh:$mm';
  }

  String _fmtDuration(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    if (d.inMinutes % 60 == 0) return '${d.inHours} h';
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  final Color surface;
  final Color border;
  const _Card({
    required this.children,
    required this.surface,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color fg;
  final Color muted;
  final bool showDivider;
  const _Row({
    required this.label,
    required this.value,
    required this.fg,
    required this.muted,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                color: muted.withValues(alpha: 0.15),
                width: 1,
              ))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppFonts.body(fontSize: 12, color: muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.body(fontSize: 13, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final Duration offset;
  final Color fg;
  final Color muted;
  final bool showDivider;
  const _ReminderRow({
    required this.offset,
    required this.fg,
    required this.muted,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                color: muted.withValues(alpha: 0.15),
                width: 1,
              ))
            : null,
      ),
      child: Row(
        children: [
          Bell(width: 14, height: 14, color: muted),
          const SizedBox(width: 12),
          Text(
            _fmt(offset),
            style: AppFonts.body(fontSize: 13, color: fg),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes} min before';
    if (d.inHours < 24) return '${d.inHours}h before';
    final days = d.inDays;
    return days == 1 ? '1 day before' : '$days days before';
  }
}
