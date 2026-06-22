import '../../../../core/usecases/usecase.dart';
import '../repository/notification_repository.dart';

/// Bitta bildirishnomani o‘qilgan deb belgilash amali.
class MarkNotificationReadUseCase implements UseCase<void, String> {
  const MarkNotificationReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<void> call(String id) => _repository.markRead(id);
}
