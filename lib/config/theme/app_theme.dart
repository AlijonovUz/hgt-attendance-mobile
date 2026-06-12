import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'theme_colors.dart';

/// Ilova mavzulari (light + dark).
///
/// Har ikkala rejim ham `AppColors` va `ThemeColors` `ThemeExtension`larini
/// ro‘yxatga oladi — shu sabab `AppColors.of(context)` va `context.color`
/// hamma joyda null bo‘lmasdan ishlaydi.
abstract final class AppTheme {
  static ThemeData get light => _base(
        brightness: Brightness.light,
        scheme: colorLightScheme,
        appColors: AppColors.light(),
        themeColors: ThemeColors.light,
      );

  static ThemeData get dark => _base(
        brightness: Brightness.dark,
        scheme: colorDarkScheme,
        appColors: AppColors.dark(),
        themeColors: ThemeColors.dark,
      );

  static ThemeData _base({
    required Brightness brightness,
    required ColorScheme scheme,
    required AppColors appColors,
    required ThemeColors themeColors,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: appColors.backgroundBase,
    );

    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme),
      extensions: <ThemeExtension<dynamic>>[appColors, themeColors],
    );
  }
}
