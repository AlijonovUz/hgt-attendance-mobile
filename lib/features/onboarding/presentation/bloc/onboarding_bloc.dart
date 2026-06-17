import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../profile/domain/usecases/get_profile_usecase.dart';
import '../../../profile/domain/usecases/update_face_image_usecase.dart';
import '../../domain/entities/onboarding_data.dart';
import '../../domain/entities/password_rule.dart';
import '../../domain/usecases/change_password_usecase.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// Login’dan keyingi majburiy sozlash oqimini boshqaradi (PageView).
///
/// Bosqichlar login javobidan kelib chiqadi: welcome → permissions →
/// (`is_password_changed == false` bo‘lsa) password → (`face_image` yo‘q bo‘lsa)
/// imageUpload → faceVerify → done. Har bosqich «gate» yopilmaguncha oldinga
/// o‘tib bo‘lmaydi ([maxUnlockedIndex]). Bloc context-free: xato enumlarini
/// emit qiladi, lokalizatsiya widget qatlamida.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({
    required ChangePasswordUseCase changePassword,
    required GetProfileUseCase getProfile,
    required UpdateFaceImageUseCase updateFaceImage,
    required ImagePickerService imagePicker,
  }) : _changePassword = changePassword,
       _getProfile = getProfile,
       _updateFaceImage = updateFaceImage,
       _imagePicker = imagePicker,
       super(OnboardingState.initial()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingRoleLoaded>(_onRoleLoaded);
    on<OnboardingPageSettled>(_onPageSettled);
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingPermissionRequested>(_onPermissionRequested);
    on<OnboardingOldPasswordChanged>(_onOldPasswordChanged);
    on<OnboardingPasswordChanged>(_onPasswordChanged);
    on<OnboardingConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<OnboardingPasswordSubmitted>(_onPasswordSubmitted);
    on<OnboardingImagePickRequested>(_onImagePickRequested);
    on<OnboardingFaceVerifiedReported>(_onFaceVerified);
  }

  final ChangePasswordUseCase _changePassword;
  final GetProfileUseCase _getProfile;
  final UpdateFaceImageUseCase _updateFaceImage;
  final ImagePickerService _imagePicker;

  /// Login ma’lumotidan bosqichlar ro‘yxatini tuzadi.
  static List<OnboardingStep> _buildSteps(OnboardingData data) {
    return [
      OnboardingStep.welcome,
      OnboardingStep.permissions,
      if (!data.isPasswordChanged) OnboardingStep.password,
      if (!data.hasFaceImage) OnboardingStep.imageUpload,
      OnboardingStep.faceVerify,
      OnboardingStep.done,
    ];
  }

  Future<void> _onStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    final location = await Permission.location.status;
    final camera = await Permission.camera.status;
    emit(
      OnboardingState(
        data: event.data,
        steps: _buildSteps(event.data),
        locationGranted: location.isGranted || location.isLimited,
        cameraGranted: camera.isGranted || camera.isLimited,
        // Login’da kiritilgan parol — «eski parol» maydoniga oldindan.
        oldPassword: event.data.loginPassword,
      ),
    );

    // Lavozim profil endpointidan (RAM token bilan) — bloklamaydi.
    try {
      final profile = await _getProfile(
        GetProfileParams(accessToken: event.data.accessToken),
      );
      if (!isClosed) add(OnboardingRoleLoaded(profile.roleName));
    } catch (_) {
      // Lavozim olinmadi — UI fallback ko‘rsatadi.
    }
  }

  void _onRoleLoaded(
    OnboardingRoleLoaded event,
    Emitter<OnboardingState> emit,
  ) {
    if (event.roleName == null || event.roleName!.trim().isEmpty) return;
    emit(state.copyWith(data: state.data.copyWith(roleName: event.roleName)));
  }

  void _onPageSettled(
    OnboardingPageSettled event,
    Emitter<OnboardingState> emit,
  ) {
    final clamped = event.index.clamp(0, state.maxUnlockedIndex);
    if (clamped == state.currentIndex) return;
    emit(state.copyWith(currentIndex: clamped));
  }

  void _onNextPressed(
    OnboardingNextPressed event,
    Emitter<OnboardingState> emit,
  ) {
    if (!state.canAdvanceCurrent) return;
    emit(state.copyWith(currentIndex: state.currentIndex + 1));
  }

  Future<void> _onPermissionRequested(
    OnboardingPermissionRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    final permission = switch (event.permission) {
      OnboardingPermission.location => Permission.location,
      OnboardingPermission.camera => Permission.camera,
    };
    var status = await permission.request();
    // Doimiy rad etilgan bo‘lsa — sozlamalarni ochamiz (foydalanuvchi qaytsa
    // holat keyingi bosqich tekshiruvida yangilanadi).
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      status = await permission.status;
    }
    final granted = status.isGranted || status.isLimited;
    emit(switch (event.permission) {
      OnboardingPermission.location => state.copyWith(locationGranted: granted),
      OnboardingPermission.camera => state.copyWith(cameraGranted: granted),
    });
  }

  void _onOldPasswordChanged(
    OnboardingOldPasswordChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        oldPassword: event.value,
        passwordError: OnboardingErrorKind.none,
      ),
    );
  }

  void _onPasswordChanged(
    OnboardingPasswordChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        newPassword: event.value,
        passwordError: OnboardingErrorKind.none,
      ),
    );
  }

  void _onConfirmPasswordChanged(
    OnboardingConfirmPasswordChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        confirmPassword: event.value,
        passwordError: OnboardingErrorKind.none,
      ),
    );
  }

  Future<void> _onPasswordSubmitted(
    OnboardingPasswordSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!state.canSubmitPassword) return;
    emit(
      state.copyWith(
        passwordSubmitting: true,
        passwordError: OnboardingErrorKind.none,
      ),
    );
    try {
      await _changePassword(
        ChangePasswordParams(
          oldPassword: state.oldPassword,
          newPassword: state.newPassword,
          confirmNewPassword: state.confirmPassword,
          accessToken: state.data.accessToken,
        ),
      );
      // Yopilgach: belgilab, keyingi bosqichga o‘tamiz.
      emit(
        state.copyWith(
          passwordSubmitting: false,
          passwordChanged: true,
          currentIndex: state.currentIndex + 1,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          passwordSubmitting: false,
          passwordError: failure is NetworkFailure
              ? OnboardingErrorKind.network
              : OnboardingErrorKind.server,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          passwordSubmitting: false,
          passwordError: OnboardingErrorKind.server,
        ),
      );
    }
  }

  Future<void> _onImagePickRequested(
    OnboardingImagePickRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state.imageUploading) return;
    final path = await _imagePicker.pickFromGallery();
    if (path == null) return; // bekor qilindi
    emit(
      state.copyWith(
        pickedImagePath: path,
        imageUploading: true,
        imageUploaded: false,
        imageError: OnboardingErrorKind.none,
      ),
    );
    try {
      await _updateFaceImage(
        UpdateFaceImageParams(
          imagePath: path,
          accessToken: state.data.accessToken,
        ),
      );
      emit(state.copyWith(imageUploading: false, imageUploaded: true));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          imageUploading: false,
          imageUploaded: false,
          imageError: failure is NetworkFailure
              ? OnboardingErrorKind.network
              : OnboardingErrorKind.server,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          imageUploading: false,
          imageUploaded: false,
          imageError: OnboardingErrorKind.server,
        ),
      );
    }
  }

  void _onFaceVerified(
    OnboardingFaceVerifiedReported event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.faceVerified) return;
    final nextIndex = state.currentIndex < state.steps.length - 1
        ? state.currentIndex + 1
        : state.currentIndex;
    emit(state.copyWith(faceVerified: true, currentIndex: nextIndex));
  }
}
