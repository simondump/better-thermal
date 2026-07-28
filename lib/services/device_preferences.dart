import 'package:better_thermal/config/devices.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevicePreferences {
  static const String _selectedDeviceKey = 'selected_device';

  static Future<UNITDevice?> loadSelectedDevice() async {
    final preferences = await SharedPreferences.getInstance();
    final selectedName = preferences.getString(_selectedDeviceKey);

    if (selectedName == null) {
      return null;
    }

    return UNITDevice.devices.firstWhere(
      (device) => device.name == selectedName,
    );
  }

  static Future<void> saveSelectedDevice(UNITDevice device) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_selectedDeviceKey, device.name);
  }
}
