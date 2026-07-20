import 'package:better_thermal/services/ftp_service/ftp_service.dart';
import 'package:better_thermal/services/live_stream_service/live_stream_service.dart';
import 'package:better_thermal/styles/themes.dart';
import 'package:better_thermal/widgets/ftp/fpt_screen.dart';
import 'package:better_thermal/widgets/live/live_stream.dart';
import 'package:flutter/material.dart';

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
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (Set<WidgetState> states) =>
                TextStyle(color: context.theme.colors.onNavigation),
          ),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? IconThemeData(color: context.theme.colors.onPrimary)
                : IconThemeData(color: context.theme.colors.onNavigation),
          ),
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          backgroundColor: context.theme.colors.navigation,
          indicatorColor: context.theme.colors.primary,
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.live_tv),
              label: 'Live Stream',
            ),
            NavigationDestination(icon: Icon(Icons.image), label: 'Images'),
          ],
        ),
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: <Widget>[
          LiveStream(liveStreamService: _liveStreamService),
          FtpScreen(ftpService: _ftpService),
        ],
      ),
    );
  }
}
