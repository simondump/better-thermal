import 'package:better_thermal/extensions/file_size_extension.dart';
import 'package:flutter/material.dart';
import 'package:better_thermal/services/live_stream.dart';
import 'package:better_thermal/styles/themes.dart';

class LiveStatsText extends StatefulWidget {
  final LiveStreamService deviceService;

  const LiveStatsText({super.key, required this.deviceService});

  @override
  State<LiveStatsText> createState() => _LiveStatsTextState();
}

class _LiveStatsTextState extends State<LiveStatsText> {
  late DeviceStatus _currentStatus;
  double _currentKbps = 0;
  double _currentFps = 0;

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
        _currentKbps = (fps * widget.deviceService.bytesPerFrame * 8) / 1000;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDisconnected = _currentStatus == DeviceStatus.disconnected;

    final fpsText = isDisconnected ? 'N/A' : _currentFps.toStringAsFixed(1);
    final kbpsText = isDisconnected
        ? 'N/A'
        : '${_currentKbps.toHumanReadableFileSize()}/s';

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'FPS: $fpsText | Kbps: $kbpsText',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: context.theme.colors.onBackground,
        ),
      ),
    );
  }
}
