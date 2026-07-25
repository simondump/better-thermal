import 'package:flutter/material.dart';
import 'package:better_thermal/services/live_stream_service/live_stream_service.dart';

class _ButtonConfig {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  const _ButtonConfig({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });
}

class ConnectButton extends StatelessWidget {
  final LiveStreamService deviceService;

  const ConnectButton({super.key, required this.deviceService});

  Map<LiveStreamStatus, _ButtonConfig> _getConfigMap(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = _ButtonConfig(
      text: 'Connect to device',
      icon: Icons.wifi,
      backgroundColor: colors.tertiary,
      foregroundColor: colors.onTertiary,
    );

    return {
      LiveStreamStatus.connecting: _ButtonConfig(
        text: 'Connecting...',
        icon: Icons.wifi_off,
        backgroundColor: colors.secondary,
        foregroundColor: colors.onSecondary,
      ),
      LiveStreamStatus.connected: _ButtonConfig(
        text: 'Disconnect',
        icon: Icons.wifi_off,
        backgroundColor: colors.error,
        foregroundColor: colors.onError,
      ),
      LiveStreamStatus.disconnected: base,
      LiveStreamStatus.error: base,
    };
  }

  void _toggleConnection() {
    if (deviceService.status == LiveStreamStatus.connecting) {
      return;
    }

    if (deviceService.status == LiveStreamStatus.error ||
        deviceService.status == LiveStreamStatus.disconnected) {
      deviceService.connect();
    } else {
      deviceService.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LiveStreamStatus>(
      stream: deviceService.statusStream,
      initialData: deviceService.status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? LiveStreamStatus.disconnected;
        final config = _getConfigMap(context)[status]!;

        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: config.backgroundColor,
            foregroundColor: config.foregroundColor,
          ),
          onPressed: _toggleConnection,
          label: Text(config.text),
          icon: Icon(config.icon),
        );
      },
    );
  }
}
