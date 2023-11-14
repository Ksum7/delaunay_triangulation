import 'dart:ffi';

import 'package:dt/triang/triang_cubit/triang_cubit.dart';
import 'package:dt/triang/triang_paint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

class TriangTab extends StatelessWidget {
  const TriangTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return BlocProvider<TriangCubit>(
        create: (context) => TriangCubit(),
        child: BlocBuilder<TriangCubit, TriangState>(builder: (context, state) {
          return state is TriangLoading
              ? const Center(
                  child: SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator()),
                )
              : Column(
                  children: [
                    _DrawSettings(
                      createPoints: (int pCount) {
                        BlocProvider.of<TriangCubit>(context).addPoints(
                            (100, constraints.maxWidth - 100),
                            (100, constraints.maxHeight - 100),
                            pCount);
                      },
                      triangulate: () {
                        BlocProvider.of<TriangCubit>(context).drawLines();
                      },
                      clearPoints: () {
                        BlocProvider.of<TriangCubit>(context).clearPoints();
                      },
                    ),
                    Expanded(
                      child: ClipRRect(
                        child: GestureDetector(
                          onPanDown: (details) {
                            BlocProvider.of<TriangCubit>(context)
                                .addPoint(details.localPosition);
                          },
                          child: CustomPaint(
                            foregroundPainter: TriangPainter(
                              points: state is TriangDrawPoints
                                  ? state.points
                                  : (state as TriangDrawLines).points,
                              lines:
                                  state is TriangDrawLines ? state.lines : null,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        }),
      );
    });
  }
}

class _DrawSettings extends StatefulWidget {
  final Function createPoints;
  final Function clearPoints;
  final Function triangulate;

  const _DrawSettings(
      {required this.createPoints,
      required this.clearPoints,
      required this.triangulate});

  @override
  _DrawSettingsState createState() => _DrawSettingsState();
}

class _DrawSettingsState extends State<_DrawSettings> {
  int _pCounter = 0;
  var counterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 50,
        ),
        const Text('Количество точек:'),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 30,
          child: TextField(
            controller: counterController..text = _pCounter.toString(),
            onChanged: (value) {
              _pCounter = int.tryParse(value) ?? 0;
            },
          ),
        ),
        const SizedBox(
          width: 50,
        ),
        ElevatedButton(
          onPressed: () {
            widget.createPoints(_pCounter);
          },
          child: const Text('Создать точки'),
        ),
        const SizedBox(
          width: 50,
        ),
        ElevatedButton(
          onPressed: () {
            widget.clearPoints();
          },
          child: const Text('Очистить'),
        ),
        const SizedBox(
          width: 50,
        ),
        ElevatedButton(
          onPressed: () {
            widget.triangulate();
          },
          child: const Text('Триангулировать'),
        ),
      ],
    );
  }
}
