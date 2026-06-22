part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Ro‘yxatni dastlab yuklash / qayta yuklash (pull-to-refresh).
class NotificationsRequested extends NotificationEvent {
  const NotificationsRequested();
}

/// Keyingi sahifani yuklash (infinite scroll).
class NotificationsNextPageRequested extends NotificationEvent {
  const NotificationsNextPageRequested();
}

/// Bitta bildirishnomani o‘qilgan deb belgilash (tap).
class NotificationMarkedRead extends NotificationEvent {
  const NotificationMarkedRead(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Barchasini o‘qilgan deb belgilash (header tugmasi).
class NotificationsAllRead extends NotificationEvent {
  const NotificationsAllRead();
}

/// Faqat o‘qilmaganlar sonini yangilash (bell badge — ro‘yxatsiz).
class NotificationCountRequested extends NotificationEvent {
  const NotificationCountRequested();
}
