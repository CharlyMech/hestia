import 'package:flutter/widgets.dart';

class PawIcon extends StatelessWidget {
  final double size;
  final Color color;

  const PawIcon({super.key, this.size = 24, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PawPainter(color),
    );
  }
}

class _PawPainter extends CustomPainter {
  final Color color;
  _PawPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * (30 / 512)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final sx = size.width / 512;
    final sy = size.height / 512;

    // Top-right pad
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(331.611 * sx, 110.864 * sy),
        width: (371.917 - 291.303) * sx,
        height: (163.799 - 57.928) * sy,
      ),
      paint,
    );

    // Top-left pad
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(180.397 * sx, 110.864 * sy),
        width: (220.704 - 140.09) * sx,
        height: (163.799 - 57.928) * sy,
      ),
      paint,
    );

    // Right pad
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(440.785 * sx, 245.257 * sy),
        width: (483.138 - 398.427) * sx,
        height: (298.192 - 192.321) * sy,
      ),
      paint,
    );

    // Left pad
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(71.195 * sx, 245.257 * sy),
        width: (113.55 - 28.839) * sx,
        height: (298.192 - 192.321) * sy,
      ),
      paint,
    );

    // Main paw — approximate the SVG path as an oval
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(255.996 * sx, 357.022 * sy),
        width: (361.867 - 150.125) * sx,
        height: (454.071 - 259.973) * sy,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PawPainter old) => old.color != color;
}
