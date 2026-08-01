import 'package:flutter/material.dart';

class FtpThermalGradient extends StatelessWidget {
  const FtpThermalGradient({
    super.key,
    required this.minimum,
    required this.maximum,
  });

  final double? minimum;
  final double? maximum;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Container(
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(colors: ThermalColorScale.colors),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatTemperature(minimum), style: textStyle),
            Text(_formatTemperature(maximum), style: textStyle),
          ],
        ),
      ],
    );
  }

  String _formatTemperature(double? value) {
    return value == null ? '--' : '${value.toStringAsFixed(1)} °C';
  }
}

class ThermalColorScale {
  const ThermalColorScale._();

  static const colors = [
    Color(0xff000000), // Black (coldest)
    Color(0xff00008b), // Dark blue
    Color(0xff0000ff), // Blue
    Color(0xff00ffff), // Cyan (light blue)
    Color(0xff00ff00), // Green
    Color(0xffffff00), // Yellow
    Color(0xffff7f00), // Orange
    Color(0xffff0000), // Red
    Color(0xffff00ff), // Magenta / Pink
    Color(0xffffffff), // White (hottest)
  ];
}
