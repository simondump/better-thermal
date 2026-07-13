import 'package:flutter/material.dart';
import 'package:uti_thermal_app/services/device.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

const host = '192.168.16.10';
const port = 9527;

class LiveImageCanvas extends StatefulWidget {
  const LiveImageCanvas({super.key});

  @override
  State<LiveImageCanvas> createState() => _LiveImageCanvasState();
}

class _LiveImageCanvasState extends State<LiveImageCanvas> {
  DeviceService? _deviceService;

  late final int _frameWidth = 400;
  late final int _frameHeight = 300;

  ui.Image? _latestFrame;

  @override
  void initState() {
    super.initState();

    _deviceService = DeviceService(
      host: host,
      port: port,
      frameWidth: _frameWidth,
      frameHeight: _frameHeight,
      onStatusChanged: (status) {
        if (!mounted) return;
      },
      onFrameReceived: (frameBytes) {
        _decodeAndPublishFrame(frameBytes);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _deviceService!.dispose();
  }

  void _decodeAndPublishFrame(Uint8List rgbaFrame) {
    ui.decodeImageFromPixels(
      rgbaFrame,
      _frameWidth,
      _frameHeight,
      ui.PixelFormat.rgba8888,
      (ui.Image image) {
        if (!mounted) {
          image.dispose();
          return;
        }

        setState(() {
          _latestFrame?.dispose();
          _latestFrame = image;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: _frameWidth / _frameHeight,
          child: CustomPaint(
            painter: _LiveImagePainter(image: _latestFrame),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _LiveImagePainter extends CustomPainter {
  const _LiveImagePainter({required this.image});

  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    if (image != null) {
      final sourceRect = Rect.fromLTWH(
        0,
        0,
        image!.width.toDouble(),
        image!.height.toDouble(),
      );
      final destinationRect = Offset.zero & size;
      canvas.drawImageRect(image!, sourceRect, destinationRect, Paint());
    }
  }

  @override
  bool shouldRepaint(covariant _LiveImagePainter oldDelegate) {
    return oldDelegate.image != image;
  }
}
