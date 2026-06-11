import 'package:flutter/material.dart';

import '../../config/routes/coordinator.dart';
import '../../config/theme/theme_colors.dart';
import '../util/app_options.dart';

extension BuildContextExtension on BuildContext {
  Locale get locale => Localizations.localeOf(this);

  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isDarkMode => colorScheme.brightness == Brightness.dark;

  ThemeColors get color => Theme.of(this).extension<ThemeColors>()!;

  // ThemeTextStyles get textStyle => Theme.of(this).extension<ThemeTextStyles>()!;

  // Widget appLogo({double? width}) => AppOptions.of(rootNavigatorKey.currentContext!).themeMode == ThemeMode.light
  //     ? SvgPicture.asset(AppIcons.logoSpherixLight, fit: BoxFit.cover, width: kSize.width * (width ?? 0.8))
  //     : SvgPicture.asset(AppIcons.logoSpherixNight, fit: BoxFit.cover, width: kSize.width * (width ?? 0.8));
  //
  // Widget appLogoTextH({double? width}) => AppOptions.of(rootNavigatorKey.currentContext!).themeMode == ThemeMode.light
  //     ? SvgPicture.asset(AppIcons.logoAndTextHorizontalLight, fit: BoxFit.cover, width: kSize.width * (width ?? 0.8))
  //     : SvgPicture.asset(AppIcons.logoAndTextHorizontalNight, fit: BoxFit.cover, width: kSize.width * (width ?? 0.8));
  //
  // Widget appLogoTextV({double? width}) => AppOptions.of(rootNavigatorKey.currentContext!).themeMode == ThemeMode.light
  //     ? SvgPicture.asset(AppIcons.logoAndTextVerticalLight, fit: BoxFit.cover, width: kSize.width * (width ?? 0.8))
  //     : SvgPicture.asset(AppIcons.logoAndTextVerticalNight, fit: BoxFit.cover, width: kSize.width * (width ?? 0.8));

  /*Assets.images.lightLogo.image(width: kSize.width * (width ?? 0.8))
          : Assets.images.transparentLogo.image(width: kSize.width * (width ?? 0.8))*/

  void get changeTheme => AppOptions.of(rootNavigatorKey.currentContext!).themeMode == ThemeMode.light
      ? AppOptions.update(rootNavigatorKey.currentContext!, AppOptions.of(rootNavigatorKey.currentContext!).copyWith(themeMode: ThemeMode.dark))
      : AppOptions.update(rootNavigatorKey.currentContext!, AppOptions.of(rootNavigatorKey.currentContext!).copyWith(themeMode: ThemeMode.light));
}
