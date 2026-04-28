import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Home, Trophy, Settings, Plus;
import 'package:iconoir_flutter/regular/list.dart' as list_icon;

enum NavTab { home, activity, goals, more }

class FloatingNavBar extends StatelessWidget {
  final NavTab active;
  final VoidCallback? onPlus;
  final ValueChanged<NavTab>? onTab;

  const FloatingNavBar({
    super.key,
    this.active = NavTab.home,
    this.onPlus,
    this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final accent = _c(theme.primaryColor);
    final muted = _c(theme.onInactiveColor);

    Widget colored(Widget child, NavTab t) =>
        SizedBox(width: 22, height: 22, child: child);

    final items = [
      _NavItem(
        tab: NavTab.home,
        label: 'Home',
        icon: colored(
          Home(width: 22, height: 22, color: active == NavTab.home ? accent : muted),
          NavTab.home,
        ),
        active: active == NavTab.home,
        activeColor: accent,
        mutedColor: muted,
        onTap: () => onTab?.call(NavTab.home),
      ),
      _NavItem(
        tab: NavTab.activity,
        label: 'Activity',
        icon: colored(
          list_icon.List(
            width: 22,
            height: 22,
            color: active == NavTab.activity ? accent : muted,
          ),
          NavTab.activity,
        ),
        active: active == NavTab.activity,
        activeColor: accent,
        mutedColor: muted,
        onTap: () => onTab?.call(NavTab.activity),
      ),
      _NavItem(
        tab: NavTab.goals,
        label: 'Goals',
        icon: colored(
          Trophy(width: 22, height: 22, color: active == NavTab.goals ? accent : muted),
          NavTab.goals,
        ),
        active: active == NavTab.goals,
        activeColor: accent,
        mutedColor: muted,
        onTap: () => onTab?.call(NavTab.goals),
      ),
      _NavItem(
        tab: NavTab.more,
        label: 'More',
        icon: colored(
          Settings(width: 22, height: 22, color: active == NavTab.more ? accent : muted),
          NavTab.more,
        ),
        active: active == NavTab.more,
        activeColor: accent,
        mutedColor: muted,
        onTap: () => onTab?.call(NavTab.more),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: items,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onPlus,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Plus(
                  width: 26,
                  height: 26,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _NavItem extends StatelessWidget {
  // ignore: unused_element_parameter
  final NavTab tab;
  final String label;
  final Widget icon;
  final bool active;
  final Color activeColor;
  final Color mutedColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.mutedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? activeColor : mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
