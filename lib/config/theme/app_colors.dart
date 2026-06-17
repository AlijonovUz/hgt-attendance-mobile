import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  // ── Base ──────────────────────────────────────────────────────────────
  final Color white;
  final Color black;
  final Color shadow;

  // ── Foreground ────────────────────────────────────────────────────────
  final Color foregroundPrimary;
  final Color foregroundAccent;
  final Color popover;

  // ── Background ────────────────────────────────────────────────────────
  final Color backgroundBase;
  final Color backgroundBase2;
  final Color backgroundElevation1;
  final Color backgroundElevation1Alt;
  final Color backgroundElevation2;
  final Color backgroundElevation2Alt;
  final Color backgroundElevation3;
  final Color backgroundElevation3Alt;

  // ── Accent ────────────────────────────────────────────────────────────
  final Color accentStrong;
  final Color accentSub;
  final Color accentSoft;
  final Color accentDisabled;
  final Color accentWhite;

  // ── Text ──────────────────────────────────────────────────────────────
  final Color textStrong;
  final Color textSub;
  final Color textSoft;
  final Color textDisabled;
  final Color textWhite;
  final Color textAccent;
  final Color textInWhite;
  final Color textInDark;

  // ── Stroke ────────────────────────────────────────────────────────────
  final Color strokeStrong;
  final Color strokeSub;
  final Color strokeSoft;
  final Color strokeAccent;
  final Color strokeWhite;

  // ── Icon ──────────────────────────────────────────────────────────────
  final Color iconStrong;
  final Color iconSub;
  final Color iconSoft;
  final Color iconDisabled;
  final Color iconWhite;
  final Color iconAccent;
  final Color iconInWhite;
  final Color iconInBlack;

  /// Bildirishnoma ikonkasi (masalan expense AppBar SVG).
  final Color iconNotify;

  // ── Error ─────────────────────────────────────────────────────────────
  final Color errorStrong;
  final Color errorSub;
  final Color errorSoft;
  final Color errorDisabled;

  // ── Success ───────────────────────────────────────────────────────────
  final Color successStrong;
  final Color successPrimary;
  final Color successSub;
  final Color successSoft;
  final Color successDisabled;

  /// Xarajat kartasi va shunga o‘xshash bosh harf avatarlari uchun fon.
  final Color avatarPlaceholder;

  // ── Control (input / button komponent tokenlari) ──────────────────────
  /// Input placeholder / ikkilamchi yozuv (Figma: components/control/text/secondary).
  final Color controlTextSecondary;

  /// O‘chirilgan tugma yozuvi (Figma: components/control/text/disabled).
  final Color controlTextDisabled;

  /// O‘chirilgan tugma foni (Figma: components/control/bg/disabled).
  final Color controlBgDisabled;

  /// O‘chirilgan asosiy tugma foni (Figma login `ring` #737373) — har ikkala rejimda bir xil.
  final Color controlBgDisabledStrong;

  /// O‘chirilgan asosiy tugma yozuvi (Figma login: light `secondary` #f5f5f5, dark `black-in-de` #444444).
  final Color controlTextDisabledStrong;

  const AppColors({
    required this.white,
    required this.black,
    required this.shadow,
    required this.backgroundBase,
    required this.backgroundBase2,
    required this.backgroundElevation1,
    required this.backgroundElevation1Alt,
    required this.backgroundElevation2,
    required this.backgroundElevation2Alt,
    required this.backgroundElevation3,
    required this.backgroundElevation3Alt,
    required this.accentStrong,
    required this.accentSub,
    required this.accentSoft,
    required this.accentDisabled,
    required this.accentWhite,
    required this.textStrong,
    required this.textSub,
    required this.textSoft,
    required this.textDisabled,
    required this.textWhite,
    required this.textAccent,
    required this.textInWhite,
    required this.textInDark,
    required this.strokeStrong,
    required this.strokeSub,
    required this.strokeSoft,
    required this.strokeAccent,
    required this.strokeWhite,
    required this.iconStrong,
    required this.iconSub,
    required this.iconSoft,
    required this.iconDisabled,
    required this.iconWhite,
    required this.iconAccent,
    required this.iconInWhite,
    required this.iconInBlack,
    required this.iconNotify,
    required this.errorStrong,
    required this.errorSub,
    required this.errorSoft,
    required this.errorDisabled,
    required this.successStrong,
    required this.successPrimary,
    required this.successSub,
    required this.successSoft,
    required this.successDisabled,
    required this.avatarPlaceholder,
    required this.controlTextSecondary,
    required this.controlTextDisabled,
    required this.controlBgDisabled,
    required this.controlBgDisabledStrong,
    required this.controlTextDisabledStrong,
    required this.foregroundPrimary,
    required this.foregroundAccent,
    required this.popover,
  });

  // Figma «HGT» design system (shadcn neutral) — Light.
  // background #fff · foreground #0a0a0a · muted #737373 · border #e5e5e5 ·
  // secondary #f5f5f5 · primary(blue) #0d74ce · destructive #dc2626 ·
  // success(green) #2b9a66 · warning(orange) #ef5f00.
  factory AppColors.light() => const AppColors(
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    shadow: Color(0x1A000000),
    // shadow-xs
    backgroundBase: Color(0xFFFFFFFF),
    backgroundBase2: Color(0xFFFFFFFF),
    backgroundElevation1: Color(0xFFFFFFFF),
    backgroundElevation1Alt: Color(0xFFF5F5F5),
    backgroundElevation2: Color(0xFFF5F5F5),
    backgroundElevation2Alt: Color(0xFFF5F5F5),
    backgroundElevation3: Color(0xFFE5E5E5),
    backgroundElevation3Alt: Color(0xFFE5E5E5),
    foregroundPrimary: Color(0xFFFAFAFA),
    foregroundAccent: Color(0xFF171717),
    popover: Color(0xFFFFFFFF),
    accentStrong: Color(0xFF0D74CE),
    accentSub: Color(0xFF0D74CE),
    accentSoft: Color(0xFF3B9EFF),
    accentDisabled: Color(0xFFE5E5E5),
    accentWhite: Color(0xFFFFFFFF),
    textStrong: Color(0xFF0A0A0A),
    textSub: Color(0xFF737373),
    textSoft: Color(0xFF737373),
    textDisabled: Color(0xFFA3A3A3),
    textWhite: Color(0xFFFFFFFF),
    textAccent: Color(0xFF0D74CE),
    textInWhite: Color(0xFFFFFFFF),
    textInDark: Color(0xFF0A0A0A),
    strokeStrong: Color(0xFFD4D4D4),
    strokeSub: Color(0xFFE5E5E5),
    strokeSoft: Color(0xFFE5E5E5),
    strokeAccent: Color(0xFF0D74CE),
    strokeWhite: Color(0xFFFFFFFF),
    iconStrong: Color(0xFF0A0A0A),
    iconSub: Color(0xFF737373),
    iconSoft: Color(0xFF737373),
    iconDisabled: Color(0xFFA3A3A3),
    iconWhite: Color(0xFFFFFFFF),
    iconAccent: Color(0xFF0D74CE),
    iconInWhite: Color(0xFFFFFFFF),
    iconInBlack: Color(0xFF000000),
    iconNotify: Color(0xFF0A0A0A),
    errorStrong: Color(0xFFDC2626),
    errorSub: Color(0xFFEF4444),
    errorSoft: Color(0xFFFEF2F2),
    errorDisabled: Color(0xFFFECACA),
    successStrong: Color(0xFF2B9A66),
    successPrimary: Color(0xFF2B9A66),
    successSub: Color(0xFF30A46C),
    successSoft: Color(0xFFDCFCE7),
    successDisabled: Color(0xFFF0FDF4),
    avatarPlaceholder: Color(0xFFE5E5E5),
    controlTextSecondary: Color(0xFF737373),
    controlTextDisabled: Color(0xFFA3A3A3),
    controlBgDisabled: Color(0xFFF5F5F5),
    controlBgDisabledStrong: Color(0xFF737373),
    controlTextDisabledStrong: Color(0xFFF5F5F5),
  );

  // Figma «HGT» design system (shadcn neutral) — Dark.
  // background #0a0a0a · foreground #fafafa · muted #a3a3a3 · border #404040 ·
  // secondary #262626 · primary(blue) #0d74ce.
  factory AppColors.dark() => const AppColors(
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    shadow: Color(0x3D000000),
    backgroundBase: Color(0xFF0A0A0A),
    backgroundBase2: Color(0xFF0A0A0A),
    backgroundElevation1: Color(0xFF171717),
    backgroundElevation1Alt: Color(0xFF262626),
    backgroundElevation2: Color(0xFF262626),
    backgroundElevation2Alt: Color(0xFF404040),
    backgroundElevation3: Color(0xFF404040),
    backgroundElevation3Alt: Color(0xFF525252),
    foregroundPrimary: Color(0xFF171717),
    foregroundAccent: Color(0xFFFAFAFA),
    popover: Color(0xFF262626),
    accentStrong: Color(0xFF0D74CE),
    accentSub: Color(0xFF0D74CE),
    accentSoft: Color(0xFF3B9EFF),
    accentDisabled: Color(0xFF1E2B5C),
    accentWhite: Color(0xFFFFFFFF),
    textStrong: Color(0xFFFAFAFA),
    textSub: Color(0xFFA3A3A3),
    textSoft: Color(0xFFA3A3A3),
    textDisabled: Color(0xFF737373),
    textWhite: Color(0xFFFFFFFF),
    textAccent: Color(0xFF3B9EFF),
    textInWhite: Color(0xFFFFFFFF),
    textInDark: Color(0xFF000000),
    strokeStrong: Color(0xFF525252),
    strokeSub: Color(0xFF404040),
    strokeSoft: Color(0xFF404040),
    strokeAccent: Color(0xFF0D74CE),
    strokeWhite: Color(0xFFFFFFFF),
    iconStrong: Color(0xFFFAFAFA),
    iconSub: Color(0xFFA3A3A3),
    iconSoft: Color(0xFFA3A3A3),
    iconDisabled: Color(0xFF737373),
    iconWhite: Color(0xFFFFFFFF),
    iconAccent: Color(0xFF3B9EFF),
    iconInWhite: Color(0xFFFFFFFF),
    iconInBlack: Color(0xFF000000),
    iconNotify: Color(0xFFFFFFFF),
    errorStrong: Color(0xFFDC2626),
    errorSub: Color(0xFFF87171),
    errorSoft: Color(0xFF2E1A1A),
    errorDisabled: Color(0xFF402323),
    successStrong: Color(0xFF2B9A66),
    successPrimary: Color(0xFF2B9A66),
    successSub: Color(0xFF30A46C),
    successSoft: Color(0xFF142E1B),
    successDisabled: Color(0xFF1B3D24),
    avatarPlaceholder: Color(0xFF404040),
    controlTextSecondary: Color(0xFFA3A3A3),
    controlTextDisabled: Color(0xFF737373),
    controlBgDisabled: Color(0xFF262626),
    controlBgDisabledStrong: Color(0xFF737373),
    controlTextDisabledStrong: Color(0xFF444444),
  );

  /// Ogohlantirish / blok sanagichi (orange) — login bloklangan holatidagi
  /// «Qayta urinish: MM:SS» vaqti (Figma `orange/10`). Har ikkala rejimda bir xil.
  static const Color warningStrong = Color(0xFFEF5F00);

  /// Brend logotipi foni (Figma `chart-5` to‘q-ko‘k) — har ikkala rejimda bir xil.
  static const Color brandNavy = Color(0xFF113264);

  /// Auth gradienti ustidagi matn rangi (sarlavha + tavsif).
  static const Color authForeground = Color(0xFF0A0A0A);

  /// Auth/login fon gradienti (Figma: 95.84°, oqish-binafsha → ko‘k).
  /// Brend gradienti — har ikkala rejimda ham bir xil.
  static const Gradient authBackgroundGradient = LinearGradient(
    begin: Alignment(-1.0, -0.1),
    end: Alignment(1.0, 0.1),
    colors: [Color(0xFFE6ECFF), Color(0xFFA5B4FC), Color(0xFF6E86E1)],
    stops: [0.0025, 0.3575, 1.0],
  );

  /// Login sahifasi tepa gradienti (vertikal, ko‘k → fonga so‘ladi). Yangi
  /// «Davomat» dizayniga mos: yorug‘da och-ko‘k, qorong‘ida to‘q-ko‘k.
  static const Gradient loginHeaderGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFBBD5F3), Color(0x00FFFFFF)],
    stops: [0.0, 1.0],
  );

  static const Gradient loginHeaderGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B2A63), Color(0x000A0A0A)],
    stops: [0.0, 1.0],
  );

  static Gradient loginHeaderGradient(Brightness brightness) =>
      brightness == Brightness.dark
      ? loginHeaderGradientDark
      : loginHeaderGradientLight;

  /// Onboarding fon gradienti — Figma (vertikal, tepada ko‘k, pastga so‘ladi).
  static const Gradient onboardingBackgroundGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFA8C5F2), Color(0xFFC9DBF6), Color(0xFFFFFFFF)],
    stops: [0.0, 0.45, 1.0],
  );

  static const Gradient onboardingBackgroundGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF10316E), Color(0xFF0C1C40), Color(0xFF0A0A0A)],
    stops: [0.0, 0.45, 1.0],
  );

  static Gradient onboardingBackgroundGradient(Brightness brightness) =>
      brightness == Brightness.dark
      ? onboardingBackgroundGradientDark
      : onboardingBackgroundGradientLight;

  /// Onboarding asosiy tugma gradienti (Figma: chapdan `#0090ff` → o‘ngda
  /// `rgba(12,96,254,.5)`) — har ikki rejimda bir xil.
  static const Gradient onboardingActionGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0090FF), Color(0x800C60FE)],
  );

  // ── Onboarding kartalari (Figma — ko‘k gradient ustidagi navy kartalar; ranglar
  // qat'iy, har ikkala rejimda bir xil) ───────────────────────────────────────
  /// Karta yuzasi (Figma `#313f5d`).
  static const Color onboardingCardBg = Color(0xFF313F5D);

  /// Karta ramkasi (Figma `#49505e`).
  static const Color onboardingCardBorder = Color(0xFF49505E);

  /// Kartadagi asosiy yozuv (Figma `foreground` `#fafafa`).
  static const Color onboardingCardText = Color(0xFFFAFAFA);

  /// Kartadagi ikkilamchi yozuv (Figma `muted-foreground` `#a3a3a3`).
  static const Color onboardingCardTextSub = Color(0xFFA3A3A3);

  /// Ruxsat kartasi ichidagi ikon qutisi foni (Figma `card` dark `#171717`).
  static const Color onboardingCardIconBg = Color(0xFF171717);

  /// «Ruxsat berish» tugmasi (Figma `primary` `#e5e5e5` + `primary-foreground` `#171717`).
  static const Color onboardingCardButtonBg = Color(0xFFE5E5E5);
  static const Color onboardingCardButtonText = Color(0xFF171717);

  /// Profil kartasidagi avatar (Figma `secondary` `#f5f5f5` fon + `foreground` `#0a0a0a` harf).
  static const Color onboardingAvatarBg = Color(0xFFF5F5F5);
  static const Color onboardingAvatarText = Color(0xFF0A0A0A);

  // ── Swipe (surish) tugmasi tokenlari ────────────────────────────────────
  // Surilganda ochiladigan fon gradientlari (chapda yorqinroq rang @50% →
  // o‘ngda to‘q asos), yo‘lak foni esa har ikki rejimda ham och qoladi
  // (Figma: dark mode’da ham `blue/3`). Dasta rangi = gradient oxirgi rangi.
  // `SwipeActionButton` orqali istalgan boshqa gradient ham berilishi mumkin.

  /// «Ishga keldim» (ko‘k). Figma: rgba(12,96,254,.5) → #0090ff.
  static const Gradient swipeArriveGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0x800C60FE), Color(0xFF0090FF)],
  );

  /// «Tushlikka chiqdim» va «Tushlikdan qaytdim» (to‘q-sariq, bir xil).
  /// Figma: #ffc182 → #ef5f00.
  static const Gradient swipeLunchGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFC182), Color(0xFFEF5F00)],
  );

  /// «Ishdan ketdim» (yashil). Figma: #adddc0 → #2b9a66.
  static const Gradient swipeLeaveGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFADDDC0), Color(0xFF2B9A66)],
  );

  /// Swipe yo‘lagi fonlari (Figma: har ikki rejimda ham och) — bosqichga mos.
  static const Color swipeTrackBlue = Color(0xFFE6F4FE); // blue/3
  static const Color swipeTrackOrange = Color(0xFFFFEFD6); // orange/3
  static const Color swipeTrackGreen = Color(0xFFE3F5EA);

  /// Surilmagan holatdagi yozuv rangi (Figma `black-in-de`) — yo‘lak och
  /// bo‘lgani uchun har ikki rejimda ham bir xil to‘q.
  static const Color swipeIdleText = Color(0xFF444444);

  /// Swipe yo‘lagi ramkasi (Figma `secondary` #f5f5f5).
  static const Color swipeTrackBorder = Color(0xFFF0F0F0);

  /// Access from anywhere: `Theme.of(context).extension<AppColors>()!`
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  /// Xarajatlar AppBar filtr/bildirishnoma tugmasi foni (light: `backgroundElevation2`, dark: `strokeSub`).
  Color get expenseAppBarFilterSurface =>
      backgroundBase.computeLuminance() < 0.5
      ? strokeSub
      : backgroundElevation2;

  @override
  AppColors copyWith({
    Color? white,
    Color? black,
    Color? shadow,
    Color? backgroundBase,
    Color? backgroundBase2,
    Color? backgroundElevation1,
    Color? backgroundElevation1Alt,
    Color? backgroundElevation2,
    Color? backgroundElevation2Alt,
    Color? backgroundElevation3,
    Color? backgroundElevation3Alt,
    Color? foregroundPrimary,
    Color? foregroundAccent,
    Color? popover,
    Color? accentStrong,
    Color? accentSub,
    Color? accentSoft,
    Color? accentDisabled,
    Color? accentWhite,
    Color? textStrong,
    Color? textSub,
    Color? textSoft,
    Color? textDisabled,
    Color? textWhite,
    Color? textAccent,
    Color? textInWhite,
    Color? textInDark,
    Color? strokeStrong,
    Color? strokeSub,
    Color? strokeSoft,
    Color? strokeAccent,
    Color? strokeWhite,
    Color? iconStrong,
    Color? iconSub,
    Color? iconSoft,
    Color? iconDisabled,
    Color? iconWhite,
    Color? iconAccent,
    Color? iconInWhite,
    Color? iconInBlack,
    Color? iconNotify,
    Color? errorStrong,
    Color? errorSub,
    Color? errorSoft,
    Color? errorDisabled,
    Color? successStrong,
    Color? successPrimary,
    Color? successSub,
    Color? successSoft,
    Color? successDisabled,
    Color? avatarPlaceholder,
    Color? controlTextSecondary,
    Color? controlTextDisabled,
    Color? controlBgDisabled,
    Color? controlBgDisabledStrong,
    Color? controlTextDisabledStrong,
  }) => AppColors(
    white: white ?? this.white,
    black: black ?? this.black,
    shadow: shadow ?? this.shadow,
    backgroundBase: backgroundBase ?? this.backgroundBase,
    backgroundBase2: backgroundBase2 ?? this.backgroundBase2,
    backgroundElevation1: backgroundElevation1 ?? this.backgroundElevation1,
    backgroundElevation1Alt:
        backgroundElevation1Alt ?? this.backgroundElevation1Alt,
    backgroundElevation2: backgroundElevation2 ?? this.backgroundElevation2,
    backgroundElevation2Alt:
        backgroundElevation2Alt ?? this.backgroundElevation2Alt,
    backgroundElevation3: backgroundElevation3 ?? this.backgroundElevation3,
    backgroundElevation3Alt:
        backgroundElevation3Alt ?? this.backgroundElevation3Alt,
    foregroundPrimary: foregroundPrimary ?? this.foregroundPrimary,
    foregroundAccent: foregroundAccent ?? this.foregroundAccent,
    popover: popover ?? this.popover,
    accentStrong: accentStrong ?? this.accentStrong,
    accentSub: accentSub ?? this.accentSub,
    accentSoft: accentSoft ?? this.accentSoft,
    accentDisabled: accentDisabled ?? this.accentDisabled,
    accentWhite: accentWhite ?? this.accentWhite,
    textStrong: textStrong ?? this.textStrong,
    textSub: textSub ?? this.textSub,
    textSoft: textSoft ?? this.textSoft,
    textDisabled: textDisabled ?? this.textDisabled,
    textWhite: textWhite ?? this.textWhite,
    textAccent: textAccent ?? this.textAccent,
    textInWhite: textInWhite ?? this.textInWhite,
    textInDark: textInDark ?? this.textInDark,
    strokeStrong: strokeStrong ?? this.strokeStrong,
    strokeSub: strokeSub ?? this.strokeSub,
    strokeSoft: strokeSoft ?? this.strokeSoft,
    strokeAccent: strokeAccent ?? this.strokeAccent,
    strokeWhite: strokeWhite ?? this.strokeWhite,
    iconStrong: iconStrong ?? this.iconStrong,
    iconSub: iconSub ?? this.iconSub,
    iconSoft: iconSoft ?? this.iconSoft,
    iconDisabled: iconDisabled ?? this.iconDisabled,
    iconWhite: iconWhite ?? this.iconWhite,
    iconAccent: iconAccent ?? this.iconAccent,
    iconInWhite: iconInWhite ?? this.iconInWhite,
    iconInBlack: iconInBlack ?? this.iconInBlack,
    iconNotify: iconNotify ?? this.iconNotify,
    errorStrong: errorStrong ?? this.errorStrong,
    errorSub: errorSub ?? this.errorSub,
    errorSoft: errorSoft ?? this.errorSoft,
    errorDisabled: errorDisabled ?? this.errorDisabled,
    successStrong: successStrong ?? this.successStrong,
    successPrimary: successPrimary ?? this.successPrimary,
    successSub: successSub ?? this.successSub,
    successSoft: successSoft ?? this.successSoft,
    successDisabled: successDisabled ?? this.successDisabled,
    avatarPlaceholder: avatarPlaceholder ?? this.avatarPlaceholder,
    controlTextSecondary: controlTextSecondary ?? this.controlTextSecondary,
    controlTextDisabled: controlTextDisabled ?? this.controlTextDisabled,
    controlBgDisabled: controlBgDisabled ?? this.controlBgDisabled,
    controlBgDisabledStrong:
        controlBgDisabledStrong ?? this.controlBgDisabledStrong,
    controlTextDisabledStrong:
        controlTextDisabledStrong ?? this.controlTextDisabledStrong,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      backgroundBase: Color.lerp(backgroundBase, other.backgroundBase, t)!,
      backgroundBase2: Color.lerp(backgroundBase2, other.backgroundBase2, t)!,
      backgroundElevation1: Color.lerp(
        backgroundElevation1,
        other.backgroundElevation1,
        t,
      )!,
      backgroundElevation1Alt: Color.lerp(
        backgroundElevation1Alt,
        other.backgroundElevation1Alt,
        t,
      )!,
      backgroundElevation2: Color.lerp(
        backgroundElevation2,
        other.backgroundElevation2,
        t,
      )!,
      backgroundElevation2Alt: Color.lerp(
        backgroundElevation2Alt,
        other.backgroundElevation2Alt,
        t,
      )!,
      backgroundElevation3: Color.lerp(
        backgroundElevation3,
        other.backgroundElevation3,
        t,
      )!,
      backgroundElevation3Alt: Color.lerp(
        backgroundElevation3Alt,
        other.backgroundElevation3Alt,
        t,
      )!,
      foregroundPrimary: Color.lerp(
        foregroundPrimary,
        other.foregroundPrimary,
        t,
      )!,
      foregroundAccent: Color.lerp(
        foregroundAccent,
        other.foregroundAccent,
        t,
      )!,
      popover: Color.lerp(popover, other.popover, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      accentSub: Color.lerp(accentSub, other.accentSub, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentDisabled: Color.lerp(accentDisabled, other.accentDisabled, t)!,
      accentWhite: Color.lerp(accentWhite, other.accentWhite, t)!,
      textStrong: Color.lerp(textStrong, other.textStrong, t)!,
      textSub: Color.lerp(textSub, other.textSub, t)!,
      textSoft: Color.lerp(textSoft, other.textSoft, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textWhite: Color.lerp(textWhite, other.textWhite, t)!,
      textAccent: Color.lerp(textAccent, other.textAccent, t)!,
      textInWhite: Color.lerp(textInWhite, other.textInWhite, t)!,
      textInDark: Color.lerp(textInDark, other.textInDark, t)!,
      strokeStrong: Color.lerp(strokeStrong, other.strokeStrong, t)!,
      strokeSub: Color.lerp(strokeSub, other.strokeSub, t)!,
      strokeSoft: Color.lerp(strokeSoft, other.strokeSoft, t)!,
      strokeAccent: Color.lerp(strokeAccent, other.strokeAccent, t)!,
      strokeWhite: Color.lerp(strokeWhite, other.strokeWhite, t)!,
      iconStrong: Color.lerp(iconStrong, other.iconStrong, t)!,
      iconSub: Color.lerp(iconSub, other.iconSub, t)!,
      iconSoft: Color.lerp(iconSoft, other.iconSoft, t)!,
      iconDisabled: Color.lerp(iconDisabled, other.iconDisabled, t)!,
      iconWhite: Color.lerp(iconWhite, other.iconWhite, t)!,
      iconAccent: Color.lerp(iconAccent, other.iconAccent, t)!,
      iconInWhite: Color.lerp(iconInWhite, other.iconInWhite, t)!,
      iconInBlack: Color.lerp(iconInBlack, other.iconInBlack, t)!,
      iconNotify: Color.lerp(iconNotify, other.iconNotify, t)!,
      errorStrong: Color.lerp(errorStrong, other.errorStrong, t)!,
      errorSub: Color.lerp(errorSub, other.errorSub, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      errorDisabled: Color.lerp(errorDisabled, other.errorDisabled, t)!,
      successStrong: Color.lerp(successStrong, other.successStrong, t)!,
      successPrimary: Color.lerp(successPrimary, other.successPrimary, t)!,
      successSub: Color.lerp(successSub, other.successSub, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      successDisabled: Color.lerp(successDisabled, other.successDisabled, t)!,
      avatarPlaceholder: Color.lerp(
        avatarPlaceholder,
        other.avatarPlaceholder,
        t,
      )!,
      controlTextSecondary: Color.lerp(
        controlTextSecondary,
        other.controlTextSecondary,
        t,
      )!,
      controlTextDisabled: Color.lerp(
        controlTextDisabled,
        other.controlTextDisabled,
        t,
      )!,
      controlBgDisabled: Color.lerp(
        controlBgDisabled,
        other.controlBgDisabled,
        t,
      )!,
      controlBgDisabledStrong: Color.lerp(
        controlBgDisabledStrong,
        other.controlBgDisabledStrong,
        t,
      )!,
      controlTextDisabledStrong: Color.lerp(
        controlTextDisabledStrong,
        other.controlTextDisabledStrong,
        t,
      )!,
    );
  }
}
