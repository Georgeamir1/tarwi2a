import '../../../domain/entities/broadcast_log.dart';
import '../../../domain/enums/broadcast_target.dart';
import '../../../domain/enums/notification_type.dart';

class BroadcastLogDTO {
  final String id;
  final String? senderId;
  final String titleAr;
  final String bodyAr;
  final String type;
  final String targetType;
  final List<String> targetUserIds;
  final String? referenceType;
  final String? referenceId;
  final int recipientCount;
  final int sentCount;
  final int skippedCount;
  final DateTime createdAt;

  const BroadcastLogDTO({
    required this.id,
    this.senderId,
    required this.titleAr,
    required this.bodyAr,
    required this.type,
    required this.targetType,
    this.targetUserIds = const [],
    this.referenceType,
    this.referenceId,
    required this.recipientCount,
    required this.sentCount,
    required this.skippedCount,
    required this.createdAt,
  });

  factory BroadcastLogDTO.fromJson(Map<String, dynamic> json) {
    return BroadcastLogDTO(
      id: json['id'] as String,
      senderId: json['sender_id'] as String?,
      titleAr: json['title_ar'] as String,
      bodyAr: json['body_ar'] as String,
      type: json['type'] as String,
      targetType: json['target_type'] as String,
      targetUserIds:
          (json['target_user_ids'] as List<dynamic>?)?.cast<String>() ??
              const [],
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      recipientCount: (json['recipient_count'] as int?) ?? 0,
      sentCount: (json['sent_count'] as int?) ?? 0,
      skippedCount: (json['skipped_count'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  BroadcastLog toDomain() => BroadcastLog(
        id: id,
        senderId: senderId,
        titleAr: titleAr,
        bodyAr: bodyAr,
        type: NotificationType.fromValue(type),
        targetType: BroadcastTargetType.fromValue(targetType),
        targetUserIds: targetUserIds,
        referenceType: referenceType,
        referenceId: referenceId,
        recipientCount: recipientCount,
        sentCount: sentCount,
        skippedCount: skippedCount,
        createdAt: createdAt,
      );
}
