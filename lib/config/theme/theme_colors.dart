import 'package:flutter/material.dart';

const colorLightScheme = ColorScheme.light(
  primary: Color(0xFF227CBA),
  surface: Color.fromARGB(255, 12, 29, 43),
  onSurface: Color(0xFFF2F5F3),
  onSurfaceVariant: Color(0xF2FFFFFF),
  secondary: Color(0xFFFF4655),
  onSecondary: Color(0xFFA4A4A4),
  error: Color(0xFFD93F2F),
  secondaryContainer: Color(0xFFF0F0F0),
  outline: Color(0xFFF5F5F5),
  surfaceContainer: Color(0xFFA5A5A5),
);

const colorDarkScheme = ColorScheme.dark(
  primary: Color(0xff0F1923),
  surface: Color(0xFFFAFAFA),
  onSurface: Color.fromARGB(255, 12, 29, 43),
  // onSurface: Color(0xFF0E315D),
  onSurfaceVariant: Color.fromARGB(255, 15, 55, 82),
  secondary: Color(0xFFFF4655),
  onSecondary: Color(0xFFA4A4A4),
  error: Color(0xFFD93F2F),
  secondaryContainer: Color(0xFFF0F0F0),
  outline: Color(0xFFF5F5F5),
  surfaceContainer: Color.fromARGB(255, 15, 55, 82),
);

class ThemeColors extends ThemeExtension<ThemeColors> {
  const ThemeColors({
    // Eski ranglar - saqlab qolindi
    required this.yellow,
    required this.green,
    required this.blueDark,
    required this.blueLight,
    required this.red,
    required this.brown,
    required this.primaryText,
    required this.secondaryText,
    required this.onCaptionText,
    required this.textFieldFillColor,
    required this.textFieldBorderColor,
    required this.textFieldFocusBorderColor,
    required this.customButtonColor,
    required this.bottomNavigationBarBorderColor,
    required this.tabBarIndicatorColor,
    required this.blueAccent,
    required this.switchBorderColor,
    required this.switchTrackColor,
    required this.switchThumbColor,
    required this.scrollbarThumbColor,
    required this.warningColor,

    // Yangi qo'shilgan ranglar
    required this.tertiaryText,
    required this.disabledText,
    required this.textFieldDisabledBorder,
    required this.cardBackground,
    required this.cardBorder,
    required this.divider,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.bottomNavBackground,
    required this.switchInactiveTrack,
    required this.switchInactiveThumb,
    required this.scrollbarTrack,
    required this.accentPurple,
    required this.accentOrange,
    required this.accentPink,
    required this.successColor,
    required this.infoColor,
  });

  // Eski ranglar
  final Color green;
  final Color yellow;
  final Color blueDark;
  final Color blueLight;
  final Color red;
  final Color brown;
  final Color primaryText;
  final Color secondaryText;
  final Color onCaptionText;
  final Color textFieldFillColor;
  final Color textFieldBorderColor;
  final Color textFieldFocusBorderColor;
  final Color customButtonColor;
  final Color bottomNavigationBarBorderColor;
  final Color tabBarIndicatorColor;
  final Color blueAccent;
  final Color switchBorderColor;
  final Color switchTrackColor;
  final Color switchThumbColor;
  final Color scrollbarThumbColor;
  final Color warningColor;

  // Yangi ranglar
  final Color tertiaryText;
  final Color disabledText;
  final Color textFieldDisabledBorder;
  final Color cardBackground;
  final Color cardBorder;
  final Color divider;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color bottomNavBackground;
  final Color switchInactiveTrack;
  final Color switchInactiveThumb;
  final Color scrollbarTrack;
  final Color accentPurple;
  final Color accentOrange;
  final Color accentPink;
  final Color successColor;
  final Color infoColor;

  /// Light theme ranglari
  static const ThemeColors light = ThemeColors(
    // Eski ranglar - yaxshilangan
    yellow: Color.fromRGBO(230, 212, 18, 1),
    green: Color(0xFF119C2B),
    blueDark: Color(0xFF2A56C8),
    blueLight: Color(0xFF2A7CC8),
    red: Color(0xFFC82A63),
    brown: Color(0xFFEF8639),
    primaryText: Color(0xFF227CBA/*14A8A4*/),
    secondaryText: Color(0xFF242424),
    onCaptionText: Color(0xFF616161),
    textFieldFillColor: Color(0xFFFAFAFA),
    textFieldFocusBorderColor: Color.fromARGB(255, 66, 66, 66),
    textFieldBorderColor: Colors.grey,
    customButtonColor: Color(0xB3D3E1EF),
    bottomNavigationBarBorderColor: Color.fromARGB(255, 12, 29, 43),
    tabBarIndicatorColor: Color(0xB3D3E1EF),
    blueAccent: Colors.blueAccent,
    switchBorderColor: Colors.grey,
    switchTrackColor: Color(0xB3D3E1EF),
    switchThumbColor: Color.fromARGB(255, 15, 55, 82),
    scrollbarThumbColor: Color(0xFFA4A4A4),
    warningColor: Color(0xFFFFB600),

    // Yangi ranglar
    tertiaryText: Color(0xFFAEAEB2),
    disabledText: Color(0xFFD1D1D6),
    textFieldDisabledBorder: Color(0xFFE5E5EA),
    cardBackground: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE5E5EA),
    divider: Color(0xFFE5E5EA),
    shimmerBase: Color(0xFFE5E5EA),
    shimmerHighlight: Color(0xFFF2F2F7),
    bottomNavBackground: Color(0xFFFFFFFF),
    switchInactiveTrack: Color(0xFFE5E5EA),
    switchInactiveThumb: Color(0xFFFFFFFF),
    scrollbarTrack: Color(0xFFF2F2F7),
    accentPurple: Color(0xFF5E5CE6),
    accentOrange: Color(0xFFFF9500),
    accentPink: Color(0xFFFF2D55),
    successColor: Color(0xFF10A832),
    infoColor: Color(0xFF0A84FF),
  );

  /// Dark theme ranglari
  static const ThemeColors dark = ThemeColors(
    // Eski ranglar - yaxshilangan
    yellow: Color.fromRGBO(230, 212, 18, 1),
    green: Color(0xFF119C2B),
    blueDark: Color(0xFF2A56C8),
    blueLight: Color(0xFF2A7CC8),
    red: Color(0xFFC82A63),
    brown: Color(0xFFEF8639),
    primaryText: Colors.white,
    secondaryText: Colors.grey,
    onCaptionText: Color.fromARGB(255, 6, 35, 55),
    textFieldFillColor: Color.fromARGB(255, 32, 44, 61),
    textFieldFocusBorderColor: Colors.white,
    textFieldBorderColor: Colors.grey,
    customButtonColor: Color.fromARGB(255, 15, 55, 82),
    bottomNavigationBarBorderColor: Color.fromRGBO(255, 255, 255, 0.4),
    tabBarIndicatorColor: Color.fromARGB(255, 15, 55, 82),
    blueAccent: Colors.blueAccent,
    switchBorderColor: Color.fromRGBO(255, 255, 255, 0.4),
    switchTrackColor: Color.fromARGB(255, 15, 55, 82),
    switchThumbColor: Color(0xFFFAFAFA),
    scrollbarThumbColor: Color.fromARGB(255, 15, 55, 82),
    warningColor: Color(0xFFFFB600),

    // Yangi ranglar
    tertiaryText: Color(0xFF636366),
    disabledText: Color(0xFF48484A),
    textFieldDisabledBorder: Color(0xFF2C2C2E),
    cardBackground: Color(0xFFD6F2FF),
    cardBorder: Color(0xFF38383A),
    divider: Color(0xFF38383A),
    shimmerBase: Color(0xFF2C2C2E),
    shimmerHighlight: Color(0xFF38383A),
    bottomNavBackground: Color(0xFF1C1C1E),
    switchInactiveTrack: Color(0xFF39393D),
    switchInactiveThumb: Color(0xFFFFFFFF),
    scrollbarTrack: Color(0xFF2C2C2E),
    accentPurple: Color(0xFF5E5CE6),
    accentOrange: Color(0xFFFF9500),
    accentPink: Color(0xFFFF375F),
    successColor: Color(0xFF30D158),
    infoColor: Color(0xFF0A84FF),
  );

  @override
  ThemeExtension<ThemeColors> copyWith({
    // Eski ranglar
    Color? yellow,
    Color? green,
    Color? primaryText,
    Color? secondaryText,
    Color? onCaptionText,
    Color? blueDark,
    Color? blueLight,
    Color? red,
    Color? brown,
    Color? textFieldFillColor,
    Color? textFieldFocusBorderColor,
    Color? textFieldBorderColor,
    Color? customButtonColor,
    Color? bottomNavigationBarBorderColor,
    Color? tabBarIndicatorColor,
    Color? blueAccent,
    Color? switchBorderColor,
    Color? switchTrackColor,
    Color? switchThumbColor,
    Color? scrollbarThumbColor,
    Color? warningColor,
    // Yangi ranglar
    Color? tertiaryText,
    Color? disabledText,
    Color? textFieldDisabledBorder,
    Color? cardBackground,
    Color? cardBorder,
    Color? divider,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? bottomNavBackground,
    Color? switchInactiveTrack,
    Color? switchInactiveThumb,
    Color? scrollbarTrack,
    Color? accentPurple,
    Color? accentOrange,
    Color? accentPink,
    Color? successColor,
    Color? infoColor,
  }) {
    return ThemeColors(
      // Eski ranglar
      blueDark: blueDark ?? this.blueDark,
      blueLight: blueLight ?? this.blueLight,
      brown: brown ?? this.brown,
      red: red ?? this.red,
      yellow: yellow ?? this.yellow,
      green: green ?? this.green,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      onCaptionText: secondaryText ?? this.onCaptionText,
      textFieldFillColor: textFieldFillColor ?? this.textFieldFillColor,
      textFieldFocusBorderColor: textFieldFocusBorderColor ?? this.textFieldFocusBorderColor,
      textFieldBorderColor: textFieldBorderColor ?? this.textFieldBorderColor,
      customButtonColor: customButtonColor ?? this.customButtonColor,
      tabBarIndicatorColor: tabBarIndicatorColor ?? this.tabBarIndicatorColor,
      switchBorderColor: switchBorderColor ?? this.switchBorderColor,
      blueAccent: blueAccent ?? this.blueAccent,
      switchTrackColor: switchTrackColor ?? this.switchTrackColor,
      switchThumbColor: switchThumbColor ?? this.switchThumbColor,
      scrollbarThumbColor: scrollbarThumbColor ?? this.scrollbarThumbColor,
      warningColor: warningColor ?? this.warningColor,
      bottomNavigationBarBorderColor: bottomNavigationBarBorderColor ?? this.bottomNavigationBarBorderColor,
      // Yangi ranglar
      tertiaryText: tertiaryText ?? this.tertiaryText,
      disabledText: disabledText ?? this.disabledText,
      textFieldDisabledBorder: textFieldDisabledBorder ?? this.textFieldDisabledBorder,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      divider: divider ?? this.divider,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      bottomNavBackground: bottomNavBackground ?? this.bottomNavBackground,
      switchInactiveTrack: switchInactiveTrack ?? this.switchInactiveTrack,
      switchInactiveThumb: switchInactiveThumb ?? this.switchInactiveThumb,
      scrollbarTrack: scrollbarTrack ?? this.scrollbarTrack,
      accentPurple: accentPurple ?? this.accentPurple,
      accentOrange: accentOrange ?? this.accentOrange,
      accentPink: accentPink ?? this.accentPink,
      successColor: successColor ?? this.successColor,
      infoColor: infoColor ?? this.infoColor,
    );
  }

  @override
  ThemeExtension<ThemeColors> lerp(ThemeExtension<ThemeColors>? other, double t) {
    if (other is! ThemeColors) return this;

    return ThemeColors(
      // Eski ranglar
      blueDark: Color.lerp(blueDark, other.blueDark, t)!,
      blueLight: Color.lerp(blueLight, other.blueLight, t)!,
      brown: Color.lerp(brown, other.brown, t)!,
      red: Color.lerp(red, other.red, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      green: Color.lerp(green, other.green, t)!,
      yellow: Color.lerp(yellow, other.yellow, t)!,
      onCaptionText: Color.lerp(onCaptionText, other.onCaptionText, t)!,
      textFieldFillColor: Color.lerp(textFieldFillColor, other.textFieldFillColor, t)!,
      textFieldBorderColor: Color.lerp(textFieldBorderColor, other.textFieldBorderColor, t)!,
      tabBarIndicatorColor: Color.lerp(tabBarIndicatorColor, other.tabBarIndicatorColor, t)!,
      textFieldFocusBorderColor: Color.lerp(textFieldFocusBorderColor, other.textFieldFocusBorderColor, t)!,
      bottomNavigationBarBorderColor: Color.lerp(bottomNavigationBarBorderColor, other.bottomNavigationBarBorderColor, t)!,
      customButtonColor: Color.lerp(customButtonColor, other.customButtonColor, t)!,
      switchBorderColor: Color.lerp(switchBorderColor, other.switchBorderColor, t)!,
      blueAccent: Color.lerp(blueAccent, other.blueAccent, t)!,
      switchTrackColor: Color.lerp(switchTrackColor, other.switchTrackColor, t)!,
      switchThumbColor: Color.lerp(switchThumbColor, other.switchThumbColor, t)!,
      scrollbarThumbColor: Color.lerp(scrollbarThumbColor, other.scrollbarThumbColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      // Yangi ranglar
      tertiaryText: Color.lerp(tertiaryText, other.tertiaryText, t)!,
      disabledText: Color.lerp(disabledText, other.disabledText, t)!,
      textFieldDisabledBorder: Color.lerp(textFieldDisabledBorder, other.textFieldDisabledBorder, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      bottomNavBackground: Color.lerp(bottomNavBackground, other.bottomNavBackground, t)!,
      switchInactiveTrack: Color.lerp(switchInactiveTrack, other.switchInactiveTrack, t)!,
      switchInactiveThumb: Color.lerp(switchInactiveThumb, other.switchInactiveThumb, t)!,
      scrollbarTrack: Color.lerp(scrollbarTrack, other.scrollbarTrack, t)!,
      accentPurple: Color.lerp(accentPurple, other.accentPurple, t)!,
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
      accentPink: Color.lerp(accentPink, other.accentPink, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
    );
  }
}
