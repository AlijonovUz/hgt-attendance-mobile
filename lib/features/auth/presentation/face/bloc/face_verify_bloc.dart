import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../attendance/domain/usecases/mark_attendance_usecase.dart';
import '../../../domain/usecases/verify_face_usecase.dart';
import 'face_flow_mode.dart';

part 'face_verify_event.dart';
part 'face_verify_state.dart';

/// Backend `errorMsg`ini qaytaradi — umumiy/zaxira xabarlar `null` (UI l10n
/// fallback’iga tushadi).
String? _friendlyFaceMessage(String message) {
  final m = message.trim();
  final lower = m.toLowerCase();
  if (m.isEmpty ||
      lower == 'server failure' ||
      lower == 'server xatosi' ||
      lower == 'unauthorized' ||
      lower == 'too many requests') {
    return null;
  }
  return m;
}

/// Universal yuz-tekshiruv: kamera oqimi + ML Kit yuz aniqlash + (rejimga qarab)
/// `verify-face` yoki `attendance` yuborish.
///
/// Rejim [FaceFlowMode] orqali keladi:
/// - [LoginFaceMode] — login’dan keyingi yuz tasdig‘i (RAM access token,
///   2xx → sahifa `SessionFaceVerified` yuboradi).
/// - [AttendanceFaceMode] — davomat hodisasi (start’da GPS olinadi, selfie
///   `event_type` + koordinata bilan yuboriladi; 2xx → sahifa `pop(true)`).
///
/// Tirik oqimda yuz barqaror aniqlansa, selfie avtomatik olinadi va yuboriladi.
class FaceVerifyBloc extends Bloc<FaceVerifyEvent, FaceVerifyState> {
  FaceVerifyBloc({
    required VerifyFaceUseCase verifyFaceUseCase,
    required MarkAttendanceUseCase markAttendance,
    required LocationService location,
  }) : _verifyFace = verifyFaceUseCase,
       _markAttendance = markAttendance,
       _location = location,
       super(const FaceVerifyState()) {
    on<FaceStarted>(_onStarted);
    on<FaceDetectionUpdated>(_onDetectionUpdated);
    on<FaceCaptureRequested>(_onCaptureRequested);
    on<FaceRetryRequested>(_onRetryRequested);
  }

  final VerifyFaceUseCase _verifyFace;
  final MarkAttendanceUseCase _markAttendance;
  final LocationService _location;

  CameraController? _controller;
  FaceDetector? _detector;
  FaceFlowMode _mode = const LoginFaceMode(accessToken: '', fullName: '');
  double? _lat;
  double? _lng;

  bool _detectorBusy = false;
  DateTime _lastDetect = DateTime.fromMillisecondsSinceEpoch(0);
  int _positiveStreak = 0;

  /// Preview widgeti uchun — tirik kamera kontrolleri (yoki null).
  CameraController? get cameraController => _controller;

  static const _detectThrottle = Duration(milliseconds: 250);
  static const _captureStreak = 6;

  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  Future<void> _onStarted(
    FaceStarted event,
    Emitter<FaceVerifyState> emit,
  ) async {
    final mode = event.mode;
    _mode = mode;
    emit(
      state.copyWith(
        status: FaceStatus.initializing,
        fullName: mode is LoginFaceMode ? mode.fullName : '',
        failureKind: FaceFailureKind.none,
        clearFailureMessage: true,
      ),
    );

    final granted = await _ensurePermission();
    if (!granted) {
      emit(state.copyWith(status: FaceStatus.permissionDenied));
      return;
    }

    // Davomat rejimida GPS start’da olinadi (xato → failure(location)).
    if (mode is AttendanceFaceMode) {
      try {
        final pos = await _location.current();
        _lat = pos.latitude;
        _lng = pos.longitude;
      } on LocationException {
        emit(
          state.copyWith(
            status: FaceStatus.failure,
            failureKind: FaceFailureKind.location,
            clearFailureMessage: true,
          ),
        );
        return;
      }
    }

    final ok = await _initCamera();
    if (!ok) {
      emit(state.copyWith(status: FaceStatus.cameraError));
      return;
    }

    _detector ??= FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: 0.15,
      ),
    );

    await _startStream();
    if (emit.isDone) return;
    emit(state.copyWith(status: FaceStatus.scanning));
  }

  Future<bool> _ensurePermission() async {
    final status = await Permission.camera.request();
    return status.isGranted || status.isLimited;
  }

  Future<bool> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return false;
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      _controller = controller;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _startStream() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isStreamingImages) return;
    _positiveStreak = 0;
    await controller.startImageStream(_onCameraImage);
  }

  Future<void> _stopStream() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (!controller.value.isStreamingImages) return;
    await controller.stopImageStream();
  }

  void _onCameraImage(CameraImage image) {
    if (isClosed || _detectorBusy) return;
    final now = DateTime.now();
    if (now.difference(_lastDetect) < _detectThrottle) return;
    _lastDetect = now;

    final inputImage = _toInputImage(image);
    if (inputImage == null) return;

    _detectorBusy = true;
    _detector
        ?.processImage(inputImage)
        .then((faces) {
          if (!isClosed) {
            add(FaceDetectionUpdated(facePresent: faces.isNotEmpty));
          }
        })
        .catchError((_) {
          // Kadr xatosi — keyingi kadrda qayta uriniladi.
        })
        .whenComplete(() => _detectorBusy = false);
  }

  void _onDetectionUpdated(
    FaceDetectionUpdated event,
    Emitter<FaceVerifyState> emit,
  ) {
    // Faqat tirik skan paytida hisoblaymiz.
    if (state.status != FaceStatus.scanning &&
        state.status != FaceStatus.detecting) {
      return;
    }

    if (!event.facePresent) {
      _positiveStreak = 0;
      if (state.status != FaceStatus.scanning) {
        emit(state.copyWith(status: FaceStatus.scanning));
      }
      return;
    }

    _positiveStreak++;
    if (state.status != FaceStatus.detecting) {
      emit(state.copyWith(status: FaceStatus.detecting));
    }
    if (_positiveStreak >= _captureStreak) {
      _positiveStreak = 0;
      add(const FaceCaptureRequested());
    }
  }

  Future<void> _onCaptureRequested(
    FaceCaptureRequested event,
    Emitter<FaceVerifyState> emit,
  ) async {
    if (state.status == FaceStatus.verifying) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final mode = _mode;
    if (mode is AttendanceFaceMode && (_lat == null || _lng == null)) return;

    emit(state.copyWith(status: FaceStatus.verifying));
    try {
      await _stopStream();
      final XFile shot = await controller.takePicture();
      if (mode is AttendanceFaceMode) {
        await _markAttendance(
          MarkAttendanceParams(
            eventType: mode.eventType,
            latitude: _lat!,
            longitude: _lng!,
            imagePath: shot.path,
          ),
        );
      } else if (mode is LoginFaceMode) {
        await _verifyFace(
          VerifyFaceParams(imagePath: shot.path, accessToken: mode.accessToken),
        );
      }
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: FaceStatus.success,
          failureKind: FaceFailureKind.none,
          clearFailureMessage: true,
        ),
      );
    } on Failure catch (failure) {
      if (emit.isDone) return;
      final isNetwork = failure is NetworkFailure;
      emit(
        state.copyWith(
          status: FaceStatus.failure,
          failureKind: isNetwork
              ? FaceFailureKind.network
              : FaceFailureKind.verifyFailed,
          // Backend `errorMsg`i bo‘lsa UI uni ko‘rsatadi (aks holda l10n fallback).
          failureMessage: isNetwork
              ? null
              : _friendlyFaceMessage(failure.message),
          clearFailureMessage: isNetwork,
        ),
      );
      // Xato → kamerani to‘liq bo‘shatamiz (resurs/performans). Qayta urinishda
      // qaytadan ishga tushadi.
      await _disposeCamera();
    } catch (_) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: FaceStatus.failure,
          failureKind: FaceFailureKind.verifyFailed,
          clearFailureMessage: true,
        ),
      );
      await _disposeCamera();
    }
  }

  Future<void> _onRetryRequested(
    FaceRetryRequested event,
    Emitter<FaceVerifyState> emit,
  ) async {
    // Xatoda kamera bo‘shatilgan — to‘liq oqimni (ruxsat → GPS → kamera) saqlangan
    // rejim bilan qaytadan boshlaymiz.
    add(FaceStarted(_mode));
  }

  /// Kamerani to‘liq bo‘shatadi (stream + controller). Detektor saqlanadi —
  /// qayta urinish tezroq bo‘lishi uchun.
  Future<void> _disposeCamera() async {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      await controller.dispose();
    } catch (_) {}
  }

  /// `CameraImage`ni ML Kit `InputImage`ga o‘giradi (NV21/BGRA, rotatsiya bilan).
  InputImage? _toInputImage(CameraImage image) {
    final controller = _controller;
    if (controller == null) return null;
    final camera = controller.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else {
      final compensation = _orientations[controller.value.deviceOrientation];
      if (compensation == null) return null;
      final rotationDegrees = camera.lensDirection == CameraLensDirection.front
          ? (sensorOrientation + compensation) % 360
          : (sensorOrientation - compensation + 360) % 360;
      rotation = InputImageRotationValue.fromRawValue(rotationDegrees);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    if (image.planes.isEmpty) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  Future<void> close() async {
    final controller = _controller;
    _controller = null;
    try {
      if (controller != null) {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
        await controller.dispose();
      }
    } catch (_) {}
    await _detector?.close();
    _detector = null;
    return super.close();
  }
}
