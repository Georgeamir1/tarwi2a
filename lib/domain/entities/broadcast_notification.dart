import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/broadcast_target.dart';
import '../enums/notification_type.dart';

part 'broadcast_notification.freezed.dart';

@freezed
class BroadcastNotification with _$BroadcastNotification {
  const factory BroadcastNotification({
    required String titleAr,
    required String bodyAr,
    required NotificationType type,
    required BroadcastTargetType targetType,
    @Default(<String>[]) List<String> targetUserIds,
    String? referenceType,
    String? referenceId,
  }) = _BroadcastNotification;
}
