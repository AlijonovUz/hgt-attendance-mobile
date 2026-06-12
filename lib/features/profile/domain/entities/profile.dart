import 'package:equatable/equatable.dart';

/// Joriy foydalanuvchi profili (GET `/v1/users/auth/profile/`).
///
/// Faqat UI uchun kerakli maydonlar olib qolingan. [faceImage] — profil/yuz
/// rasmi URL’i; bo‘sh bo‘lsa foydalanuvchidan rasm o‘rnatish so‘raladi.
class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.fullName,
    this.phone,
    this.faceImage,
    this.roleName,
    this.departmentName,
  });

  final String id;
  final String fullName;
  final String? phone;

  /// Profil rasmi (URI). `null`/bo‘sh → rasm hali yuklanmagan.
  final String? faceImage;

  final String? roleName;
  final String? departmentName;

  /// Profil rasmi mavjudligi — modal so‘rovni shu hal qiladi.
  bool get hasFaceImage =>
      faceImage != null && faceImage!.trim().isNotEmpty;

  Profile copyWith({String? faceImage}) => Profile(
        id: id,
        fullName: fullName,
        phone: phone,
        faceImage: faceImage ?? this.faceImage,
        roleName: roleName,
        departmentName: departmentName,
      );

  @override
  List<Object?> get props =>
      [id, fullName, phone, faceImage, roleName, departmentName];
}
