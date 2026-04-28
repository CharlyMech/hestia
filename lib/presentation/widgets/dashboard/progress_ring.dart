import 'dart:math' as math;
import 'package:flutter/widgets.dart';

class ProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Color trackColor;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 56,
    this.stroke = 4,
    required this.color,
    required this.trackColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              value: clamped,
              stroke: stroke,
              color: color,
              trackColor: trackColor,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double stroke;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.value,
    required this.stroke,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      value * 2 * math.pi,
      false,
      Paint()
        ..color = color
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value ||
      old.stroke != stroke ||
      old.color != color ||
      old.trackColor != trackColor;
}
