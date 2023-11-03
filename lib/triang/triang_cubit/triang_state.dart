part of 'midpoint_cubit.dart';

@immutable
sealed class MidpointState {
  const MidpointState();
}

final class MidpointDraw extends MidpointState {
  const MidpointDraw({required this.points});

  final List<Offset> points;
}

final class MidpointLoading extends MidpointState {
  const MidpointLoading();
}
