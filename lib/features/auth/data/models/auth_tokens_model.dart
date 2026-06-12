import '../../domain/entities/auth_tokens.dart';

/// Login javobidagi token juftligi + profil rasm holati. Backend ham
/// `{ access, refresh }` (xom SimpleJWT), ham `{ data: { access, refresh, user },
/// success }` (konvert) ko‘rinishini qaytarishi mumkin — ikkalasini ham
/// qo‘llab-quvvatlaymiz. `face_image` `data.user.face_image`’dan o‘qiladi.
class AuthTokensModel {
  const AuthTokensModel({
    required this.access,
    required this.refresh,
    this.faceImage,
  });

  final String access;
  final String refresh;
  final String? faceImage;

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final src = json['data'] is Map
        ? (json['data'] as Map).cast<String, dynamic>()
        : json;
    final user = src['user'] is Map
        ? (src['user'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final face = user['face_image'] ?? src['face_image'];
    return AuthTokensModel(
      access: src['access'] as String? ?? '',
      refresh: src['refresh'] as String? ?? '',
      faceImage:
          face is String && face.trim().isNotEmpty ? face.trim() : null,
    );
  }

  AuthTokens toEntity() =>
      AuthTokens(access: access, refresh: refresh, faceImage: faceImage);
}
