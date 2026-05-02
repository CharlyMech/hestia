import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Home, Trophy, Calendar, Wallet, Plus;

/// Tab indices for the floating nav bar.
enum NavTab { home, calendar, goals, accounts }

/// Index-driven floating nav bar with animated active pill.
///
/// [activeIndex] drives both the pill position and the active item color.
/// Pass a fractional [pageOffset] (0.0–3.0) from a [PageController] to make
/// the pill track swipe gestures continuously.
class FloatingNavBar extends StatelessWidget {
  final int activeIndex;
  final double? pageOffset;
  final ValueChanged<int>? onTab;
  final VoidCallback? onPlus;

  const FloatingNavBar({
    super.key,
    required this.activeIndex,
    this.pageOffset,
    this.onTab,
    this.onPlus,
  });

  static const _items = 4;

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final accent = _c(theme.primaryColor);
    final muted = _c(theme.onInactiveColor);

    final position = pageOffset ?? activeIndex.toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(color: border, width: 1),
              ),
              child: LayoutBuilder(
                builder: (context, c) {
                  final itemWidth = c.maxWidth / _items;
                  // Pill is a thin accent bar above the active item.
                  final pillWidth = itemWidth * 0.46;
                  final pillLeft =
                      position * itemWidth + (itemWidth - pillWidth) / 2;

                  return Stack(
                    children: [
                      // Animated active-indicator pill (top edge of bar)
                      AnimatedPositioned(
                        duration: pageOffset != null
                            ? Duration.zero
                            : const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                        top: 0,
                        left: pillLeft,
                        width: pillWidth,
                        height: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < _items; i++)
                            Expanded(
                              child: _NavItem(
                                index: i,
                                active: activeIndex == i,
                                accent: accent,
                                muted: muted,
                                onTap: () => onTab?.call(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
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
                borderRadius: BorderRadius.circular(AppRadii.xl),
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
  final int index;
  final bool active;
  final Color accent;
  final Color muted;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.active,
    required this.accent,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? accent : muted;
    final Widget icon = switch (index) {
      0 => Home(width: 22, height: 22, color: color),
      1 => Calendar(width: 22, height: 22, color: color),
      2 => Trophy(width: 22, height: 22, color: color),
      _ => Wallet(width: 22, height: 22, color: color),
    };
    final label = switch (index) {
      0 => 'Home',
      1 => 'Calendar',
      2 => 'Goals',
      _ => 'Accounts',
    };
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 22, height: 22, child: icon),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppFonts.body(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
