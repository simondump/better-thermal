import 'package:flutter/material.dart';
import 'package:uti_thermal_app/widgets/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTI Thermal Viewer',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
