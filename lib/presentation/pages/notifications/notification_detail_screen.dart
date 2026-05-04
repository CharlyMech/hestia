import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/notifications/notification_icon.dart';

class NotificationDetailScreen extends StatelessWidget {
  final AppNotification notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);

    final v = NotifVisual.of(context, notification.type);

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Notification',
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
                children: [
                  CatTile(icon: v.icon, color: v.color, size: 44),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: v.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _typeLabel(notification.type),
                      style: AppFonts.label(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: v.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                notification.title,
                style: AppFonts.heading(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _fmtFull(notification.createdAt),
                style: AppFonts.body(fontSize: 12, color: muted),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  border: Border.all(color: border, width: 1),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
                child: Text(
                  notification.body,
                  style: AppFonts.body(fontSize: 14, color: fg, height: 1.5),
                ),
              ),
              if (notification.payload != null &&
                  notification.payload!.isNotEmpty) ...[
                const SizedBox(height: 22),
                SectionLabel('Details', color: muted),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: border, width: 1),
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final entry in notification.payload!.entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 110,
                                child: Text(
                                  entry.key,
                                  style: AppFonts.body(
                                      fontSize: 12, color: muted),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${entry.value}',
                                  style: AppFonts.body(
                                      fontSize: 13, color: fg),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _typeLabel(NotificationType t) => switch (t) {
        NotificationType.transaction => 'Transaction',
        NotificationType.goal => 'Goal',
        NotificationType.alert => 'Alert',
        NotificationType.system => 'System',
        NotificationType.reminder => 'Reminder',
      };

  String _fmtFull(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} · $hh:$mm';
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
