import 'package:better_thermal/components/alert.dart';
import 'package:better_thermal/styles/themes.dart';
import 'package:better_thermal/widgets/connection_stats_text.dart';
import 'package:flutter/material.dart';
import 'package:better_thermal/services/live_stream.dart';
import 'package:better_thermal/widgets/connect_button.dart';
import 'package:better_thermal/widgets/live_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LiveStreamService _liveStreamService = LiveStreamService(
    host: '192.168.16.10',
    port: 9527,
    frameWidth: 400,
    frameHeight: 300,
  );

  @override
  void activate() {
    super.activate();
  }

  @override
  void dispose() {
    _liveStreamService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.theme.colors.background,
        systemOverlayStyle: context.theme.systemUiOverlayStyle,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              StreamBuilder(
                stream: _liveStreamService.statusStream,
                builder: (context, snapshot) {
                  return AnimatedOpacity(
                    opacity: _liveStreamService.status == DeviceStatus.error
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
                child: LiveImageCanvas(liveStreamService: _liveStreamService),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: ConnectionStatsText(deviceService: _liveStreamService),
              ),
              ConnectButton(deviceService: _liveStreamService),
            ],
          ),
        ),
      ),
    );
  }
}
