import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/notification_repository.dart';

/// FCM qurilma tokenini ro‘yxatdan o‘tkazish amali (push uchun).
class RegisterDeviceUseCase implements UseCase<void, RegisterDeviceParams> {
  const RegisterDeviceUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<void> call(RegisterDeviceParams params) => _repository.registerDevice(
        userId: params.userId,
        fcmToken: params.fcmToken,
        deviceType: params.deviceType,
        deviceId: params.deviceId,
      );
}

class RegisterDeviceParams extends Equatable {
  const RegisterDeviceParams({
    required this.userId,
    required this.fcmToken,
    required this.deviceType,
    required this.deviceId,
  });

  /// JWT `user_id` (profil `id`).
  final String userId;
  final String fcmToken;

  /// `ios` / `android` / `web`.
  final String deviceType;
  final String deviceId;

  @override
  List<Object?> get props => [userId, fcmToken, deviceType, deviceId];
}
