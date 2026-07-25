import 'package:better_thermal/components/alert.dart';
import 'package:better_thermal/widgets/live/live_stats_text.dart';
import 'package:flutter/material.dart';
import 'package:better_thermal/services/live_stream_service/live_stream_service.dart';
import 'package:better_thermal/widgets/live/connect_button.dart';
import 'package:better_thermal/widgets/live/live_image.dart';

class LiveStream extends StatefulWidget {
  final LiveStreamService liveStreamService;

  const LiveStream({super.key, required this.liveStreamService});

  @override
  State<LiveStream> createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> {
  @override
  Widget build(BuildContext context) {
    final liveStreamService = super.widget.liveStreamService;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
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
                child: LiveImageCanvas(liveStreamService: liveStreamService),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: LiveStatsText(deviceService: liveStreamService),
              ),
              ConnectButton(deviceService: liveStreamService),
            ],
          ),
        ),
      ),
    );
  }
}
