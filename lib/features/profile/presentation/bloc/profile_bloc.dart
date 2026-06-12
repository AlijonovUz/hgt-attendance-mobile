import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/usecases/no_params.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_face_image_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Profil holatini boshqaradi: yuklash + rasm tanlash + `face_image` yuklash.
///
/// Profil olingach, rasm yo‘q bo‘lsa [ProfileState.needsPhoto] `true` bo‘ladi va
/// home modal so‘rovni ko‘rsatadi. Foydalanuvchi qurilmadan rasm tanlaydi
/// ([ProfilePhotoPickRequested]) → ko‘rib chiqadi → yuklaydi
/// ([ProfilePhotoSubmitted]) → PATCH `face_image`.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetProfileUseCase getProfile,
    required UpdateFaceImageUseCase updateFaceImage,
    required ImagePickerService imagePicker,
  })  : _getProfile = getProfile,
        _updateFaceImage = updateFaceImage,
        _imagePicker = imagePicker,
        super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
    on<ProfileUploadAuthProvided>(_onAuthProvided);
    on<ProfilePhotoPickRequested>(_onPickRequested);
    on<ProfilePhotoCleared>(_onCleared);
    on<ProfilePhotoSubmitted>(_onSubmitted);
  }

  final GetProfileUseCase _getProfile;
  final UpdateFaceImageUseCase _updateFaceImage;
  final ImagePickerService _imagePicker;

  /// Yuzdan oldingi bosqich uchun manual access token (saqlanmagan).
  String? _uploadAccessToken;

  void _onAuthProvided(
    ProfileUploadAuthProvided event,
    Emitter<ProfileState> emit,
  ) {
    _uploadAccessToken = event.accessToken;
  }

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      status: ProfileStatus.loading,
      loadErrorKind: ProfileErrorKind.none,
    ));
    try {
      final profile = await _getProfile(const NoParams());
      emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
    } on Failure catch (failure) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        loadErrorKind: _kindOf(failure),
      ));
    }
  }

  Future<void> _onPickRequested(
    ProfilePhotoPickRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final path = event.source == ImageSourceKind.camera
        ? await _imagePicker.pickFromCamera()
        : await _imagePicker.pickFromGallery();
    if (path == null) return; // bekor qilindi
    emit(state.copyWith(
      pickedImagePath: path,
      uploadStatus: ProfileUploadStatus.idle,
      uploadErrorKind: ProfileErrorKind.none,
    ));
  }

  void _onCleared(ProfilePhotoCleared event, Emitter<ProfileState> emit) {
    emit(state.copyWith(
      clearPickedImage: true,
      uploadStatus: ProfileUploadStatus.idle,
      uploadErrorKind: ProfileErrorKind.none,
    ));
  }

  Future<void> _onSubmitted(
    ProfilePhotoSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    final path = state.pickedImagePath;
    if (path == null || path.isEmpty || state.isUploading) return;

    emit(state.copyWith(
      uploadStatus: ProfileUploadStatus.uploading,
      uploadErrorKind: ProfileErrorKind.none,
    ));
    try {
      final updated = await _updateFaceImage(
        UpdateFaceImageParams(imagePath: path, accessToken: _uploadAccessToken),
      );
      // Server rasm URL’ini qaytarmasa — lokal yo‘l bilan gate’ni yopamiz.
      final profile = updated.hasFaceImage
          ? updated
          : (state.profile ?? updated).copyWith(faceImage: path);
      emit(state.copyWith(
        profile: profile,
        uploadStatus: ProfileUploadStatus.success,
        clearPickedImage: true,
      ));
    } on Failure catch (failure) {
      emit(state.copyWith(
        uploadStatus: ProfileUploadStatus.failure,
        uploadErrorKind: _kindOf(failure),
      ));
    }
  }

  ProfileErrorKind _kindOf(Failure failure) => switch (failure) {
        NetworkFailure() => ProfileErrorKind.network,
        UnauthorizedFailure() => ProfileErrorKind.unauthorized,
        _ => ProfileErrorKind.server,
      };
}
