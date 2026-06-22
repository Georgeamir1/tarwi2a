import '../../../domain/entities/app_notification.dart';
import '../../../domain/enums/notification_type.dart';

class NotificationDTO {
  final String id;
  final String userId;
  final String titleAr;
  final String bodyAr;
  final String type;
  final String? referenceType;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? openedAt;

  const NotificationDTO({
    required this.id,
    required this.userId,
    required this.titleAr,
    required this.bodyAr,
    required this.type,
    this.referenceType,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
    this.deliveredAt,
    this.openedAt,
  });

  factory NotificationDTO.fromJson(Map<String, dynamic> json) {
    return NotificationDTO(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      titleAr: (json['title_ar'] ?? json['title']) as String,
      bodyAr: (json['body_ar'] ?? json['body']) as String,
      type: json['type'] as String,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      openedAt: json['opened_at'] != null
          ? DateTime.parse(json['opened_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title_ar': titleAr,
        'body_ar': bodyAr,
        'type': type,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toInsertJson() => {
        'user_id': userId,
        'title': titleAr,
        'body': bodyAr,
        'type': type,
        'is_read': isRead,
      };

  AppNotification toDomain() => AppNotification(
        id: id,
        userId: userId,
        titleAr: titleAr,
        bodyAr: bodyAr,
        type: NotificationType.fromValue(type),
        referenceType: referenceType,
        referenceId: referenceId,
        isRead: isRead,
        createdAt: createdAt,
        deliveredAt: deliveredAt,
        openedAt: openedAt,
      );
}
