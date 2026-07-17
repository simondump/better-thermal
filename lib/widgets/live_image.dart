import 'package:flutter/material.dart';
import 'package:better_thermal/services/device.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class LiveImageCanvas extends StatefulWidget {
  final DeviceService deviceService;

  const LiveImageCanvas({super.key, required this.deviceService});

  @override
  State<LiveImageCanvas> createState() =>
      _LiveImageCanvasState(deviceService: deviceService);
}

class _LiveImageCanvasState extends State<LiveImageCanvas> {
  final DeviceService deviceService;

  ui.Image? _latestFrame;

  _LiveImageCanvasState({required this.deviceService});

  @override
  void initState() {
    super.initState();

    deviceService.frameStream.listen((Uint8List rgbaFrame) {
      _decodeAndPublishFrame(rgbaFrame);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _decodeAndPublishFrame(Uint8List rgbaFrame) {
    ui.decodeImageFromPixels(
      rgbaFrame,
      deviceService.frameWidth,
      deviceService.frameHeight,
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
          aspectRatio: deviceService.frameWidth / deviceService.frameHeight,
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
