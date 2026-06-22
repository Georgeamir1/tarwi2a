import '../../../domain/entities/notification_preference.dart';

class NotificationPreferenceDTO {
  final String id;
  final String userId;
  final bool orderUpdates;
  final bool promotions;
  final bool pushEnabled;
  final DateTime updatedAt;

  const NotificationPreferenceDTO({
    required this.id,
    required this.userId,
    required this.orderUpdates,
    required this.promotions,
    required this.pushEnabled,
    required this.updatedAt,
  });

  factory NotificationPreferenceDTO.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceDTO(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      orderUpdates: (json['order_updates'] as bool?) ?? true,
      promotions: (json['promotions'] as bool?) ?? true,
      pushEnabled: (json['push_enabled'] as bool?) ?? true,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toUpdateJson() => {
        'order_updates': orderUpdates,
        'promotions': promotions,
        'push_enabled': pushEnabled,
      };

  NotificationPreference toDomain() => NotificationPreference(
        id: id,
        userId: userId,
        orderUpdates: orderUpdates,
        promotions: promotions,
        pushEnabled: pushEnabled,
        updatedAt: updatedAt,
      );

  factory NotificationPreferenceDTO.defaultsFor(String userId) =>
      NotificationPreferenceDTO(
        id: '',
        userId: userId,
        orderUpdates: true,
        promotions: true,
        pushEnabled: true,
        updatedAt: DateTime.now(),
      );
}
