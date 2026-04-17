import 'package:flutter/cupertino.dart';

/// Animated linear progress bar using Flutter's built-in animation stack.
///
/// Progress changes animate smoothly via [CurvedAnimation].
/// A shimmer sweep rides on top while [value] < 1.0.
class AnimatedProgressBar extends StatefulWidget {
  final double value;
  final Color trackColor;
  final Color fillColor;
  final double height;
  final BorderRadius borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.trackColor,
    required this.fillColor,
    this.height = 4,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        height: widget.height,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: widget.value),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, _) {
            return AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ProgressBarPainter(
                    progress: animatedValue,
                    trackColor: widget.trackColor,
                    fillColor: widget.fillColor,
                    shimmerPosition: _shimmerAnimation.value,
                    complete: widget.value >= 1.0,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double shimmerPosition;
  final bool complete;

  const _ProgressBarPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.shimmerPosition,
    required this.complete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()..color = trackColor;
    canvas.drawRect(Offset.zero & size, trackPaint);

    final fillWidth = size.width * progress.clamp(0.0, 1.0);
    if (fillWidth <= 0) return;

    final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.height);
    final fillPaint = Paint()..color = fillColor;
    canvas.drawRect(fillRect, fillPaint);

    if (!complete && fillWidth > 0) {
      final shimmerX = fillWidth * shimmerPosition;
      final shimmerPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            fillColor.withValues(alpha: 0),
            fillColor.withValues(alpha: 0.5),
            fillColor.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromLTWH(shimmerX - 30, 0, 60, size.height),
        );
      canvas.drawRect(fillRect, shimmerPaint);
    }
  }

  @override
  bool shouldRepaint(_ProgressBarPainter old) =>
      old.progress != progress ||
      old.shimmerPosition != shimmerPosition ||
      old.complete != complete;
}
