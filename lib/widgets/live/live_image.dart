import 'package:flutter/material.dart';
import 'package:better_thermal/services/live_stream_service/live_stream_service.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class LiveImageCanvas extends StatefulWidget {
  final LiveStreamService liveStreamService;

  const LiveImageCanvas({super.key, required this.liveStreamService});

  @override
  State<LiveImageCanvas> createState() =>
      _LiveImageCanvasState(liveStreamService: liveStreamService);
}

class _LiveImageCanvasState extends State<LiveImageCanvas> {
  final LiveStreamService _liveStreamService;

  ui.Image? _latestFrame;

  _LiveImageCanvasState({required this._liveStreamService});

  @override
  void initState() {
    super.initState();

    _liveStreamService.frameStream.listen((Uint8List rgbaFrame) {
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
      _liveStreamService.width,
      _liveStreamService.height,
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
          aspectRatio: _liveStreamService.width / _liveStreamService.height,
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
