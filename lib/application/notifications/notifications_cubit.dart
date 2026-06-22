import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/logger/app_logger.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _repository;
  StreamSubscription<List<AppNotification>>? _subscription;

  NotificationsCubit(this._repository) : super(NotificationsState.initial());

  Future<void> loadNotifications(String userId) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    final result = await _repository.getNotifications(userId: userId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: NotificationsStatus.error,
        failure: failure,
      )),
      (notifications) {
        final safe = _filterByUser(notifications, userId);
        final unread = safe.where((n) => !n.isRead).length;
        emit(state.copyWith(
          status: NotificationsStatus.loaded,
          notifications: safe,
          unreadCount: unread,
        ));
      },
    );
    _listenToStream(userId);
  }

  List<AppNotification> _filterByUser(
      List<AppNotification> notifications, String userId) {
    return notifications.where((n) => n.userId == userId).toList();
  }

  void _listenToStream(String userId) {
    _subscription?.cancel();
    _subscription = _repository.watchNotifications(userId: userId).listen(
      (notifications) {
        if (isClosed) return;
        final safe = _filterByUser(notifications, userId);
        final unread = safe.where((n) => !n.isRead).length;
        emit(state.copyWith(
          status: NotificationsStatus.loaded,
          notifications: safe,
          unreadCount: unread,
        ));
      },
      onError: (Object e) {
        if (isClosed) return;
        appLogger.e('[NotificationsCubit] stream error', error: e);
        emit(state.copyWith(
          status: NotificationsStatus.error,
          failure: Failure.unexpected(message: e.toString()),
        ));
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final result = await _repository.markAsRead(notificationId);
    result.fold(
      (failure) {
        appLogger.e('[NotificationsCubit] markAsRead failed', error: failure);
      },
      (_) {
        final updated = state.notifications
            .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
            .toList();
        final unread = updated.where((n) => !n.isRead).length;
        emit(state.copyWith(
          notifications: updated,
          unreadCount: unread,
        ));
      },
    );
    // Also track analytics — markOpened sets both opened_at and is_read
    unawaited(_repository.markOpened(notificationId));
  }

  Future<void> markAllAsRead(String userId) async {
    final result = await _repository.markAllAsRead(userId: userId);
    result.fold(
      (failure) {
        appLogger.e('[NotificationsCubit] markAllAsRead failed',
            error: failure);
      },
      (_) {
        final updated =
            state.notifications.map((n) => n.copyWith(isRead: true)).toList();
        emit(state.copyWith(
          notifications: updated,
          unreadCount: 0,
        ));
      },
    );
  }

  Future<void> markIdsAsRead(List<String> ids) async {
    for (final id in ids) {
      await markAsRead(id);
    }
  }

  void switchUser(String? userId) {
    _subscription?.cancel();
    _subscription = null;
    emit(NotificationsState.initial());
    if (userId != null && userId.isNotEmpty) {
      loadNotifications(userId);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState extends Equatable {
  final List<AppNotification> notifications;
  final int unreadCount;
  final NotificationsStatus status;
  final Failure? failure;

  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.status = NotificationsStatus.initial,
    this.failure,
  });

  factory NotificationsState.initial() => const NotificationsState();

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    NotificationsStatus? status,
    Failure? failure,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [notifications, unreadCount, status, failure];
}
