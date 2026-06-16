part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Onboardingni login ma’lumotlari bilan ishga tushiradi (bosqichlar tuziladi,
/// lavozim olinadi, ruxsat holatlari tekshiriladi).
class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted(this.data);

  final OnboardingData data;

  @override
  List<Object?> get props => [data];
}

/// Lavozim (profil) yuklandi (ichki).
class OnboardingRoleLoaded extends OnboardingEvent {
  const OnboardingRoleLoaded(this.roleName);

  final String? roleName;

  @override
  List<Object?> get props => [roleName];
}

/// PageView qo‘lda surilib joriy sahifa o‘zgardi (cheklangan: maxUnlocked).
class OnboardingPageSettled extends OnboardingEvent {
  const OnboardingPageSettled(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

/// Pastki «Davom etish» tugmasi — keyingi bosqichga (ruxsat bo‘lsa).
class OnboardingNextPressed extends OnboardingEvent {
  const OnboardingNextPressed();
}

/// Ruxsat so‘rash (har bir karta tugmasi).
class OnboardingPermissionRequested extends OnboardingEvent {
  const OnboardingPermissionRequested(this.permission);

  final OnboardingPermission permission;

  @override
  List<Object?> get props => [permission];
}

/// Eski parol maydoni o‘zgardi (`change-password`ning `old_password`i).
class OnboardingOldPasswordChanged extends OnboardingEvent {
  const OnboardingOldPasswordChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Yangi parol maydoni o‘zgardi (`new_password`).
class OnboardingPasswordChanged extends OnboardingEvent {
  const OnboardingPasswordChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Yangi parolni tasdiqlash maydoni o‘zgardi (`confirm_new_password`).
class OnboardingConfirmPasswordChanged extends OnboardingEvent {
  const OnboardingConfirmPasswordChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Parol shartlari to‘liq → serverga yuborish, muvaffaqiyatda keyingi bosqich.
class OnboardingPasswordSubmitted extends OnboardingEvent {
  const OnboardingPasswordSubmitted();
}

/// Rasm tanlash so‘rovi (galereya) → tanlangach yuklash.
class OnboardingImagePickRequested extends OnboardingEvent {
  const OnboardingImagePickRequested();
}

/// Yuz tasdiqlandi (face bosqichidan) → keyingi (yakuniy) bosqich.
class OnboardingFaceVerifiedReported extends OnboardingEvent {
  const OnboardingFaceVerifiedReported();
}
