import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/notification_repository.dart';

/// Barcha bildirishnomalarni o‘qilgan deb belgilash amali.
class MarkAllNotificationsReadUseCase implements UseCase<void, NoParams> {
  const MarkAllNotificationsReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.markAllRead();
}
