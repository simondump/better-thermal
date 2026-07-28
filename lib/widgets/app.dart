import 'package:better_thermal/config/devices.dart';
import 'package:better_thermal/services/ftp_service/ftp_service.dart';
import 'package:better_thermal/services/device_preferences.dart';
import 'package:better_thermal/services/live_stream_service/live_stream_service.dart';
import 'package:better_thermal/widgets/ftp/fpt_screen.dart';
import 'package:better_thermal/widgets/live/live_stream.dart';
import 'package:better_thermal/widgets/settings/settings.dart';
import 'package:flutter/material.dart';

class AppNavigationItem {
  final String label;
  final IconData icon;
  final Widget screen;

  const AppNavigationItem({
    required this.label,
    required this.icon,
    required this.screen,
  });
}

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  final UNITDevice _defaultDevice = UNITDevice.devices[1];

  late UNITDevice _selectedDevice = _defaultDevice;
  late LiveStreamService _liveStreamService;
  late FtpService _ftpService;

  bool _isReady = false;

  List<AppNavigationItem> get _navigationItems =>
      [
        AppNavigationItem(
          label: 'Live Stream',
          icon: Icons.live_tv,
          screen: LiveStream(liveStreamService: _liveStreamService),
        ),
        AppNavigationItem(
          label: 'Saved Images',
          icon: Icons.image,
          screen: FtpScreen(ftpService: _ftpService),
        ),
        AppNavigationItem(
          label: 'Settings',
          icon: Icons.settings,
          screen: SettingsScreen(
            selectedDevice: _selectedDevice,
            onDeviceSelected: _setSelectedDevice,
          ),
        ),
      ];

  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSelectedDevice();
  }

  Future<void> _loadSelectedDevice() async {
    final device = await DevicePreferences.loadSelectedDevice();
    if (!mounted) return;

    _configureServices(device ?? _defaultDevice);
  }

  void _configureServices(UNITDevice device) {
    _ftpService = FtpService(host: device.ftpHost, port: device.ftpPort);
    _liveStreamService = LiveStreamService(
      host: device.serverIp,
      port: device.serverPort,
      width: 400,
      height: 300,
    );

    setState(() {
      _selectedDevice = device;
      _isReady = true;
    });
  }

  Future<void> _setSelectedDevice(UNITDevice device) async {
    await DevicePreferences.saveSelectedDevice(device);
    if (!mounted) return;

    _liveStreamService.disconnect();
    _configureServices(device);
  }

  @override
  void dispose() {
    if (_isReady) {
      _liveStreamService.disconnect();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_navigationItems[currentPageIndex].label)),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: _navigationItems
            .map(
              (item) =>
              NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
        )
            .toList(),
      ),
      body: Column(
        children: [
          _DeviceBanner(device: _selectedDevice),
          Expanded(
            child: IndexedStack(
              index: currentPageIndex,
              children: _navigationItems.map((item) => item.screen).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceBanner extends StatelessWidget {
  final UNITDevice device;

  const _DeviceBanner({required this.device});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme
          .of(context)
          .colorScheme
          .secondaryContainer,
      child: SizedBox(
        width: double.infinity,
        height: 32,
        child: Center(
          child: Text(
            'Device: ${device.name}',
            style: TextStyle(
              color: Theme
                  .of(context)
                  .colorScheme
                  .onSecondaryContainer,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
