import '../../domain/entities/auth_tokens.dart';

/// Login javobidagi token juftligi + profil holati. Backend ham
/// `{ access, refresh }` (xom SimpleJWT), ham `{ data: { access, refresh, user },
/// success }` (konvert) ko‘rinishini qaytarishi mumkin — ikkalasini ham
/// qo‘llab-quvvatlaymiz. `face_image`, `full_name`, `is_password_changed`
/// `data.user`’dan o‘qiladi (onboarding oqimi shu maydonlardan kelib chiqadi).
class AuthTokensModel {
  const AuthTokensModel({
    required this.access,
    required this.refresh,
    this.faceImage,
    this.fullName,
    this.isPasswordChanged = true,
  });

  final String access;
  final String refresh;
  final String? faceImage;
  final String? fullName;
  final bool isPasswordChanged;

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final src = json['data'] is Map
        ? (json['data'] as Map).cast<String, dynamic>()
        : json;
    final user = src['user'] is Map
        ? (src['user'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final face = user['face_image'] ?? src['face_image'];
    final name = user['full_name'] ?? src['full_name'];
    // `is_password_changed` yo‘q bo‘lsa — parol bosqichini majburlamaymiz (true).
    final changed = user['is_password_changed'] ?? src['is_password_changed'];
    return AuthTokensModel(
      access: src['access'] as String? ?? '',
      refresh: src['refresh'] as String? ?? '',
      faceImage:
          face is String && face.trim().isNotEmpty ? face.trim() : null,
      fullName:
          name is String && name.trim().isNotEmpty ? name.trim() : null,
      isPasswordChanged: changed is bool ? changed : true,
    );
  }

  AuthTokens toEntity() => AuthTokens(
        access: access,
        refresh: refresh,
        faceImage: faceImage,
        fullName: fullName,
        isPasswordChanged: isPasswordChanged,
      );
}
