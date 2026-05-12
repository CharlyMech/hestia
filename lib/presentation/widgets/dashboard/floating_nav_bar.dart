import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'package:hestia/presentation/widgets/pets/paw_icon.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Car, CartAlt, ReportColumns, Wallet, CoinsSwap;

/// Logical tab indices — independent of whether Cars is shown.
enum NavTab { home, accounts, pets, cars, shopping }

/// Glass-morphism floating nav bar with animated active pill.
///
/// Tab order: Home · Accounts · Pets · (Cars, if enabled) · Shopping
/// The [activeIndex] is a *page index* (0-based, fuel page included when
/// shown). [pageOffset] is the raw [PageController.page] value used for
/// continuous pill tracking during swipe.
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

  @override
  Widget build(BuildContext context) {
    final showFuel = context.watch<UserPrefsBloc>().state.showFuelModule;
    final tabs = _buildTabs(showFuel);
    final accent = _c(context.myTheme.primaryColor);
    final muted = _c(context.myTheme.onInactiveColor);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _GlassNavPill(
              tabs: tabs,
              activeIndex: activeIndex,
              pageOffset: pageOffset,
              accent: accent,
              muted: muted,
              l10n: l10n,
              onTab: onTab,
            ),
          ),
          const SizedBox(width: 12),
          _PlusButton(accent: accent, onPlus: onPlus),
        ],
      ),
    );
  }

  static List<NavTab> _buildTabs(bool showFuel) {
    final tabs = [NavTab.home, NavTab.accounts, NavTab.pets];
    if (showFuel) tabs.add(NavTab.cars);
    tabs.add(NavTab.shopping);
    return tabs;
  }

  static Color _c(String hex) =>
      Color(int.parse(hex.replaceFirst('#', '0xff')));
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

  const _GlassNavPill({
    required this.tabs,
    required this.activeIndex,
    required this.pageOffset,
    required this.accent,
    required this.muted,
    required this.l10n,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    final position = (pageOffset ?? activeIndex.toDouble())
        .clamp(0.0, (tabs.length - 1).toDouble());

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground
                .resolveFrom(context)
                .withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: CupertinoColors.separator
                  .resolveFrom(context)
                  .withValues(alpha: 0.45),
              width: 0.8,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final itemW = c.maxWidth / tabs.length;
              final pillW = itemW * 0.72;
              final pillLeft = position * itemW + (itemW - pillW) / 2;
              final pillBg = CupertinoColors.label
                  .resolveFrom(context)
                  .withValues(alpha: 0.14);

              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedPositioned(
                    duration: pageOffset != null
                        ? Duration.zero
                        : const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    left: pillLeft,
                    top: 6,
                    width: pillW,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(20),
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
                            accent: accent,
                            muted: muted,
                            l10n: l10n,
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

// ── Plus button ───────────────────────────────────────────────────────────────

class _PlusButton extends StatefulWidget {
  final Color accent;
  final VoidCallback? onPlus;

  const _PlusButton({required this.accent, required this.onPlus});

  @override
  State<_PlusButton> createState() => _PlusButtonState();
}

class _PlusButtonState extends State<_PlusButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onPlus?.call();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: widget.accent.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: widget.accent.withValues(alpha: 0.5),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: CoinsSwap(
                  width: 26,
                  height: 26,
                  color: CupertinoColors.white,
                ),
              ),
            ),
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
  final Color accent;
  final Color muted;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.active,
    required this.accent,
    required this.muted,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? accent : muted;
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
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(width: 22, height: 22, child: icon),
            const SizedBox(height: 4),
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
