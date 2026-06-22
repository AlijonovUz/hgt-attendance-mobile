import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repository/notification_repository.dart';
import '../data_sources/notification_remote_data_source.dart';

/// [NotificationRepository] implementatsiyasi — data source `Exception`larini
/// domen `Failure`lariga aylantiradi.
class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({
    required NotificationRemoteDataSource remote,
  }) : _remote = remote;

  final NotificationRemoteDataSource _remote;

  @override
  Future<NotificationPage> getNotifications({int page = 1, bool? isRead}) =>
      _guard(() async {
        final model = await _remote.getNotifications(page: page, isRead: isRead);
        return model.toEntity();
      });

  @override
  Future<void> markRead(String id) => _guard(() => _remote.markRead(id));

  @override
  Future<void> markAllRead() => _guard(() => _remote.markAllRead());

  @override
  Future<int> unreadCount() => _guard(() => _remote.unreadCount());

  @override
  Future<void> registerDevice({
    required String userId,
    required String fcmToken,
    required String deviceType,
    required String deviceId,
  }) =>
      _guard(() => _remote.registerDevice(
            userId: userId,
            fcmToken: fcmToken,
            deviceType: deviceType,
            deviceId: deviceId,
          ));

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
