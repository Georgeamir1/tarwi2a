import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_preference.freezed.dart';

@freezed
class NotificationPreference with _$NotificationPreference {
  const factory NotificationPreference({
    required String id,
    required String userId,
    @Default(true) bool orderUpdates,
    @Default(true) bool promotions,
    @Default(true) bool pushEnabled,
    required DateTime updatedAt,
  }) = _NotificationPreference;
}
