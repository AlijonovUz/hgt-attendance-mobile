import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/attendance_event_type.dart';
import '../../domain/usecases/mark_attendance_usecase.dart';

part 'attendance_check_event.dart';
part 'attendance_check_state.dart';

/// Davomat yuz-tekshiruvini boshqaradi: GPS + kamera oqimi + ML Kit yuz
/// aniqlash + `POST /v1/attendance/attendance/`.
///
/// Oqim `FaceVerifyBloc` namunasidan moslangan; farqi — start’da GPS olinadi
/// va selfie [MarkAttendanceUseCase] orqali `event_type` bilan yuboriladi
/// (saqlangan token AuthInterceptor orqali). 2xx → success.
class AttendanceCheckBloc
    extends Bloc<AttendanceCheckEvent, AttendanceCheckState> {
  AttendanceCheckBloc({
    required MarkAttendanceUseCase markAttendance,
    required LocationService location,
  }) : _markAttendance = markAttendance,
       _location = location,
       super(const AttendanceCheckState()) {
    on<AttendanceCheckStarted>(_onStarted);
    on<AttendanceFaceDetectionUpdated>(_onDetectionUpdated);
    on<AttendanceCaptureRequested>(_onCaptureRequested);
    on<AttendanceRetryRequested>(_onRetryRequested);
  }

  final MarkAttendanceUseCase _markAttendance;
  final LocationService _location;

  CameraController? _controller;
  FaceDetector? _detector;
  AttendanceEventType _eventType = AttendanceEventType.checkIn;
  double? _lat;
  double? _lng;

  bool _detectorBusy = false;
  DateTime _lastDetect = DateTime.fromMillisecondsSinceEpoch(0);
  int _positiveStreak = 0;

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
    AttendanceCheckStarted event,
    Emitter<AttendanceCheckState> emit,
  ) async {
    _eventType = event.eventType;
    emit(
      state.copyWith(
        status: AttendanceCheckStatus.initializing,
        failureKind: AttendanceFailureKind.none,
      ),
    );

    final granted = await _ensurePermission();
    if (!granted) {
      emit(state.copyWith(status: AttendanceCheckStatus.permissionDenied));
      return;
    }

    // GPS — start’da olinadi (xato → failure(location)).
    try {
      final pos = await _location.current();
      _lat = pos.latitude;
      _lng = pos.longitude;
    } on LocationException {
      emit(
        state.copyWith(
          status: AttendanceCheckStatus.failure,
          failureKind: AttendanceFailureKind.location,
        ),
      );
      return;
    }

    final ok = await _initCamera();
    if (!ok) {
      emit(state.copyWith(status: AttendanceCheckStatus.cameraError));
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
    emit(state.copyWith(status: AttendanceCheckStatus.scanning));
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
            add(AttendanceFaceDetectionUpdated(facePresent: faces.isNotEmpty));
          }
        })
        .catchError((_) {
          // Kadr xatosi — keyingi kadrda qayta uriniladi.
        })
        .whenComplete(() => _detectorBusy = false);
  }

  void _onDetectionUpdated(
    AttendanceFaceDetectionUpdated event,
    Emitter<AttendanceCheckState> emit,
  ) {
    if (state.status != AttendanceCheckStatus.scanning &&
        state.status != AttendanceCheckStatus.detecting) {
      return;
    }

    if (!event.facePresent) {
      _positiveStreak = 0;
      if (state.status != AttendanceCheckStatus.scanning) {
        emit(state.copyWith(status: AttendanceCheckStatus.scanning));
      }
      return;
    }

    _positiveStreak++;
    if (state.status != AttendanceCheckStatus.detecting) {
      emit(state.copyWith(status: AttendanceCheckStatus.detecting));
    }
    if (_positiveStreak >= _captureStreak) {
      _positiveStreak = 0;
      add(const AttendanceCaptureRequested());
    }
  }

  Future<void> _onCaptureRequested(
    AttendanceCaptureRequested event,
    Emitter<AttendanceCheckState> emit,
  ) async {
    if (state.status == AttendanceCheckStatus.verifying) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (_lat == null || _lng == null) return;

    emit(state.copyWith(status: AttendanceCheckStatus.verifying));
    try {
      await _stopStream();
      final XFile shot = await controller.takePicture();
      await _markAttendance(
        MarkAttendanceParams(
          eventType: _eventType,
          latitude: _lat!,
          longitude: _lng!,
          imagePath: shot.path,
        ),
      );
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: AttendanceCheckStatus.success,
          failureKind: AttendanceFailureKind.none,
        ),
      );
    } on Failure catch (failure) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: AttendanceCheckStatus.failure,
          failureKind: failure is NetworkFailure
              ? AttendanceFailureKind.network
              : AttendanceFailureKind.verifyFailed,
        ),
      );
      await _disposeCamera();
    } catch (_) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: AttendanceCheckStatus.failure,
          failureKind: AttendanceFailureKind.verifyFailed,
        ),
      );
      await _disposeCamera();
    }
  }

  Future<void> _onRetryRequested(
    AttendanceRetryRequested event,
    Emitter<AttendanceCheckState> emit,
  ) async {
    add(AttendanceCheckStarted(_eventType));
  }

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
