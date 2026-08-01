import 'package:better_thermal/services/ftp_service/directory_entry_file.dart';
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
    return AspectRatio(
      aspectRatio: width / height,
      child: CustomPaint(
        painter: _ThermalSamplesPainter(
          samples: samples,
          width: width,
          height: height,
        ),
      ),
    );
  }
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

    final sampleCount = width * height;
    final count = samples.length < sampleCount ? samples.length : sampleCount;
    var minimum = samples.first.celsius;
    var maximum = minimum;

    for (var index = 1; index < count; index++) {
      final value = samples[index].celsius;
      if (value < minimum) minimum = value;
      if (value > maximum) maximum = value;
    }

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
    const colors = [
      Color(0xff0000ff),
      Color(0xff00ffff),
      Color(0xff00ff00),
      Color(0xffffff00),
      Color(0xffff0000),
    ];

    final scaled = value * (colors.length - 1);
    final lower = scaled.floor().clamp(0, colors.length - 2);
    final upper = lower + 1;
    return Color.lerp(colors[lower], colors[upper], scaled - lower)!;
  }

  @override
  bool shouldRepaint(covariant _ThermalSamplesPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}
