import 'package:better_thermal/components/alert.dart';
import 'package:better_thermal/widgets/live/live_stats_text.dart';
import 'package:flutter/material.dart';
import 'package:better_thermal/services/live_stream_service/live_stream_service.dart';
import 'package:better_thermal/widgets/live/connect_button.dart';
import 'package:better_thermal/widgets/live/live_image.dart';
import 'package:share_plus/share_plus.dart';

class LiveStream extends StatefulWidget {
  final LiveStreamService liveStreamService;

  const LiveStream({super.key, required this.liveStreamService});

  @override
  State<LiveStream> createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> {
  final _liveImageKey = GlobalKey<LiveImageCanvasState>();

  Future<void> _shareCurrentFrame() async {
    if (!mounted) {
      return;
    }

    final jpegBytes = _liveImageKey.currentState?.getCurrentFrameJpeg();
    if (jpegBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There is no live frame to share yet.')),
      );

      return;
    }

    final file = XFile.fromData(
      jpegBytes,
      name: 'thermal-image.jpg',
      mimeType: 'image/jpeg',
    );

    await SharePlus.instance.share(
      ShareParams(files: [file], subject: 'Thermal camera image'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liveStreamService = super.widget.liveStreamService;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(left: 8, right: 8),
          margin: const EdgeInsets.only(bottom: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              StreamBuilder(
                stream: liveStreamService.statusStream,
                builder: (context, snapshot) {
                  return AnimatedOpacity(
                    opacity: liveStreamService.status == LiveStreamStatus.error
                        ? 1
                        : 0,
                    duration: const Duration(milliseconds: 150),
                    child: const Alert(
                      type: .danger,
                      message:
                          'Failed to connect to device. Click connect to device to try again.',
                    ),
                  );
                },
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LiveImageCanvas(
                  key: _liveImageKey,
                  liveStreamService: liveStreamService,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: LiveStatsText(deviceService: liveStreamService),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConnectButton(deviceService: liveStreamService),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _shareCurrentFrame,
                    icon: const Icon(Icons.camera),
                    label: const Text('Share current image'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
