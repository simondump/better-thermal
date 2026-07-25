import 'package:better_thermal/services/ftp_service/ftp_service.dart';
import 'package:better_thermal/services/live_stream_service/live_stream_service.dart';
import 'package:better_thermal/widgets/ftp/fpt_screen.dart';
import 'package:better_thermal/widgets/live/live_stream.dart';
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
  final FtpService _ftpService = FtpService(host: '192.168.16.10', port: 9528);
  final LiveStreamService _liveStreamService = LiveStreamService(
    host: '192.168.16.10',
    port: 9527,
    width: 400,
    height: 300,
  );

  late final List<AppNavigationItem> _navigationItems = [
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
  ];

  int currentPageIndex = 0;

  @override
  void activate() {
    super.activate();
  }

  @override
  void dispose() {
    super.dispose();
    _liveStreamService.disconnect();
  }

  @override
  Widget build(BuildContext context) {
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
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: _navigationItems.map((item) => item.screen).toList(),
      ),
    );
  }
}
