import 'package:bezier_curves/bezier/bezier_bloc/bezier_bloc.dart';
import 'package:bezier_curves/bezier/bezier_paint.dart';
import 'package:bezier_curves/bezier/bezier_tab.dart';
import 'package:bezier_curves/midpoint/midpoint_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Material(child: HomePage()),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Tab();
  }
}
