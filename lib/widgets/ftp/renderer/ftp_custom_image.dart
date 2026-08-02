import 'dart:typed_data';

import 'package:better_thermal/services/ftp_service/directory_entry_file.dart';
import 'package:better_thermal/widgets/ftp/renderer/ftp_thermal_gradient.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'ftp_image_renderer.dart';

class FtpCustomImage extends FtpImageRenderer {
  const FtpCustomImage({
    super.key,
    required this.samples,
    required this.width,
    required this.height,
  });

  final List<ThermalSample> samples;
  final int width;
  final int height;

  @override
  Uint8List getImageJpeg() {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Image dimensions must be positive');
    }

    final colors = renderThermalSamples(samples, width, height);
    final output = img.Image(width: width, height: height);
    for (var index = 0; index < colors.length; index++) {
      final color = colors[index];
      output.setPixelRgb(
        index % width,
        index ~/ width,
        (color.r * 255).round().clamp(0, 255),
        (color.g * 255).round().clamp(0, 255),
        (color.b * 255).round().clamp(0, 255),
      );
    }

    return Uint8List.fromList(img.encodeJpg(output));
  }

  @override
  Widget build(BuildContext context) {
    final temperatureRange = _temperatureRange(samples, width, height);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (width > 0 && height > 0)
          AspectRatio(
            aspectRatio: width / height,
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(4),
              child: CustomPaint(
                painter: _ThermalSamplesPainter(
                  samples: samples,
                  width: width,
                  height: height,
                ),
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        const SizedBox(height: 8),
        FtpThermalGradient(
          minimum: temperatureRange?.minimum,
          maximum: temperatureRange?.maximum,
        ),
      ],
    );
  }
}

List<Color> renderThermalSamples(
  List<ThermalSample> samples,
  int width,
  int height,
) {
  if (samples.isEmpty || width <= 0 || height <= 0) return const [];

  final count = samples.length < width * height
      ? samples.length
      : width * height;
  var minimum = samples.first.celsius;
  var maximum = minimum;
  for (var index = 1; index < count; index++) {
    final value = samples[index].celsius;
    if (value < minimum) minimum = value;
    if (value > maximum) maximum = value;
  }

  final difference = maximum - minimum;
  return [
    for (var index = 0; index < count; index++)
      _colorForTemperature(samples[index].celsius, minimum, difference),
  ];
}

Color _colorForTemperature(double value, double minimum, double difference) {
  final normalized = difference == 0
      ? 0.5
      : ((value - minimum) / difference).clamp(0.0, 1.0);
  final scaled = normalized * (ThermalColorScale.colors.length - 1);
  final lower = scaled.floor().clamp(0, ThermalColorScale.colors.length - 2);
  return Color.lerp(
    ThermalColorScale.colors[lower],
    ThermalColorScale.colors[lower + 1],
    scaled - lower,
  )!;
}

class _TemperatureRange {
  const _TemperatureRange(this.minimum, this.maximum);

  final double minimum;
  final double maximum;
}

_TemperatureRange? _temperatureRange(
  List<ThermalSample> samples,
  int width,
  int height,
) {
  if (samples.isEmpty || width <= 0 || height <= 0) return null;

  final count = samples.length < width * height
      ? samples.length
      : width * height;
  var minimum = samples.first.celsius;
  var maximum = minimum;

  for (var index = 1; index < count; index++) {
    final value = samples[index].celsius;
    if (value < minimum) minimum = value;
    if (value > maximum) maximum = value;
  }

  return _TemperatureRange(minimum, maximum);
}

class _ThermalSamplesPainter extends CustomPainter {
  _ThermalSamplesPainter({
    required this.samples,
    required this.width,
    required this.height,
  });

  final List<ThermalSample> samples;
  final int width;
  final int height;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = renderThermalSamples(samples, width, height);
    if (colors.isEmpty) return;

    final pixelWidth = size.width / width;
    final pixelHeight = size.height / height;
    final paint = Paint();

    for (var index = 0; index < colors.length; index++) {
      paint.color = colors[index];

      final x = index % width;
      final y = index ~/ width;
      canvas.drawRect(
        Rect.fromLTWH(
          x * pixelWidth,
          y * pixelHeight,
          pixelWidth + 0.5,
          pixelHeight + 0.5,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ThermalSamplesPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}
