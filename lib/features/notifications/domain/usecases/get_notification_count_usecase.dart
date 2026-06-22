import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/notification_repository.dart';

/// O‘qilmagan bildirishnomalar sonini olish amali (bell badge uchun).
class GetNotificationCountUseCase implements UseCase<int, NoParams> {
  const GetNotificationCountUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<int> call(NoParams params) => _repository.unreadCount();
}
