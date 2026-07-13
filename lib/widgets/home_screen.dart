import 'package:flutter/material.dart';
import 'package:uti_thermal_app/services/device.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('UTI Thermal TCP Viewer'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LiveImageCanvas(deviceService: _deviceService),
          ),
        ),
      ),
    );
  }
}
