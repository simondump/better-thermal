import 'package:flutter/material.dart';
import 'package:uti_thermal_app/styles/colors.dart';

@immutable
class AppTheme extends ThemeExtension<AppTheme> {
  const AppTheme({required this.colors});

  final AppColors colors;

  @override
  AppTheme copyWith({AppColors? colors}) {
    return AppTheme(colors: this.colors);
  }

  @override
  AppTheme lerp(AppTheme? other, double t) {
    if (other == null) return this;

    return AppTheme(colors: colors);
  }
}

class AppThemes {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    extensions: const [AppTheme(colors: AppColors.light)],
  );

  static final dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF101014),
    extensions: const [AppTheme(colors: AppColors.dark)],
  );
}

extension AppThemeExtension on BuildContext {
  AppTheme get theme => Theme.of(this).extension<AppTheme>()!;
}
