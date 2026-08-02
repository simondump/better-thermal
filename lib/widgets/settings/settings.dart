import 'package:better_thermal/components/alert.dart';
import 'package:better_thermal/config/devices.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

const _sourceUrl = 'https://github.com/simonwep/better-thermal';
const _sponsorsUrl = 'https://github.com/sponsors/simonwep';

const _buildVersion = String.fromEnvironment(
  'FLUTTER_BUILD_NAME',
  defaultValue: '1.0.0',
);

const _buildNumber = String.fromEnvironment(
  'FLUTTER_BUILD_NUMBER',
  defaultValue: '1',
);

class SettingsScreen extends StatefulWidget {
  final UNITDevice selectedDevice;
  final Future<void> Function(UNITDevice device) onDeviceSelected;

  const SettingsScreen({
    super.key,
    required this.selectedDevice,
    required this.onDeviceSelected,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSaving = false;

  Future<void> _selectDevice(UNITDevice? device) async {
    if (device == null || device == widget.selectedDevice || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onDeviceSelected(device);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 8,
        children: [
          Text('Device', style: Theme.of(context).textTheme.titleLarge),
          Card(
            child: DropdownButtonFormField<UNITDevice>(
              initialValue: widget.selectedDevice,
              decoration: const InputDecoration(
                labelText: 'Device model',
                border: OutlineInputBorder(),
              ),
              items: UNITDevice.devices
                  .map(
                    (device) => DropdownMenuItem<UNITDevice>(
                      value: device,
                      child: Text(device.name),
                    ),
                  )
                  .toList(),
              onChanged: _isSaving ? null : _selectDevice,
            ),
          ),
          const Alert(
            type: .warning,
            message:
                'Make sure to turn on Wi-Fi on your device and connect to it from your phone. You may also need to disable mobile data on your phone to connect to the device.',
          ),
          Expanded(
            child: Column(
              spacing: 12,
              mainAxisAlignment: .end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 32, right: 32),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(fontWeight: .bold),
                      children: [
                        const TextSpan(
                          text: 'Build by Simon with ❤️ - consider ',
                        ),
                        TextSpan(
                          text: 'supporting me ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _openUrl(_sponsorsUrl),
                        ),
                        const TextSpan(text: ' if you like this app!'),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodySmall,
                      children: [
                        const TextSpan(
                          text: 'Build $_buildVersion ($_buildNumber) · ',
                        ),
                        TextSpan(
                          text: 'View on GitHub',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _openUrl(_sourceUrl),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
