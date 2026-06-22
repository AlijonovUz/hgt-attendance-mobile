import '../entities/app_notification.dart';

/// Bildirishnoma domeni shartnomasi. Xatolarda `Failure`
/// (core/error/failures.dart) `throw` qiladi; bloc ularni xato enumiga,
/// widget esa lokalizatsiyaga o‘giradi.
abstract interface class NotificationRepository {
  /// Sahifalangan ro‘yxat. [isRead] berilsa filtrlaydi.
  Future<NotificationPage> getNotifications({int page = 1, bool? isRead});

  /// Bitta bildirishnomani o‘qilgan deb belgilash.
  Future<void> markRead(String id);

  /// Barcha bildirishnomalarni o‘qilgan deb belgilash.
  Future<void> markAllRead();

  /// O‘qilmaganlar soni (bell badge uchun).
  Future<int> unreadCount();

  /// FCM qurilma tokenini backendda ro‘yxatdan o‘tkazadi (push uchun).
  /// [userId] — JWT `user_id` (profil `id`ga teng), backend majburiy maydoni.
  Future<void> registerDevice({
    required String userId,
    required String fcmToken,
    required String deviceType,
    required String deviceId,
  });
}
