import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_thermal/styles/colors.dart';

@immutable
class AppTheme extends ThemeExtension<AppTheme> {
  const AppTheme({required this.colors, required this.systemUiOverlayStyle});

  final AppColors colors;
  final SystemUiOverlayStyle systemUiOverlayStyle;

  @override
  AppTheme copyWith({
    AppColors? colors,
    SystemUiOverlayStyle? systemUiOverlayStyle,
  }) {
    return AppTheme(
      colors: colors ?? this.colors,
      systemUiOverlayStyle: systemUiOverlayStyle ?? this.systemUiOverlayStyle,
    );
  }

  @override
  AppTheme lerp(AppTheme? other, double t) {
    if (other == null) return this;

    return AppTheme(colors: colors, systemUiOverlayStyle: systemUiOverlayStyle);
  }
}

class AppThemes {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.light.background,
    extensions: const [
      AppTheme(
        colors: AppColors.light,
        systemUiOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
    ],
  );

  static final dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.dark.background,
    extensions: const [
      AppTheme(
        colors: AppColors.dark,
        systemUiOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
    ],
  );
}

extension AppThemeExtension on BuildContext {
  AppTheme get theme => Theme.of(this).extension<AppTheme>()!;
}
