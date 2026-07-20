import 'dart:ui';

class AppColors {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.danger,
    required this.onDanger,
    required this.background,
    required this.navigation,
    required this.onNavigation,
    required this.onBackground,
    required this.onBackgroundMuted,
  });

  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color danger;
  final Color onDanger;
  final Color background;
  final Color navigation;
  final Color onNavigation;
  final Color onBackground;
  final Color onBackgroundMuted;

  static const AppColors light = AppColors(
    primary: Color(0xFF0066FF),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF6C63FF),
    onSecondary: Color(0xFFFFFFFF),
    success: Color(0xFF2E7D32),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFF9A825),
    onWarning: Color(0xFF000000),
    danger: Color(0xFFD32F2F),
    onDanger: Color(0xFFFFFFFF),
    background: Color(0xFFF5F5F5),
    navigation: Color(0xFFF5F5F5),
    onNavigation: Color(0xFF000000),
    onBackground: Color(0xFF000000),
    onBackgroundMuted: Color(0xFF757575),
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF4D8DFF),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF8C9EFF),
    onSecondary: Color(0xFF000000),
    success: Color(0xFF66BB6A),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFFFC107),
    onWarning: Color(0xFF000000),
    danger: Color(0xFFEF5350),
    onDanger: Color(0xFFFFFFFF),
    background: Color(0xFF0F0F11),
    navigation: Color(0xFF14141C),
    onNavigation: Color(0xFF708EF5),
    onBackground: Color(0xFFFFFFFF),
    onBackgroundMuted: Color(0xFF47484B),
  );
}
