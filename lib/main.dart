import 'package:better_thermal/widgets/app.dart';
import 'package:flutter/material.dart';

void main() {
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
