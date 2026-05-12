import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/presentation/blocs/notifications/notifications_bloc.dart';

/// Compact notifications popover used by the dashboard bell. Shows the latest
/// 5 unread notifications, "Mark all read" and "Show all" CTAs. Tapping a row
/// marks it read and pushes the detail screen.
class NotificationsPopover extends StatelessWidget {
  final String userId;
  const NotificationsPopover({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);

    return SizedBox(
      width: 320,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            final loaded = state is NotificationsLoaded ? state : null;
            final unread = loaded == null
                ? const <AppNotification>[]
                : loaded.items.where((n) => !n.isRead).take(5).toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(
                  fg: fg,
                  muted: muted,
                  accent: accent,
                  unreadCount: loaded?.unreadCount ?? 0,
                  onMarkAll: () => context
                      .read<NotificationsBloc>()
                      .add(NotificationsMarkAllRead(userId)),
                ),
                Container(height: 1, color: border),
                if (state is NotificationsLoading ||
                    state is NotificationsInitial)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: CupertinoActivityIndicator(),
                  )
                else if (unread.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'You\'re all caught up',
                      style: AppFonts.body(fontSize: 12, color: muted),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (var i = 0; i < unread.length; i++)
                        _Row(
                          item: unread[i],
                          fg: fg,
                          muted: muted,
                          accent: accent,
                          showDivider: i < unread.length - 1,
                          dividerColor: border,
                          onTap: () {
                            context
                                .read<NotificationsBloc>()
                                .add(NotificationsMarkRead(unread[i].id));
                            Navigator.of(context).maybePop();
                            context.push(
                              AppRoutes.notificationDetail,
                              extra: unread[i],
                            );
                          },
                        ),
                    ],
                  ),
                Container(height: 1, color: border),
                CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                    context.push(AppRoutes.notifications);
                  },
                  child: Text(
                    'Show all',
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accent,
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

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Header extends StatelessWidget {
  final Color fg;
  final Color muted;
  final Color accent;
  final int unreadCount;
  final VoidCallback onMarkAll;

  const _Header({
    required this.fg,
    required this.muted,
    required this.accent,
    required this.unreadCount,
    required this.onMarkAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 1,
              children: [
                Text(
                  'Notifications',
                  style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                Text(
                  unreadCount == 0 ? 'No unread' : '$unreadCount unread',
                  style: AppFonts.body(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            CupertinoButton(
              onPressed: onMarkAll,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Mark all read',
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final AppNotification item;
  final Color fg;
  final Color muted;
  final Color accent;
  final bool showDivider;
  final Color dividerColor;
  final VoidCallback onTap;

  const _Row({
    required this.item,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.showDivider,
    required this.dividerColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: dividerColor, width: 1))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 1,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
