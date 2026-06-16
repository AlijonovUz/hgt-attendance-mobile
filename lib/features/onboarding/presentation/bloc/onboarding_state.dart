part of 'onboarding_bloc.dart';

/// Onboarding bosqichlari (PageView sahifalari). [done] — yakuniy «Hammasi
/// tayyor!» ekrani (progress/orqaga yo‘q).
enum OnboardingStep { welcome, permissions, password, imageUpload, faceVerify, done }

/// So‘raladigan ruxsatlar.
enum OnboardingPermission { location, camera }

/// Bosqich xatosi turi — lokalizatsiya widget qatlamida.
enum OnboardingErrorKind { none, network, server }

class OnboardingState extends Equatable {
  const OnboardingState({
    required this.data,
    required this.steps,
    this.currentIndex = 0,
    this.locationGranted = false,
    this.cameraGranted = false,
    this.oldPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.passwordSubmitting = false,
    this.passwordChanged = false,
    this.passwordError = OnboardingErrorKind.none,
    this.pickedImagePath,
    this.imageUploading = false,
    this.imageUploaded = false,
    this.imageError = OnboardingErrorKind.none,
    this.faceVerified = false,
  });

  /// Boshlang‘ich (bo‘sh) holat — bloc qurilishida (`OnboardingStarted`gacha).
  factory OnboardingState.initial() => const OnboardingState(
        data: OnboardingData(
          accessToken: '',
          fullName: '',
          isPasswordChanged: true,
        ),
        steps: [OnboardingStep.welcome],
      );

  final OnboardingData data;
  final List<OnboardingStep> steps;
  final int currentIndex;

  final bool locationGranted;
  final bool cameraGranted;

  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  final bool passwordSubmitting;
  final bool passwordChanged;
  final OnboardingErrorKind passwordError;

  /// Qurilmadan tanlangan, yuklangan rasm yo‘li (lokal).
  final String? pickedImagePath;
  final bool imageUploading;
  final bool imageUploaded;
  final OnboardingErrorKind imageError;

  final bool faceVerified;

  OnboardingStep get currentStep =>
      steps[currentIndex.clamp(0, steps.length - 1)];

  /// Faqat progress ko‘rsatkichida hisoblanadigan bosqichlar (yakuniysiz).
  int get progressTotal =>
      steps.where((s) => s != OnboardingStep.done).length;

  /// Joriy bosqichning progressdagi tartibi (1‑asosli, `done`da progress yo‘q).
  int get progressIndex => currentStep == OnboardingStep.done
      ? progressTotal
      : currentIndex.clamp(0, progressTotal - 1);

  bool get showChrome => currentStep != OnboardingStep.done;

  /// Yuz tasdig‘i va inset uchun mos rasm: login rasmi yoki yuklangani.
  String? get referenceImageUrl => data.faceImage;
  String? get referenceImagePath => pickedImagePath;

  /// Yangi parolda qondirilgan shartlar (jonli ko‘rsatkich).
  Set<PasswordRule> get satisfiedRules => PasswordRule.values
      .where((rule) => rule.isSatisfiedBy(newPassword))
      .toSet();

  /// Yangi parol barcha shartlarni qondiradimi.
  bool get isNewPasswordStrong =>
      PasswordRule.values.every((rule) => rule.isSatisfiedBy(newPassword));

  /// Ikkala yangi parol mos kelganmi (tasdiqlash maydoni bo‘sh emas + teng).
  bool get passwordsMatch =>
      confirmPassword.isNotEmpty && newPassword == confirmPassword;

  /// Parolni yuborish mumkinmi: eski kiritilgan, yangisi kuchli, tasdiq mos.
  bool get canSubmitPassword =>
      oldPassword.isNotEmpty &&
      isNewPasswordStrong &&
      passwordsMatch &&
      !passwordSubmitting;

  /// Bosqich yakunlanganmi (keyingisiga ruxsat shartidan kelib chiqadi).
  bool isStepComplete(OnboardingStep step) => switch (step) {
        OnboardingStep.welcome => true,
        OnboardingStep.permissions => locationGranted && cameraGranted,
        OnboardingStep.password => passwordChanged,
        OnboardingStep.imageUpload => imageUploaded,
        OnboardingStep.faceVerify => faceVerified,
        OnboardingStep.done => true,
      };

  /// Foydalanuvchi yetib bora oladigan eng katta indeks (oldingi barcha
  /// bosqichlar yakunlangan bo‘lsa). Oldinga surishni cheklash uchun.
  int get maxUnlockedIndex {
    var i = 0;
    while (i < steps.length - 1 && isStepComplete(steps[i])) {
      i++;
    }
    return i;
  }

  /// Joriy bosqichdan keyingisiga o‘tish mumkinmi (pastki tugma).
  bool get canAdvanceCurrent =>
      currentIndex < steps.length - 1 && isStepComplete(currentStep);

  OnboardingState copyWith({
    OnboardingData? data,
    List<OnboardingStep>? steps,
    int? currentIndex,
    bool? locationGranted,
    bool? cameraGranted,
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
    bool? passwordSubmitting,
    bool? passwordChanged,
    OnboardingErrorKind? passwordError,
    String? pickedImagePath,
    bool clearPickedImage = false,
    bool? imageUploading,
    bool? imageUploaded,
    OnboardingErrorKind? imageError,
    bool? faceVerified,
  }) {
    return OnboardingState(
      data: data ?? this.data,
      steps: steps ?? this.steps,
      currentIndex: currentIndex ?? this.currentIndex,
      locationGranted: locationGranted ?? this.locationGranted,
      cameraGranted: cameraGranted ?? this.cameraGranted,
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      passwordSubmitting: passwordSubmitting ?? this.passwordSubmitting,
      passwordChanged: passwordChanged ?? this.passwordChanged,
      passwordError: passwordError ?? this.passwordError,
      pickedImagePath:
          clearPickedImage ? null : (pickedImagePath ?? this.pickedImagePath),
      imageUploading: imageUploading ?? this.imageUploading,
      imageUploaded: imageUploaded ?? this.imageUploaded,
      imageError: imageError ?? this.imageError,
      faceVerified: faceVerified ?? this.faceVerified,
    );
  }

  @override
  List<Object?> get props => [
        data,
        steps,
        currentIndex,
        locationGranted,
        cameraGranted,
        oldPassword,
        newPassword,
        confirmPassword,
        passwordSubmitting,
        passwordChanged,
        passwordError,
        pickedImagePath,
        imageUploading,
        imageUploaded,
        imageError,
        faceVerified,
      ];
}
