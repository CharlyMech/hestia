import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';

/// Animated sliding-pill tab bar, liquid-glass inspired.
/// Drop-in replacement for any manual row-based tab selector.
class AnimatedPillTabs extends StatefulWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color pillColor;
  final Color? activeIndexFgColor;
  final List<Widget>? icons;
  final double height;

  const AnimatedPillTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.pillColor,
    this.activeIndexFgColor,
    this.icons,
    this.height = 44,
  });

  @override
  State<AnimatedPillTabs> createState() => _AnimatedPillTabsState();
}

class _AnimatedPillTabsState extends State<AnimatedPillTabs>
    with TickerProviderStateMixin {
  static const double _trackInset = 4;
  static const double _itemHorizontalPadding = 6;
  final Map<int, AnimationController> _scaleControllers = {};

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.labels.length; i++) {
      _scaleControllers[i] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 1.0,
      );
    }
  }

  @override
  void dispose() {
    for (final c in _scaleControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTap(int index) {
    final ctrl = _scaleControllers[index];
    if (ctrl != null) {
      ctrl.forward().then((_) => ctrl.reverse());
    }
    widget.onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: widget.border, width: 0.8),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final count = widget.labels.length;
              final itemW = constraints.maxWidth / count;
              final pillW = itemW - (_trackInset * 2);
              final pillLeft = widget.selectedIndex * itemW + _trackInset;

              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    left: pillLeft,
                    top: _trackInset,
                    width: pillW,
                    height: widget.height - (_trackInset * 2),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.pillColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < count; i++)
                        Expanded(
                          child: _TabItem(
                            label: widget.labels[i],
                            icon: widget.icons?.elementAtOrNull(i),
                            horizontalPadding: _itemHorizontalPadding,
                            active: widget.selectedIndex == i,
                            // Active tab sits on the pill → default to onPrimary
                            // (reads on light themes) unless caller overrides.
                            activeFg: widget.activeIndexFgColor ??
                                hexToColor(context.myTheme.onPrimaryColor),
                            muted: widget.muted,
                            scaleCtrl: _scaleControllers[i]!,
                            onTap: () => _onTap(i),
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

class _TabItem extends StatelessWidget {
  final String label;
  final Widget? icon;
  final double horizontalPadding;
  final bool active;
  final Color activeFg;
  final Color muted;
  final AnimationController scaleCtrl;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.horizontalPadding,
    required this.active,
    required this.activeFg,
    required this.muted,
    required this.scaleCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeFg : muted;
    final scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: scaleCtrl, curve: Curves.easeInOut),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: scale,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 2,
            children: [
              if (icon != null) icon!,
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
