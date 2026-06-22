import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/app_notification.dart';
import '../repository/notification_repository.dart';

/// Sahifalangan bildirishnomalar ro‘yxatini olish amali.
class GetNotificationsUseCase
    implements UseCase<NotificationPage, GetNotificationsParams> {
  const GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<NotificationPage> call(GetNotificationsParams params) =>
      _repository.getNotifications(page: params.page, isRead: params.isRead);
}

class GetNotificationsParams extends Equatable {
  const GetNotificationsParams({this.page = 1, this.isRead});

  final int page;
  final bool? isRead;

  @override
  List<Object?> get props => [page, isRead];
}
