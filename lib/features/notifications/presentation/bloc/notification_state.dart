part of 'notification_bloc.dart';

enum NotificationStatus { initial, loading, loaded, failure }

/// Yuklashdagi xato turi — widget lokalizatsiyaga o‘giradi.
enum NotificationErrorKind { none, network, server }

class NotificationState extends Equatable {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.items = const [],
    this.errorKind = NotificationErrorKind.none,
    this.page = 1,
    this.hasNext = false,
    this.isLoadingMore = false,
    this.unreadCount = 0,
  });

  final NotificationStatus status;
  final List<AppNotification> items;
  final NotificationErrorKind errorKind;

  /// Yuklangan oxirgi sahifa raqami.
  final int page;
  final bool hasNext;
  final bool isLoadingMore;

  /// O‘qilmaganlar soni (bell badge).
  final int unreadCount;

  bool get isEmpty =>
      status == NotificationStatus.loaded && items.isEmpty;

  bool get hasUnread => unreadCount > 0;

  NotificationState copyWith({
    NotificationStatus? status,
    List<AppNotification>? items,
    NotificationErrorKind? errorKind,
    int? page,
    bool? hasNext,
    bool? isLoadingMore,
    int? unreadCount,
  }) {
    return NotificationState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorKind: errorKind ?? this.errorKind,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        errorKind,
        page,
        hasNext,
        isLoadingMore,
        unreadCount,
      ];
}
