import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/theme_utils.dart';

/// Gradient overlay over the status bar zone.
/// Fades from transparent at the bottom to [tint] at [peakOpacity] at the top.
class StatusBarBlurOverlay extends StatelessWidget {
  const StatusBarBlurOverlay({
    super.key,
    this.tint,
    this.peakOpacity = 1.0,
    this.fadeExtent = 20,
  });

  /// Tint colour; defaults to theme background colour.
  final Color? tint;

  /// Opacity at the very top (Dynamic Island zone).
  final double peakOpacity;

  /// Extra pixels below the status bar over which the gradient fades to zero.
  final double fadeExtent;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final statusBarH =
        (mq.viewPadding.top > 0 ? mq.viewPadding.top : mq.padding.top) - 20;
    if (statusBarH <= 0) return const SizedBox.shrink();

    final totalH = statusBarH + fadeExtent;
    final tintColor = tint ?? hexToColor(context.myTheme.backgroundColor);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: totalH,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                tintColor.withValues(alpha: 1),
                tintColor.withValues(alpha: 0.95),
                tintColor.withValues(alpha: 0.9),
                tintColor.withValues(alpha: 0.85),
                tintColor.withValues(alpha: 0.8),
                tintColor.withValues(alpha: 0.75),
                tintColor.withValues(alpha: 0.7),
                tintColor.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
