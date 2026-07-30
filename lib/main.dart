import 'package:better_thermal/widgets/app.dart';
import 'package:flutter/material.dart';
import 'package:nativeapi/nativeapi.dart';

void main() {
  final window = WindowManager.instance.getCurrent();

  if (window != null) {
    window.setSize(450, 800);
    window.title = 'UNI-T Better Thermal';
    window.isResizable = false;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNI-T Thermal Viewer',
      theme: ThemeData.dark(useMaterial3: true),
      home: const AppScreen(),
    );
  }
}
