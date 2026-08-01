import 'package:better_thermal/services/ftp_service/directory_entry_file.dart';
import 'package:better_thermal/widgets/ftp/renderer/ftp_thermal_gradient.dart';
import 'package:flutter/material.dart';

class FtpCustomImage extends StatelessWidget {
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
    if (samples.isEmpty || width <= 0 || height <= 0) return;

    final rangeValues = _temperatureRange(samples, width, height)!;
    final count = samples.length < width * height
        ? samples.length
        : width * height;
    final minimum = rangeValues.minimum;
    final maximum = rangeValues.maximum;

    final range = maximum - minimum;
    final pixelWidth = size.width / width;
    final pixelHeight = size.height / height;
    final paint = Paint();

    for (var index = 0; index < count; index++) {
      final value = samples[index].celsius;
      final normalized = range == 0
          ? 0.5
          : ((value - minimum) / range).clamp(0.0, 1.0);
      paint.color = _colorFor(normalized);

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

  Color _colorFor(double value) {
    final scaled = value * (ThermalColorScale.colors.length - 1);
    final lower = scaled.floor().clamp(0, ThermalColorScale.colors.length - 2);
    final upper = lower + 1;
    return Color.lerp(
      ThermalColorScale.colors[lower],
      ThermalColorScale.colors[upper],
      scaled - lower,
    )!;
  }

  @override
  bool shouldRepaint(covariant _ThermalSamplesPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}
