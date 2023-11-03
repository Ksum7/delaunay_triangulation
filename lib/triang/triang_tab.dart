import 'package:bezier_curves/midpoint/midpoint_cubit/midpoint_cubit.dart';
import 'package:bezier_curves/midpoint/midpoint_paint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

class Tab extends StatelessWidget {
  const Tab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return BlocProvider<MidpointCubit>(
        create: (context) => MidpointCubit(),
        child: BlocBuilder<MidpointCubit, MidpointState>(
            builder: (context, state) {
          return state is MidpointLoading
              ? const Center(
                  child: SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator()),
                )
              : Column(
                  children: [
                    _DrawSettings(
                      startOffset: Offset(0, constraints.maxHeight - 100),
                      endOffset: Offset(
                          constraints.maxWidth, constraints.maxHeight - 100),
                      onDrawPressed: (
                          {required Offset endOffset,
                          required double minStep,
                          required double roughness,
                          required Offset startOffset,
                          int? step}) {
                        BlocProvider.of<MidpointCubit>(context).draw(
                            startOffset, endOffset, roughness, minStep,
                            step: step);
                      },
                    ),
                    Expanded(
                      child: ClipRRect(
                        child: CustomPaint(
                          foregroundPainter: MidpointPainter(
                              points: (state as MidpointDraw).points),
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
  final void Function({
    required Offset startOffset,
    required Offset endOffset,
    required double roughness,
    required double minStep,
    int? step,
  }) onDrawPressed;
  final Offset startOffset;
  final Offset endOffset;

  const _DrawSettings(
      {required this.onDrawPressed,
      required this.startOffset,
      required this.endOffset});

  @override
  _DrawSettingsState createState() => _DrawSettingsState();
}

class _DrawSettingsState extends State<_DrawSettings> {
  bool isDrawed = false;
  double _step = 0;
  double _roughness = 1;
  double _min = 1;
  var minController = TextEditingController();
  var roughController = TextEditingController();

  num findSteps() {
    return pow(
            2,
            (log((widget.endOffset.dx - widget.startOffset.dx) / _min) / log(2))
                .floor()) -
        1;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 100,
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Step: ${_step.round()}'),
              Slider(
                value: _step,
                onChanged: (value) {
                  _step = value;
                  if (isDrawed) {
                    widget.onDrawPressed(
                        startOffset: widget.startOffset,
                        endOffset: widget.endOffset,
                        roughness: _roughness,
                        minStep: _min,
                        step: _step.round());
                  }
                },
                min: 0,
                max: findSteps().toDouble(),
                divisions: findSteps().toInt(),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 50,
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Roughness:'),
              SizedBox(
                child: TextField(
                  controller: roughController..text = _roughness.toString(),
                  onChanged: (value) {
                    _roughness = double.tryParse(value) ?? 0.0;
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 50,
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Min Step Len:'),
              TextField(
                controller: minController..text = _min.toString(),
                onChanged: (value) {
                  _min = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 50,
        ),
        ElevatedButton(
          onPressed: () {
            isDrawed = true;
            _step = findSteps().toDouble();
            widget.onDrawPressed(
                startOffset: widget.startOffset,
                endOffset: widget.endOffset,
                roughness: _roughness,
                minStep: _min);
          },
          child: const Text('Draw'),
        ),
      ],
    );
  }
}
