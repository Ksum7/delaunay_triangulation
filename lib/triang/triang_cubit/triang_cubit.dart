import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'triang_state.dart';

class TriangCubit extends Cubit<TriangState> {
  TriangCubit() : super(const TriangDrawPoints(points: []));

  List<Offset> points = [];
  List<(Offset, Offset)> lines = [];

  void addPoints((double, double) xdiap, (double, double) ydiap, int pCount) {
    emit(const TriangLoading());
    Random random = Random();
    for (var i = 0; i < pCount; i++) {
      double dx = xdiap.$1 + random.nextDouble() * (xdiap.$2 - xdiap.$1);
      double dy = ydiap.$1 + random.nextDouble() * (ydiap.$2 - ydiap.$1);
      points.add(Offset(dx, dy));
    }
    emit(TriangDrawPoints(points: points));
  }

  void clearPoints() {
    emit(const TriangLoading());
    points = [];
    lines = [];
    emit(TriangDrawPoints(points: points));
  }

  void drawLines() {
    emit(const TriangLoading());
    if (points.length >= 3) {
      lines = delanunayTriangulation(points);
    } else {
      lines = [];
    }
    emit(TriangDrawLines(lines: lines, points: points));
  }

  void addPoint(Offset point) {
    emit(const TriangLoading());

    points.add(point);

    emit(TriangDrawLines(lines: lines, points: points));
  }
}

double calculateDeterminant(List<List<double>> matrix) {
  if (matrix.length != 3 || matrix.any((row) => row.length != 3)) {
    throw ArgumentError("Матрица должна быть размером 3x3");
  }

  double det = 0;

  det += matrix[0][0] * matrix[1][1] * matrix[2][2];
  det += matrix[0][1] * matrix[1][2] * matrix[2][0];
  det += matrix[0][2] * matrix[1][0] * matrix[2][1];
  det -= matrix[0][2] * matrix[1][1] * matrix[2][0];
  det -= matrix[0][0] * matrix[1][2] * matrix[2][1];
  det -= matrix[0][1] * matrix[1][0] * matrix[2][2];

  return det;
}

class Triangle {
  final Offset A, B, C;

  Triangle(this.A, this.B, this.C);
}

class Edge {
  final Offset start, end;

  Edge(this.start, this.end);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Edge &&
          runtimeType == other.runtimeType &&
          ((start == other.start && end == other.end) ||
              (start == other.end && end == other.start));

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

bool isClockwise(Offset a, Offset b, Offset c) {
  double crossProduct =
      (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);
  return crossProduct < 0;
}

List<Edge> findUniqueEdges(List<Triangle> triangles) {
  final edgeCount = HashMap<Edge, int>();

  for (final triangle in triangles) {
    final edges = [
      Edge(triangle.A, triangle.B),
      Edge(triangle.B, triangle.C),
      Edge(triangle.C, triangle.A),
    ];

    for (final edge in edges) {
      edgeCount[edge] = (edgeCount[edge] ?? 0) + 1;
    }
  }

  final uniqueEdges = <Edge>[];
  edgeCount.forEach((edge, count) {
    if (count == 1) {
      uniqueEdges.add(edge);
    }
  });

  return uniqueEdges;
}

bool isPointInsideCircumcircle(Offset A, Offset B, Offset C, Offset D) {
  if (isClockwise(A, B, C)) {
    (A, B) = (B, A);
  }

  double det = calculateDeterminant([
    [
      A.dx - D.dx,
      A.dy - D.dy,
      (pow(A.dx - D.dx, 2) + pow(A.dy - D.dy, 2)).toDouble()
    ],
    [
      B.dx - D.dx,
      B.dy - D.dy,
      (pow(B.dx - D.dx, 2) + pow(B.dy - D.dy, 2)).toDouble()
    ],
    [
      C.dx - D.dx,
      C.dy - D.dy,
      (pow(C.dx - D.dx, 2) + pow(C.dy - D.dy, 2)).toDouble()
    ],
  ]);

  return det > 0;
}

bool isPointInsideCircumcircle1(Offset A, Offset B, Offset C, Offset D) {
  var center = findCircumcenter(A, B, C);
  (center - A).distance;

  return (center - A).distance >= (center - D).distance;
}

List<(Offset, Offset)> bowyerWatson(List<Offset> points) {
  List<Triangle> triangles = [];

  double maxX = points.map((point) => point.dx).reduce(max);
  double maxY = points.map((point) => point.dy).reduce(max);
  double minX = points.map((point) => point.dx).reduce(min);
  double minY = points.map((point) => point.dy).reduce(min);

  double superSize = max(maxX - minX, maxY - minY) * 2;

  Offset superA = Offset(minX - superSize, minY - superSize);
  Offset superB = Offset(maxX + superSize, minY - superSize);
  Offset superC = Offset((minX + maxX) / 2, maxY + superSize);

  triangles.add(Triangle(superA, superB, superC));

  for (Offset point in points) {
    List<Triangle> badTriangles = [];

    for (Triangle triangle in triangles) {
      if (isPointInsideCircumcircle(
          triangle.A, triangle.B, triangle.C, point)) {
        badTriangles.add(triangle);
      }
    }

    List<Edge> polygon = findUniqueEdges(badTriangles);

    triangles.removeWhere((triangle) => badTriangles.contains(triangle));

    for (var edge in polygon) {
      triangles.add(Triangle(edge.start, edge.end, point));
    }
  }

  Set<Edge> res = {};
  for (var triangle in triangles) {
    res.add(Edge(triangle.A, triangle.B));
    res.add(Edge(triangle.A, triangle.C));
    res.add(Edge(triangle.C, triangle.B));
  }
  res.removeWhere((edge) =>
      edge.start == superA ||
      edge.end == superA ||
      edge.start == superB ||
      edge.end == superB ||
      edge.start == superC ||
      edge.end == superC);

  return res.map((e) => (e.start, e.end)).toList();
}

List<(Offset, Offset)> delanunayTriangulation(List<Offset> points) {
  return bowyerWatson(points);
}

List<(Offset, Offset)> delanunayTriangulation1(List<Offset> points) {
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
