import 'package:flutter/material.dart';
import 'package:uti_thermal_app/services/device.dart';
import 'package:uti_thermal_app/styles/themes.dart';

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
  final DeviceService deviceService;
  final VoidCallback onPressed;

  const ConnectButton({
    super.key,
    required this.deviceService,
    required this.onPressed,
  });

  Map<DeviceStatus, _ButtonConfig> _getConfigMap(BuildContext context) {
    return {
      DeviceStatus.connecting: _ButtonConfig(
        text: 'Connecting...',
        icon: Icons.wifi_off,
        backgroundColor: context.theme.colors.warning,
        foregroundColor: context.theme.colors.onWarning,
      ),
      DeviceStatus.connected: _ButtonConfig(
        text: 'Disconnect',
        icon: Icons.wifi_off,
        backgroundColor: context.theme.colors.danger,
        foregroundColor: context.theme.colors.onSuccess,
      ),
      DeviceStatus.disconnected: _ButtonConfig(
        text: 'Connect to device',
        icon: Icons.wifi,
        backgroundColor: context.theme.colors.success,
        foregroundColor: context.theme.colors.onSuccess,
      ),
      DeviceStatus.error: _ButtonConfig(
        text: 'Error, retry connecting?',
        icon: Icons.error,
        backgroundColor: context.theme.colors.success,
        foregroundColor: context.theme.colors.onDanger,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DeviceStatus>(
      stream: deviceService.statusStream,
      initialData: deviceService.status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? DeviceStatus.disconnected;
        final config = _getConfigMap(context)[status]!;
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: config.backgroundColor,
            foregroundColor: config.foregroundColor,
          ),
          onPressed: onPressed,
          label: Text(config.text),
          icon: Icon(config.icon),
        );
      },
    );
  }
}
