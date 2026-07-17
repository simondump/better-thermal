import 'package:flutter/material.dart';
import 'package:better_thermal/services/device.dart';
import 'package:better_thermal/styles/themes.dart';

class FpsText extends StatefulWidget {
  final DeviceService deviceService;

  const FpsText({super.key, required this.deviceService});

  @override
  State<FpsText> createState() => _FpsTextState();
}

class _FpsTextState extends State<FpsText> {
  late DeviceStatus _currentStatus;
  double? _currentFps;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.deviceService.status;

    widget.deviceService.statusStream.listen((status) {
      setState(() {
        _currentStatus = status;
      });
    });

    widget.deviceService.fpsConnector.listen((fps) {
      setState(() {
        _currentFps = fps;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDisconnected = _currentStatus == DeviceStatus.disconnected;

    final fpsText = isDisconnected
        ? 'N/A'
        : _currentFps?.toStringAsFixed(1) ?? 'N/A';

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'FPS: $fpsText',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: context.theme.colors.onBackground,
        ),
      ),
    );
  }
}
