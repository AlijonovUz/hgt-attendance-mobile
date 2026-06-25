import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/face_image_cache_service.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../attendance/domain/usecases/sync_user_geozone_usecase.dart';
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
///
/// Offline‑first kesh: profil URL bilan kelsa [FaceImageCacheService] orqali
/// bayt‑bayt yuklab olinadi va `<docs>/face_images/<id>.jpg`ga yoziladi;
/// natija [Profile.localFaceImagePath]ga qo‘yiladi (avatar lokaldan render).
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetProfileUseCase getProfile,
    required UpdateFaceImageUseCase updateFaceImage,
    required ImagePickerService imagePicker,
    required FaceImageCacheService faceImageCache,
    required SyncUserGeozoneUseCase syncGeozone,
  })  : _getProfile = getProfile,
        _updateFaceImage = updateFaceImage,
        _imagePicker = imagePicker,
        _faceImageCache = faceImageCache,
        _syncGeozone = syncGeozone,
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
  final FaceImageCacheService _faceImageCache;
  final SyncUserGeozoneUseCase _syncGeozone;

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
      final profile = await _getProfile(const GetProfileParams());
      // Avval mavjud keshni biriktiramiz (offline kirishda darhol ko‘rinadi),
      // keyin URL bo‘lsa fonda yangilab qo‘yamiz.
      final cachedPath = await _faceImageCache.cachedPathFor(profile.id);
      final initial = cachedPath != null
          ? profile.copyWith(localFaceImagePath: cachedPath)
          : profile;
      emit(state.copyWith(status: ProfileStatus.loaded, profile: initial));

      // Geozonani fonda yangilaymiz (online bo‘lsa) — offline geofence keshi.
      // Xato (offline/server) → eski kesh saqlanadi, profil oqimi buzilmaydi.
      if (profile.branchId != null && profile.branchId!.isNotEmpty) {
        unawaited(_syncGeozone(profile.branchId!).catchError((_) => null));
      }

      if (profile.faceImage != null && profile.faceImage!.trim().isNotEmpty) {
        final stored = await _faceImageCache.downloadAndStore(
          userId: profile.id,
          faceImage: profile.faceImage!,
        );
        if (stored != null && !emit.isDone) {
          emit(state.copyWith(
            profile: initial.copyWith(localFaceImagePath: stored),
          ));
        }
      }
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
      // Tanlangan rasmni darhol kanonik kesh joyiga yozib qo‘yamiz (offline
      // davomat uchun): server URL’ini keyin tortib olishga muhtoj emasmiz.
      String? localPath;
      try {
        final bytes = await File(path).readAsBytes();
        localPath = await _faceImageCache.storeFromBytes(profile.id, bytes);
      } catch (_) {
        localPath = null;
      }
      emit(state.copyWith(
        profile: localPath != null
            ? profile.copyWith(localFaceImagePath: localPath)
            : profile,
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
