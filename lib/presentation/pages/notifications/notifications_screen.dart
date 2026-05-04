import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/notif_row.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:hestia/presentation/widgets/notifications/notification_icon.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final userId = auth is AuthAuthenticated ? auth.profile.id : null;

    if (userId == null) {
      return const _Empty(text: 'Sign in to view notifications.');
    }

    // Reuse the app-level NotificationsBloc; refresh on entry.
    context.read<NotificationsBloc>().add(NotificationsLoad(userId));
    return _NotificationsBody(userId: userId);
  }
}

class _NotificationsBody extends StatelessWidget {
  final String userId;
  const _NotificationsBody({required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final dim = muted.withValues(alpha: 0.55);

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Inbox',
      trailing: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          final enabled =
              state is NotificationsLoaded && state.unreadCount > 0;
          return GestureDetector(
            onTap: enabled
                ? () => context
                    .read<NotificationsBloc>()
                    .add(NotificationsMarkAllRead(userId))
                : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                'Mark all',
                style: AppFonts.body(
                  fontSize: 13,
                  color: enabled ? accent : muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
      child: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading || state is NotificationsInitial) {
            return Skeletonizer(
              enabled: true,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  _InboxSubtitle(unread: 0, muted: muted),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: surface,
                      border: Border.all(color: border, width: 1),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < 4; i++)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                            decoration: BoxDecoration(
                              border: i < 3
                                  ? Border(bottom: BorderSide(color: border))
                                  : null,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Notification placeholder',
                              style: AppFonts.body(
                                  fontSize: 14, color: fg, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is NotificationsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(fontSize: 14, color: muted),
                ),
              ),
            );
          }
          final loaded = state as NotificationsLoaded;
          final items = loaded.items;

          if (items.isEmpty) {
            return ScreenShell(
              bg: bg,
              bottomPadding: 24,
              slivers: [
                SliverToBoxAdapter(
                  child: _InboxSubtitle(unread: 0, muted: muted),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
                SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'No notifications yet',
                      style: AppFonts.body(fontSize: 14, color: muted),
                    ),
                  ),
                ),
              ],
            );
          }

          final now = DateTime.now();
          final today = <AppNotification>[];
          final earlier = <AppNotification>[];
          for (final n in items) {
            if (_isSameDay(n.createdAt, now)) {
              today.add(n);
            } else {
              earlier.add(n);
            }
          }

          Widget card(List<AppNotification> rows) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: surface,
                  border: Border.all(color: border, width: 1),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++)
                      Dismissible(
                        key: ValueKey('notif-${rows[i].id}'),
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          color: accent.withValues(alpha: 0.18),
                          child: Text(
                            rows[i].isRead ? 'Mark unread' : 'Mark read',
                            style: AppFonts.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: const Color(0xFFEF4444),
                          child: Text(
                            'Delete',
                            style: AppFonts.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            return await showCupertinoDialog<bool>(
                                  context: context,
                                  builder: (ctx) => CupertinoAlertDialog(
                                    title: const Text('Delete notification'),
                                    content: const Text(
                                        'This action cannot be undone.'),
                                    actions: [
                                      CupertinoDialogAction(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      CupertinoDialogAction(
                                        isDestructiveAction: true,
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                          }
                          // Swipe right → toggle read; don't actually dismiss.
                          context.read<NotificationsBloc>().add(
                                NotificationsToggleRead(
                                    rows[i].id, rows[i].isRead),
                              );
                          return false;
                        },
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            context
                                .read<NotificationsBloc>()
                                .add(NotificationsDelete(rows[i].id));
                          }
                        },
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _openDetail(context, rows[i]),
                          child: NotifRow(
                            n: _toData(context, rows[i]),
                            divider: i < rows.length - 1,
                            border: border,
                            fg: fg,
                            muted: muted,
                            dim: dim,
                            accent: accent,
                          ),
                        ),
                      ),
                  ],
                ),
              );

          return ScreenShell(
            bg: bg,
            bottomPadding: 24,
            slivers: [
              SliverToBoxAdapter(
                child: _InboxSubtitle(
                  unread: loaded.unreadCount,
                  muted: muted,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              if (today.isNotEmpty) ...[
                SliverToBoxAdapter(child: SectionLabel('Today', color: muted)),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                SliverToBoxAdapter(child: card(today)),
                const SliverToBoxAdapter(child: SizedBox(height: 22)),
              ],
              if (earlier.isNotEmpty) ...[
                SliverToBoxAdapter(child: SectionLabel('Earlier', color: muted)),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                SliverToBoxAdapter(child: card(earlier)),
              ],
            ],
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, AppNotification n) {
    if (!n.isRead) {
      context.read<NotificationsBloc>().add(NotificationsMarkRead(n.id));
    }
    context.push(AppRoutes.notificationDetail, extra: n);
  }

  NotifData _toData(BuildContext context, AppNotification n) {
    final v = NotifVisual.of(context, n.type);
    return NotifData(
      icon: v.icon,
      color: v.color,
      title: n.title,
      body: n.body,
      time: _fmtTime(n.createdAt),
      unread: !n.isRead,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _fmtTime(DateTime d) {
    final now = DateTime.now();
    if (_isSameDay(d, now)) {
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    final diff = now.difference(d).inDays;
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${d.day}/${d.month}';
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _InboxSubtitle extends StatelessWidget {
  final int unread;
  final Color muted;

  const _InboxSubtitle({required this.unread, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          unread == 0 ? 'All caught up' : '$unread unread',
          style: AppFonts.body(fontSize: 13, color: muted),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = Color(int.parse(theme.backgroundColor.replaceFirst('#', '0xff')));
    final surface =
        Color(int.parse(theme.surfaceColor.replaceFirst('#', '0xff')));
    final border = Color(int.parse(theme.borderColor.replaceFirst('#', '0xff')));
    final fg = Color(int.parse(theme.onBackgroundColor.replaceFirst('#', '0xff')));
    final muted = Color(int.parse(theme.onInactiveColor.replaceFirst('#', '0xff')));
    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Inbox',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppFonts.body(fontSize: 14, color: muted),
          ),
        ),
      ),
    );
  }
}
