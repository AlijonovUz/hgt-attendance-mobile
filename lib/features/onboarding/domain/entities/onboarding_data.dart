import 'package:equatable/equatable.dart';

/// Login’dan keyin onboarding oqimini boshqaruvchi ma’lumotlar to‘plami.
///
/// [accessToken] hali saqlanmagan (RAM’dagi) token — onboarding so‘rovlari
/// (parol o‘rnatish, rasm yuklash, yuz tasdig‘i) manual Bearer sifatida
/// ishlatadi. [faceImage]/[isPasswordChanged] qaysi bosqichlar ko‘rsatilishini
/// hal qiladi. [roleName] welcome kartasidagi lavozim.
class OnboardingData extends Equatable {
  const OnboardingData({
    required this.accessToken,
    required this.fullName,
    required this.isPasswordChanged,
    this.loginPassword = '',
    this.faceImage,
    this.roleName,
  });

  final String accessToken;
  final String fullName;
  final bool isPasswordChanged;

  /// Login’da kiritilgan parol — parol bosqichida «eski parol» maydoniga oldindan
  /// qo‘yiladi (`change-password`ning `old_password`i).
  final String loginPassword;
  final String? faceImage;
  final String? roleName;

  /// Login javobida profil rasmi bormi (yo‘q bo‘lsa — rasm yuklash bosqichi).
  bool get hasFaceImage => faceImage != null && faceImage!.trim().isNotEmpty;

  OnboardingData copyWith({String? roleName}) => OnboardingData(
    accessToken: accessToken,
    fullName: fullName,
    isPasswordChanged: isPasswordChanged,
    loginPassword: loginPassword,
    faceImage: faceImage,
    roleName: roleName ?? this.roleName,
  );

  @override
  List<Object?> get props => [
    accessToken,
    fullName,
    isPasswordChanged,
    loginPassword,
    faceImage,
    roleName,
  ];
}
