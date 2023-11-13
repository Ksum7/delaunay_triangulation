part of 'triang_cubit.dart';

@immutable
sealed class TriangState {
  const TriangState();
}

final class TriangDrawPoints extends TriangState {
  const TriangDrawPoints({required this.points});

  final List<Offset> points;
}

final class TriangDrawLines extends TriangState {
  const TriangDrawLines({required this.lines});

  final List<(Offset, Offset)> lines;
}

final class TriangLoading extends TriangState {
  const TriangLoading();
}
