import 'package:flutter/material.dart';

class MultiArcPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  MultiArcPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 24.0;
    double spacing = 28.0;
    Offset center = Offset(size.width / 2, size.height);

    for (int i = 0; i < values.length; i++) {
      double radius = size.width / 2 - (i * spacing);

      Paint bgPaint = Paint()
        ..color = const Color(0xFF242424)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        3.14,
        3.14,
        false,
        bgPaint,
      );

      Paint activePaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        3.14 + (3.14 * (1 - values[i])),
        3.14 * values[i],
        false,
        activePaint,
      );
    }

    Paint linePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    final baselineY = size.height - 1;
    canvas.drawLine(
      Offset(0, baselineY),
      Offset(size.width, baselineY),
      linePaint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, baselineY),
      5,
      Paint()..color = const Color(0xFFE8D1AB),
    );
  }

  @override
  bool shouldRepaint(covariant MultiArcPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
