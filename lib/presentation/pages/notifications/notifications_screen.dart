import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/notif_row.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:hestia/presentation/widgets/notifications/notification_icon.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final userId = auth is AuthAuthenticated ? auth.profile.id : null;

    if (userId == null) {
      return const _Empty(text: 'Sign in to view notifications.');
    }

    return BlocProvider(
      create: (_) => NotificationsBloc(AppDependencies.instance.notificationRepository)
        ..add(NotificationsLoad(userId)),
      child: _NotificationsBody(userId: userId),
    );
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

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading || state is NotificationsInitial) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (state is NotificationsError) {
            return _Empty(text: state.message);
          }
          final loaded = state as NotificationsLoaded;
          final items = loaded.items;

          if (items.isEmpty) {
            return ScreenShell(
              bg: bg,
              bottomPadding: 24,
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    fg: fg,
                    muted: muted,
                    accent: accent,
                    unread: 0,
                    onMarkAll: null,
                  ),
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
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++)
                      GestureDetector(
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
                  ],
                ),
              );

          return ScreenShell(
            bg: bg,
            bottomPadding: 24,
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  fg: fg,
                  muted: muted,
                  accent: accent,
                  unread: loaded.unreadCount,
                  onMarkAll: loaded.unreadCount == 0
                      ? null
                      : () => context
                          .read<NotificationsBloc>()
                          .add(NotificationsMarkAllRead(userId)),
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

class _Header extends StatelessWidget {
  final Color fg;
  final Color muted;
  final Color accent;
  final int unread;
  final VoidCallback? onMarkAll;

  const _Header({
    required this.fg,
    required this.muted,
    required this.accent,
    required this.unread,
    required this.onMarkAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inbox',
                  style: AppFonts.heading(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unread == 0 ? 'All caught up' : '$unread unread',
                  style: AppFonts.body(fontSize: 13, color: muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onMarkAll,
            child: Text(
              'Mark all read',
              style: AppFonts.body(
                fontSize: 13,
                color: onMarkAll == null ? muted : accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
    final muted = Color(int.parse(theme.onInactiveColor.replaceFirst('#', '0xff')));
    return CupertinoPageScaffold(
      backgroundColor: bg,
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
