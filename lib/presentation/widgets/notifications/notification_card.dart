import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/presentation/widgets/common/swipeable_card.dart';
import 'package:hestia/presentation/widgets/notifications/notification_icon.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Trash;

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final VoidCallback? onTap;
  final VoidCallback? onToggleRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    this.onTap,
    this.onToggleRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final visual = NotifVisual.of(context, notification.type);

    return SwipeableCard(
      leftActions: [
        if (onDelete != null)
          SwipeAction(
            color: CupertinoColors.destructiveRed,
            icon: Trash(width: 18, height: 18, color: CupertinoColors.white),
            label: 'Delete',
            onTap: onDelete!,
          ),
      ],
      rightActions: [
        if (onToggleRead != null)
          SwipeAction(
            color: accent.withValues(alpha: 0.85),
            icon: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                shape: BoxShape.circle,
              ),
            ),
            label: notification.isRead ? 'Unread' : 'Read',
            onTap: onToggleRead!,
          ),
      ],
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: notification.isRead ? surface : accent.withValues(alpha: 0.04),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: visual.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: visual.icon,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      notification.title,
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.w700,
                        color: fg,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notification.body.isNotEmpty)
                      Text(
                        notification.body,
                        style: AppFonts.body(fontSize: 12, color: muted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
