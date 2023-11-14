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

    if (lines != null) {
      for (var el in lines!) {
        canvas.drawLine(el.$1, el.$2, linePaint);
      }
    }

    if (points != null) {
      canvas.drawPoints(PointMode.points, points!, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
