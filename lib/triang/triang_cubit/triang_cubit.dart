import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'triang_state.dart';

class TriangCubit extends Cubit<TriangState> {
  TriangCubit() : super(const TriangDrawPoints(points: []));

  List<Offset> points = [];

  void drawPoints((double, double) xdiap, (double, double) ydiap, int pCount) {
    emit(const TriangLoading());
    Random random = Random();
    points = [];
    for (var i = 0; i < pCount; i++) {
      double dx = xdiap.$1 + random.nextDouble() * (xdiap.$2 - xdiap.$1);
      double dy = ydiap.$1 + random.nextDouble() * (ydiap.$2 - ydiap.$1);
      points.add(Offset(dx, dy));
    }
    emit(TriangDrawPoints(points: points));
  }

  void drawLines() {
    emit(const TriangLoading());

    var lines = delanunayTriangulation(points);

    emit(TriangDrawLines(lines: lines));
  }
}

List<(Offset, Offset)> delanunayTriangulation(List<Offset> points) {
  List<(Offset, Offset)> liveEdges = [];
  List<(Offset, Offset)> deadEdges = [];

  points.sort((a, b) => a.dx.compareTo(b.dx));
  //Offset firstPoint = points.removeAt(0);
  Offset firstPoint = points[0];

  int secondPointIdx = 1;
  for (int i = 2; i < points.length; i++) {
    if (isClockwise(firstPoint, points[secondPointIdx], points[i])) {
      secondPointIdx = i;
    }
  }

  //liveEdges.add((firstPoint, points.removeAt(secondPointIdx)));
  liveEdges.add((firstPoint, points[secondPointIdx]));

  while (liveEdges.isNotEmpty) {
    var edge = liveEdges.removeLast();
    int minIdx = -1;
    double minDist = double.infinity;
    var rPoints = findPointsToTheRight(points, edge);
    for (int i = 0; i < rPoints.length; i++) {
      if (isDegenerateTriangle(edge.$1, edge.$2, rPoints[i])) continue;

      var cc = findCircumcenter(edge.$1, edge.$2, rPoints[i]);
      double dist = 0;
      // for (int j = 0; j < rPoints.length; j++) {
      //   if (j == i) continue;
      //   //dist += cc.dx + cc.dy - rPoints[j].dx - rPoints[j].dy;
      //   dist += cc.dx -
      //       rPoints[j].dx +
      //       sqrt((cc.dy - rPoints[j].dy) * (cc.dy - rPoints[j].dy));
      // }
      var mPoint =
          Offset((edge.$1.dx + edge.$2.dx) / 2, (edge.$1.dy + edge.$2.dy) / 2);
      dist +=
          cc.dx - mPoint.dx + sqrt((cc.dy - mPoint.dy) * (cc.dy - mPoint.dy));

      if (dist < minDist) {
        minIdx = i;
        minDist = dist;
      }
    }

    deadEdges.add(edge);
    if (minIdx == -1) {
      continue;
    }
    // var newPoint = rPoints.removeAt(minIdx);
    var newPoint = rPoints[minIdx];

    if (edge.$1.dx < newPoint.dx) {
      if (!deadEdges.contains((edge.$1, newPoint)) &&
          !liveEdges.contains((edge.$1, newPoint))) {
        liveEdges.add((edge.$1, newPoint));
      }
    } else {
      if (!deadEdges.contains((newPoint, edge.$1)) &&
          !liveEdges.contains((newPoint, edge.$1))) {
        liveEdges.add((newPoint, edge.$1));
      }
    }

    if (edge.$2.dx < newPoint.dx) {
      if (!deadEdges.contains((edge.$2, newPoint)) &&
          !liveEdges.contains((edge.$2, newPoint))) {
        liveEdges.add((edge.$2, newPoint));
      }
    } else {
      if (!deadEdges.contains((newPoint, edge.$2)) &&
          !liveEdges.contains((newPoint, edge.$2))) {
        liveEdges.add((newPoint, edge.$2));
      }
    }
    //points.remove(edge.$1);
    //points.remove(edge.$2);
  }

  return deadEdges;
}

bool isClockwise(Offset a, Offset b, Offset c) {
  double crossProduct =
      (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);
  return crossProduct < 0;
}

Offset findCircumcenter(Offset a, Offset b, Offset c) {
  double coef1 =
      a.dx * (b.dy - c.dy) + b.dx * (c.dy - a.dy) + c.dx * (a.dy - b.dy);
  double coef2 = (a.dx * a.dx + a.dy * a.dy) * (b.dy - c.dy) +
      (b.dx * b.dx + b.dy * b.dy) * (c.dy - a.dy) +
      (c.dx * c.dx + c.dy * c.dy) * (a.dy - b.dy);
  double coef3 = (a.dx * a.dx + a.dy * a.dy) * (c.dx - b.dx) +
      (b.dx * b.dx + b.dy * b.dy) * (a.dx - c.dx) +
      (c.dx * c.dx + c.dy * c.dy) * (b.dx - a.dx);

  double centerX = coef2 / (2 * coef1);
  double centerY = coef3 / (2 * coef1);

  return Offset(centerX, centerY);
}

bool isDegenerateTriangle(Offset a, Offset b, Offset c) {
  double area = 0.5 *
      ((a.dx * (b.dy - c.dy)) + (b.dx * (c.dy - a.dy)) + (c.dx * (a.dy - b.dy)))
          .abs();
  return area < 1e-10;
}

List<Offset> findPointsToTheRight(List<Offset> points, (Offset, Offset) edge) {
  List<Offset> rightPoints = [];

  for (Offset point in points) {
    if (isPointToTheRight(point, edge)) {
      rightPoints.add(point);
    }
  }

  return rightPoints;
}

bool isPointToTheRight(Offset point, (Offset, Offset) edge) {
  double determinant = (edge.$2.dx - edge.$1.dx) * (point.dy - edge.$1.dy) -
      (edge.$2.dy - edge.$1.dy) * (point.dx - edge.$1.dx);

  return determinant > 0;
}
