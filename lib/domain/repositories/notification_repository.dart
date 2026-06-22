import 'package:dartz/dartz.dart';
import '../entities/app_notification.dart';
import '../entities/notification_preference.dart';
import '../failures/failure.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    required String userId,
    int limit = 50,
  });

  Future<Either<Failure, int>> getUnreadCount({required String userId});

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> markAllAsRead({required String userId});

  Future<Either<Failure, void>> markDelivered(String notificationId);

  Future<Either<Failure, void>> markOpened(String notificationId);

  Future<Either<Failure, void>> createNotification({
    required String userId,
    required String titleAr,
    required String bodyAr,
    required String type,
    String? referenceType,
    String? referenceId,
  });

  Future<Either<Failure, NotificationPreference>> getPreferences({
    required String userId,
  });

  Future<Either<Failure, NotificationPreference>> updatePreferences({
    required String userId,
    bool? orderUpdates,
    bool? promotions,
    bool? pushEnabled,
  });

  Stream<List<AppNotification>> watchNotifications({required String userId});
}
