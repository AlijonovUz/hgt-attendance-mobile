import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/no_params.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/get_notification_count_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

/// Bildirishnomalar holatini boshqaradi: ro‘yxat yuklash, sahifalash
/// (infinite scroll), bitta/barchasini o‘qilgan deb belgilash, o‘qilmaganlar
/// soni (bell badge). Bloc context-free: xato enumini emit qiladi,
/// lokalizatsiya widget qatlamida.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markRead,
    required MarkAllNotificationsReadUseCase markAllRead,
    required GetNotificationCountUseCase getCount,
  })  : _getNotifications = getNotifications,
        _markRead = markRead,
        _markAllRead = markAllRead,
        _getCount = getCount,
        super(const NotificationState()) {
    on<NotificationsRequested>(_onRequested);
    on<NotificationsNextPageRequested>(_onNextPage);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationsAllRead>(_onAllRead);
    on<NotificationCountRequested>(_onCountRequested);
  }

  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final GetNotificationCountUseCase _getCount;

  Future<void> _onRequested(
    NotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(
      status: NotificationStatus.loading,
      errorKind: NotificationErrorKind.none,
    ));
    try {
      final page = await _getNotifications(const GetNotificationsParams(page: 1));
      emit(state.copyWith(
        status: NotificationStatus.loaded,
        items: page.items,
        page: 1,
        hasNext: page.hasNext,
        unreadCount: page.items.where((n) => !n.isRead).length,
      ));
    } on Failure catch (failure) {
      emit(state.copyWith(
        status: NotificationStatus.failure,
        errorKind: _kindOf(failure),
      ));
    }
  }

  Future<void> _onNextPage(
    NotificationsNextPageRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (!state.hasNext || state.isLoadingMore || state.status != NotificationStatus.loaded) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.page + 1;
      final page = await _getNotifications(GetNotificationsParams(page: next));
      final merged = [...state.items, ...page.items];
      emit(state.copyWith(
        items: merged,
        page: next,
        hasNext: page.hasNext,
        isLoadingMore: false,
        unreadCount: merged.where((n) => !n.isRead).length,
      ));
    } on Failure {
      // Keyingi sahifa xatosi — jim qoldiramiz, mavjud ro‘yxat saqlanadi.
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationState> emit,
  ) async {
    final target = state.items.where((n) => n.id == event.id);
    if (target.isEmpty || target.first.isRead) return;

    // Optimistik: darhol o‘qilgan deb ko‘rsatamiz.
    final updated = state.items
        .map((n) => n.id == event.id ? n.copyWith(isRead: true) : n)
        .toList();
    emit(state.copyWith(
      items: updated,
      unreadCount: updated.where((n) => !n.isRead).length,
    ));

    try {
      await _markRead(event.id);
    } on Failure {
      // Backend rad etsa — holatni qaytaramiz.
      final reverted = state.items
          .map((n) => n.id == event.id ? n.copyWith(isRead: false) : n)
          .toList();
      emit(state.copyWith(
        items: reverted,
        unreadCount: reverted.where((n) => !n.isRead).length,
      ));
    }
  }

  Future<void> _onAllRead(
    NotificationsAllRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.unreadCount == 0) return;
    final previous = state.items;
    final updated = previous.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(items: updated, unreadCount: 0));

    try {
      await _markAllRead(const NoParams());
    } on Failure {
      emit(state.copyWith(
        items: previous,
        unreadCount: previous.where((n) => !n.isRead).length,
      ));
    }
  }

  Future<void> _onCountRequested(
    NotificationCountRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final count = await _getCount(const NoParams());
      emit(state.copyWith(unreadCount: count));
    } on Failure {
      // Badge — kritik emas; xatoni yutamiz.
    }
  }

  NotificationErrorKind _kindOf(Failure failure) => switch (failure) {
        NetworkFailure() => NotificationErrorKind.network,
        _ => NotificationErrorKind.server,
      };
}
