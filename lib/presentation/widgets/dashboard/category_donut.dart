import 'dart:math' as math;
import 'package:flutter/widgets.dart';

class DonutSegment {
  final double value;
  final Color color;
  const DonutSegment({required this.value, required this.color});
}

class CategoryDonut extends StatelessWidget {
  final List<DonutSegment> segments;
  final double size;
  final double stroke;
  final Color trackColor;

  const CategoryDonut({
    super.key,
    required this.segments,
    this.size = 96,
    this.stroke = 12,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          segments: segments,
          stroke: stroke,
          trackColor: trackColor,
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double stroke;
  final Color trackColor;

  _DonutPainter({
    required this.segments,
    required this.stroke,
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

    final total = segments.fold<double>(0, (s, x) => s + x.value);
    if (total == 0) return;
    var startRad = -math.pi / 2;
    for (final seg in segments) {
      final sweep = (seg.value / total) * 2 * math.pi;
      canvas.drawArc(
        rect,
        startRad,
        sweep,
        false,
        Paint()
          ..color = seg.color
          ..strokeWidth = stroke
          ..style = PaintingStyle.stroke,
      );
      startRad += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.segments != segments ||
      old.stroke != stroke ||
      old.trackColor != trackColor;
}
