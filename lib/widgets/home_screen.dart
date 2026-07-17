import 'package:better_thermal/components/alert.dart';
import 'package:better_thermal/styles/themes.dart';
import 'package:flutter/material.dart';
import 'package:better_thermal/services/device.dart';
import 'package:better_thermal/widgets/connect_button.dart';
import 'package:better_thermal/widgets/fps_text.dart';
import 'package:better_thermal/widgets/live_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeviceService _deviceService = DeviceService(
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
    _deviceService.disconnect();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              StreamBuilder(
                stream: _deviceService.statusStream,
                builder: (context, snapshot) {
                  final status = _deviceService.status;
                  if (status == DeviceStatus.error) {
                    return const Alert(
                      type: .danger,
                      message:
                          'Failed to connect to device. Click connect to device to try again.',
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LiveImageCanvas(deviceService: _deviceService),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FpsText(deviceService: _deviceService),
              ),
              ConnectButton(deviceService: _deviceService),
            ],
          ),
        ),
      ),
    );
  }
}
