import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/broadcast_target.dart';
import '../enums/notification_type.dart';

part 'broadcast_log.freezed.dart';

@freezed
class BroadcastLog with _$BroadcastLog {
  const factory BroadcastLog({
    required String id,
    String? senderId,
    required String titleAr,
    required String bodyAr,
    required NotificationType type,
    required BroadcastTargetType targetType,
    @Default(<String>[]) List<String> targetUserIds,
    String? referenceType,
    String? referenceId,
    @Default(0) int recipientCount,
    @Default(0) int sentCount,
    @Default(0) int skippedCount,
    required DateTime createdAt,
  }) = _BroadcastLog;
}
