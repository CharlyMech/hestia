import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/notif_row.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Group, Trophy, Bell, Shield;

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
    final dim = muted.withValues(alpha: 0.55);

    final today = <NotifData>[
      NotifData(
        icon: Group(width: 18, height: 18, color: tints[0]),
        color: tints[0],
        title: 'Luis added a transaction',
        body: 'Iberdrola · −62.14€ on Joint · Santander',
        time: '09:14',
        unread: true,
      ),
      NotifData(
        icon: Trophy(width: 18, height: 18, color: _c(theme.colorGreen)),
        color: _c(theme.colorGreen),
        title: 'Goal milestone reached',
        body: 'Summer trip · Sicily passed 60% complete',
        time: '07:50',
        unread: true,
      ),
    ];

    final earlier = <NotifData>[
      NotifData(
        icon: Bell(width: 18, height: 18, color: tints[1]),
        color: tints[1],
        title: 'Recurring transaction',
        body: 'Netflix was charged 12.99€',
        time: 'Yesterday',
      ),
      NotifData(
        icon: Shield(width: 18, height: 18, color: _c(theme.colorRed)),
        color: _c(theme.colorRed),
        title: 'Unusual spending',
        body: 'Dining budget at 110% this month',
        time: '2 days ago',
      ),
      NotifData(
        icon: Group(width: 18, height: 18, color: tints[2]),
        color: tints[2],
        title: 'Household invite accepted',
        body: 'Luis Rodríguez joined your household',
        time: '4 days ago',
      ),
    ];

    Widget card(List<NotifData> rows) => Container(
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
                NotifRow(
                  n: rows[i],
                  divider: i < rows.length - 1,
                  border: border,
                  fg: fg,
                  muted: muted,
                  dim: dim,
                  accent: accent,
                ),
            ],
          ),
        );

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: ScreenShell(
        bg: bg,
        bottomPadding: 24,
        slivers: [
        SliverToBoxAdapter(
          child: Padding(
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
                        '2 unread',
                        style: AppFonts.body(fontSize: 13, color: muted),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Mark all read',
                  style: AppFonts.body(
                    fontSize: 13,
                    color: accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 22)),
        SliverToBoxAdapter(child: SectionLabel('Today', color: muted)),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(child: card(today)),
        const SliverToBoxAdapter(child: SizedBox(height: 22)),
        SliverToBoxAdapter(child: SectionLabel('Earlier', color: muted)),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(child: card(earlier)),
        ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
