import '../entities/profile.dart';

/// Profil domeni shartnomasi. Xatolarda `Failure` (core/error/failures.dart)
/// `throw` qiladi; bloc ularni xato enumiga, widget esa lokalizatsiyaga o‘giradi.
abstract interface class ProfileRepository {
  /// Joriy foydalanuvchi profilini oladi.
  Future<Profile> getProfile();

  /// Faqat profil rasmini (`face_image`) yangilaydi — multipart PATCH.
  /// Yangilangan profil qaytadi. [accessToken] berilsa manual Bearer (token
  /// hali saqlanmagan bosqich uchun).
  Future<Profile> updateFaceImage(String imagePath, {String? accessToken});
}
