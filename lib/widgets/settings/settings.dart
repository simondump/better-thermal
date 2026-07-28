import 'package:better_thermal/config/devices.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Device', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<UNITDevice>(
              initialValue: widget.selectedDevice,
              decoration: const InputDecoration(
                labelText: 'Thermal camera',
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
        ),
        if (_isSaving) ...[
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}
