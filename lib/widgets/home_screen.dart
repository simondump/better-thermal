import 'package:flutter/material.dart';
import 'package:uti_thermal_app/services/device.dart';
import 'package:uti_thermal_app/widgets/connect_button.dart';
import 'package:uti_thermal_app/widgets/fps_text.dart';
import 'package:uti_thermal_app/widgets/live_image.dart';

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

  void _toggleConnection() {
    if (_deviceService.status == DeviceStatus.disconnected) {
      _deviceService.connect();
    } else {
      _deviceService.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LiveImageCanvas(deviceService: _deviceService),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FpsText(deviceService: _deviceService),
              ),
              ConnectButton(
                deviceService: _deviceService,
                onPressed: _toggleConnection,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
