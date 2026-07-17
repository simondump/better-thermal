import 'package:flutter/material.dart';
import 'package:better_thermal/styles/themes.dart';
import 'package:better_thermal/widgets/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNI-T Thermal Viewer',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
