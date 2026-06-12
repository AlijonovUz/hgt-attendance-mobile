part of 'profile_bloc.dart';

/// Rasm manbai — UI `image_picker`ga bevosita bog‘lanmasligi uchun.
enum ImageSourceKind { gallery, camera }

enum ProfileStatus { initial, loading, loaded, failure }

enum ProfileUploadStatus { idle, uploading, success, failure }

/// Yuklash/olishdagi xato turi — widget lokalizatsiyaga o‘giradi.
enum ProfileErrorKind { none, network, unauthorized, server }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.loadErrorKind = ProfileErrorKind.none,
    this.pickedImagePath,
    this.uploadStatus = ProfileUploadStatus.idle,
    this.uploadErrorKind = ProfileErrorKind.none,
  });

  final ProfileStatus status;
  final Profile? profile;
  final ProfileErrorKind loadErrorKind;

  /// Tanlangan, hali yuklanmagan rasm (lokal fayl yo‘li).
  final String? pickedImagePath;
  final ProfileUploadStatus uploadStatus;
  final ProfileErrorKind uploadErrorKind;

  /// Profil yuklangan, lekin rasm yo‘q → modal so‘rov ochiladi.
  bool get needsPhoto =>
      status == ProfileStatus.loaded &&
      profile != null &&
      !profile!.hasFaceImage;

  bool get isUploading => uploadStatus == ProfileUploadStatus.uploading;

  bool get hasPickedImage =>
      pickedImagePath != null && pickedImagePath!.isNotEmpty;

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    ProfileErrorKind? loadErrorKind,
    String? pickedImagePath,
    bool clearPickedImage = false,
    ProfileUploadStatus? uploadStatus,
    ProfileErrorKind? uploadErrorKind,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      loadErrorKind: loadErrorKind ?? this.loadErrorKind,
      pickedImagePath:
          clearPickedImage ? null : (pickedImagePath ?? this.pickedImagePath),
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadErrorKind: uploadErrorKind ?? this.uploadErrorKind,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        loadErrorKind,
        pickedImagePath,
        uploadStatus,
        uploadErrorKind,
      ];
}
