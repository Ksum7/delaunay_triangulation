import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TriangPainter extends CustomPainter {
  final List<Offset>? points;
  final List<(Offset, Offset)>? lines;

  const TriangPainter({this.points, this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (points != null) {
      canvas.drawPoints(PointMode.points, points!, pointPaint);
    }

    if (lines != null) {
      var i = 1.0;
      for (var el in lines!) {
        canvas.drawLine(el.$1, el.$2, linePaint);
        canvas.drawCircle(
            Offset((el.$1.dx + el.$2.dx) / 2, (el.$1.dy + el.$2.dy) / 2),
            i++,
            linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
