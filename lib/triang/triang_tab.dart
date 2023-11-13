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
                        BlocProvider.of<TriangCubit>(context).drawPoints(
                            (100, constraints.maxWidth - 100),
                            (100, constraints.maxHeight - 100),
                            pCount);
                      },
                      triangulate: () {
                        BlocProvider.of<TriangCubit>(context).drawLines();
                      },
                    ),
                    Expanded(
                      child: ClipRRect(
                        child: CustomPaint(
                          foregroundPainter: TriangPainter(
                            points:
                                state is TriangDrawPoints ? state.points : null,
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
                  ],
                );
        }),
      );
    });
  }
}

class _DrawSettings extends StatefulWidget {
  final Function createPoints;
  final Function triangulate;

  const _DrawSettings({required this.createPoints, required this.triangulate});

  @override
  _DrawSettingsState createState() => _DrawSettingsState();
}

class _DrawSettingsState extends State<_DrawSettings> {
  bool isPointsDrawed = false;
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
            isPointsDrawed = true;
            widget.createPoints(_pCounter);
          },
          child: const Text('Создать точки'),
        ),
        const SizedBox(
          width: 50,
        ),
        isPointsDrawed
            ? ElevatedButton(
                onPressed: () {
                  widget.triangulate();
                },
                child: const Text('Триангулировать'),
              )
            : const SizedBox.shrink()
      ],
    );
  }
}
