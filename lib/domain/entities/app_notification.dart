import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/notification_type.dart';

part 'app_notification.freezed.dart';

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String userId,
    required String titleAr,
    required String bodyAr,
    required NotificationType type,
    String? referenceType,
    String? referenceId,
    @Default(false) bool isRead,
    required DateTime createdAt,
    DateTime? deliveredAt,
    DateTime? openedAt,
  }) = _AppNotification;
}
