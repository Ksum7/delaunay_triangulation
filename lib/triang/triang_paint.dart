import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MidpointPainter extends CustomPainter {
  final List<Offset> points;

  const MidpointPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final curvePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 1; i < points.length; i++) {
      canvas.drawLine(points[i - 1], points[i], curvePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
