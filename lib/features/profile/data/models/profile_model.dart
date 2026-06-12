import '../../domain/entities/profile.dart';

/// `/v1/users/auth/profile/` javobini parslaydi.
///
/// Backend xom obyekt (`{ id, full_name, face_image, ... }`) yoki konvert
/// (`{ data: {...}, success }`) qaytarishi mumkin — ikkalasini ham qo‘llaymiz.
/// Ichki obyektlar (`role_info`, `department_info`) `name` maydonidan o‘qiladi.
class ProfileModel {
  const ProfileModel({
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
  final String? faceImage;
  final String? roleName;
  final String? departmentName;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final src = json['data'] is Map
        ? (json['data'] as Map).cast<String, dynamic>()
        : json;

    String? nestedName(Object? node) {
      if (node is Map && node['name'] is String) return node['name'] as String;
      return null;
    }

    String? asString(Object? v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return ProfileModel(
      id: asString(src['id']) ?? '',
      fullName: asString(src['full_name']) ?? '',
      phone: asString(src['phone']),
      faceImage: asString(src['face_image']),
      roleName: nestedName(src['role_info']) ?? nestedName(src['position_info']),
      departmentName: nestedName(src['department_info']),
    );
  }

  Profile toEntity() => Profile(
        id: id,
        fullName: fullName,
        phone: phone,
        faceImage: faceImage,
        roleName: roleName,
        departmentName: departmentName,
      );
}
