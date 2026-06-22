import 'package:dartz/dartz.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/app_notification.dart';
import '../../../domain/entities/notification_preference.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../datasources/remote/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final dtos = await _remoteDataSource.getNotifications(
        userId: userId,
        limit: limit,
      );
      return right(dtos.map((d) => d.toDomain()).toList());
    } catch (e, st) {
      appLogger.e('[NotificationRepository] getNotifications failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({required String userId}) async {
    try {
      final count = await _remoteDataSource.getUnreadCount(userId: userId);
      return right(count);
    } catch (e, st) {
      appLogger.e('[NotificationRepository] getUnreadCount failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _remoteDataSource.markAsRead(notificationId);
      return right<Failure, void>(null);
    } catch (e, st) {
      appLogger.e('[NotificationRepository] markAsRead failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead({required String userId}) async {
    try {
      await _remoteDataSource.markAllAsRead(userId: userId);
      return right<Failure, void>(null);
    } catch (e, st) {
      appLogger.e('[NotificationRepository] markAllAsRead failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markDelivered(String notificationId) async {
    try {
      await _remoteDataSource.markDelivered(notificationId);
      return right<Failure, void>(null);
    } catch (e, st) {
      appLogger.e('[NotificationRepository] markDelivered failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markOpened(String notificationId) async {
    try {
      await _remoteDataSource.markOpened(notificationId);
      return right<Failure, void>(null);
    } catch (e, st) {
      appLogger.e('[NotificationRepository] markOpened failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createNotification({
    required String userId,
    required String titleAr,
    required String bodyAr,
    required String type,
    String? referenceType,
    String? referenceId,
  }) async {
    try {
      await _remoteDataSource.createNotification(
        userId: userId,
        titleAr: titleAr,
        bodyAr: bodyAr,
        type: type,
        referenceType: referenceType,
        referenceId: referenceId,
      );
      return right<Failure, void>(null);
    } catch (e, st) {
      appLogger.e('[NotificationRepository] createNotification failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationPreference>> getPreferences({
    required String userId,
  }) async {
    try {
      final dto = await _remoteDataSource.getPreferences(userId: userId);
      if (dto != null) {
        return right(dto.toDomain());
      }
      return right(_defaultPreferences(userId));
    } catch (e, st) {
      appLogger.e('[NotificationRepository] getPreferences failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationPreference>> updatePreferences({
    required String userId,
    bool? orderUpdates,
    bool? promotions,
    bool? pushEnabled,
  }) async {
    try {
      final dto = await _remoteDataSource.upsertPreferences(
        userId: userId,
        orderUpdates: orderUpdates,
        promotions: promotions,
        pushEnabled: pushEnabled,
      );
      return right(dto.toDomain());
    } catch (e, st) {
      appLogger.e('[NotificationRepository] updatePreferences failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Stream<List<AppNotification>> watchNotifications({required String userId}) {
    return _remoteDataSource.watchNotifications(userId: userId).map(
          (dtos) => dtos.map((d) => d.toDomain()).toList(),
        );
  }

  NotificationPreference _defaultPreferences(String userId) {
    return NotificationPreference(
      id: '',
      userId: userId,
      orderUpdates: true,
      promotions: true,
      pushEnabled: true,
      updatedAt: DateTime.now(),
    );
  }
}
