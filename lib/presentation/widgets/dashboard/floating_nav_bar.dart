import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_sessions_bloc.dart';
import 'package:hestia/presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'package:hestia/presentation/widgets/pets/paw_icon.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Car, CartAlt, ReportColumns, Wallet;

/// Logical tab indices — independent of whether Cars is shown.
enum NavTab { home, accounts, pets, cars, shopping }

const double _kNavItemHorizontalPadding = 2;
const double _kNavItemVerticalPadding = 2;
const double _kNavPillInset = 2;

/// Glass-morphism floating nav bar with animated active pill.
///
/// Tab order: Home · Accounts · Calendar · Pets · (Cars, if enabled) · Shopping
class FloatingNavBar extends StatelessWidget {
  final int activeIndex;
  final double? pageOffset;
  final ValueChanged<int>? onTab;
  final double height;

  const FloatingNavBar({
    super.key,
    required this.activeIndex,
    this.pageOffset,
    this.onTab,
    this.height = 58,
  });

  @override
  Widget build(BuildContext context) {
    final showFuel = context.watch<UserPrefsBloc>().state.showFuelModule;
    final tabs = _buildTabs(showFuel);
    final accent = hexToColor(context.myTheme.primaryColor);
    final muted = hexToColor(context.myTheme.onInactiveColor);
    final l10n = AppLocalizations.of(context);

    // Shopping badge — number of active sessions
    final shoppingState = context.watch<ShoppingSessionsBloc>().state;
    final shoppingBadge = shoppingState is ShoppingSessionsLoaded
        ? shoppingState.activeCount
        : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: _GlassNavPill(
        tabs: tabs,
        activeIndex: activeIndex,
        pageOffset: pageOffset,
        accent: accent,
        muted: muted,
        l10n: l10n,
        onTab: onTab,
        shoppingBadge: shoppingBadge,
        height: height,
      ),
    );
  }

  static List<NavTab> _buildTabs(bool showFuel) {
    final tabs = [NavTab.home, NavTab.accounts, NavTab.pets];
    if (showFuel) tabs.add(NavTab.cars);
    tabs.add(NavTab.shopping);
    return tabs;
  }
}

// ── Glass pill container ──────────────────────────────────────────────────────

class _GlassNavPill extends StatelessWidget {
  final List<NavTab> tabs;
  final int activeIndex;
  final double? pageOffset;
  final Color accent;
  final Color muted;
  final AppLocalizations l10n;
  final ValueChanged<int>? onTab;
  final int shoppingBadge;
  final double height;

  const _GlassNavPill({
    required this.tabs,
    required this.activeIndex,
    required this.pageOffset,
    required this.accent,
    required this.muted,
    required this.l10n,
    required this.onTab,
    this.shoppingBadge = 0,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final position = (pageOffset ?? activeIndex.toDouble())
        .clamp(0.0, (tabs.length - 1).toDouble());
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final primary = hexToColor(theme.primaryColor);
    final onPrimary = hexToColor(theme.onPrimaryColor);
    final red = hexToColor(theme.colorRed);
    final onRed = hexToColor(theme.onRedColor);

    final navRadius = height / 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(navRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(navRadius),
            border: Border.all(
              color: border,
              width: 1,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final itemW = c.maxWidth / tabs.length;
              // Fill almost entire navbar height with a tiny uniform inset.
              final pillH =
                  (c.maxHeight - (_kNavPillInset * 2)).clamp(0.0, c.maxHeight);
              final pillTop = _kNavPillInset;
              // Pill width follows NavItem width minus its horizontal padding.
              final pillW =
                  (itemW - (_kNavItemHorizontalPadding * 2)).clamp(0.0, itemW);
              final pillLeft = position * itemW + _kNavItemHorizontalPadding;
              final pillBg = primary;

              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedPositioned(
                    duration: pageOffset != null
                        ? Duration.zero
                        : const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    left: pillLeft,
                    top: pillTop,
                    width: pillW,
                    height: pillH,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(pillH / 2),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < tabs.length; i++)
                        Expanded(
                          child: _NavItem(
                            tab: tabs[i],
                            active: activeIndex == i,
                            // Active item sits on the primary pill → use
                            // onPrimary so it reads on light themes too.
                            activeColor: onPrimary,
                            badgeColor: red,
                            badgeFg: onRed,
                            muted: muted,
                            l10n: l10n,
                            badge:
                                tabs[i] == NavTab.shopping ? shoppingBadge : 0,
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
    );
  }
}

// ── Nav item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final NavTab tab;
  final bool active;
  final Color activeColor;
  final Color muted;
  final Color badgeColor;
  final Color badgeFg;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final int badge;

  const _NavItem({
    required this.tab,
    required this.active,
    required this.activeColor,
    required this.muted,
    required this.badgeColor,
    required this.badgeFg,
    required this.l10n,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : muted;
    final Widget icon = switch (tab) {
      NavTab.home => ReportColumns(width: 22, height: 22, color: color),
      NavTab.accounts => Wallet(width: 22, height: 22, color: color),
      NavTab.pets => PawIcon(size: 22, color: color),
      NavTab.cars => Car(width: 22, height: 22, color: color),
      NavTab.shopping => CartAlt(width: 22, height: 22, color: color),
    };
    final label = switch (tab) {
      NavTab.home => l10n.nav_dashboard,
      NavTab.accounts => l10n.nav_accounts,
      NavTab.pets => l10n.nav_pets,
      NavTab.cars => l10n.nav_cars,
      NavTab.shopping => l10n.nav_shopping,
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _kNavItemHorizontalPadding,
          vertical: _kNavItemVerticalPadding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          spacing: 2,
          children: [
            // Icon with optional badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(width: 22, height: 22, child: icon),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 14),
                      height: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$badge',
                        style: TextStyle(
                          color: badgeFg,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: color,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
