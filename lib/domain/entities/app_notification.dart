import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _AppNotification;
}
