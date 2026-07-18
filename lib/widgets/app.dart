import 'package:better_thermal/styles/themes.dart';
import 'package:better_thermal/widgets/ftp/fpt_screen.dart';
import 'package:better_thermal/widgets/live/live_screen.dart';
import 'package:flutter/material.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  int currentPageIndex = 0;

  @override
  void activate() {
    super.activate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? TextStyle(color: context.theme.colors.primary)
                : TextStyle(color: context.theme.colors.onBackgroundMuted),
          ),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? IconThemeData(color: context.theme.colors.onPrimary)
                : IconThemeData(color: context.theme.colors.onBackgroundMuted),
          ),
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          backgroundColor: context.theme.colors.background,
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
        children: <Widget>[LiveScreen(), FtpScreen()],
      ),
    );
  }
}
