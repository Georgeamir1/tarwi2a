import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/logger/app_logger.dart';
import '../../dtos/notification_dto.dart';
import '../../dtos/notification_preference_dto.dart';

class NotificationRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<NotificationDTO>> getNotifications({
    required String userId,
    int limit = 50,
  }) async {
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    appLogger.d(
        '📬 notifications getNotifications($userId) count=${(data as List).length}');
    return (data as List).map((e) => NotificationDTO.fromJson(e)).toList();
  }

  Future<int> getUnreadCount({required String userId}) async {
    final res = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false)
        .count(CountOption.exact);
    return res.count;
  }

  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  Future<void> markAllAsRead({required String userId}) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<void> markDelivered(String notificationId) async {
    await _client
        .from('notifications')
        .update({'delivered_at': DateTime.now().toIso8601String()}).eq(
            'id', notificationId);
  }

  Future<void> markOpened(String notificationId) async {
    await _client.from('notifications').update({
      'opened_at': DateTime.now().toIso8601String(),
      'is_read': true,
    }).eq('id', notificationId);
  }

  Future<void> createNotification({
    required String userId,
    required String titleAr,
    required String bodyAr,
    required String type,
    String? referenceType,
    String? referenceId,
  }) async {
    final payload = <String, dynamic>{
      'user_id': userId,
      'title_ar': titleAr,
      'body_ar': bodyAr,
      'type': type,
    };
    if (referenceType != null) payload['reference_type'] = referenceType;
    if (referenceId != null) payload['reference_id'] = referenceId;
    await _client.from('notifications').insert(payload);
  }

  Future<NotificationPreferenceDTO?> getPreferences({
    required String userId,
  }) async {
    final data = await _client
        .from('notification_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (data == null) return null;
    return NotificationPreferenceDTO.fromJson(data);
  }

  Future<NotificationPreferenceDTO> upsertPreferences({
    required String userId,
    bool? orderUpdates,
    bool? promotions,
    bool? pushEnabled,
  }) async {
    final updates = <String, dynamic>{};
    if (orderUpdates != null) updates['order_updates'] = orderUpdates;
    if (promotions != null) updates['promotions'] = promotions;
    if (pushEnabled != null) updates['push_enabled'] = pushEnabled;

    if (updates.isEmpty) {
      final existing = await getPreferences(userId: userId);
      if (existing != null) return existing;
      final inserted = await _client
          .from('notification_preferences')
          .insert({'user_id': userId})
          .select()
          .single();
      return NotificationPreferenceDTO.fromJson(inserted);
    }

    final data = await _client
        .from('notification_preferences')
        .upsert({'user_id': userId, ...updates}, onConflict: 'user_id')
        .select()
        .single();
    return NotificationPreferenceDTO.fromJson(data);
  }

  Stream<List<NotificationDTO>> watchNotifications({required String userId}) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .limit(50)
        .map((rows) {
          final filtered =
              rows.where((row) => row['user_id'] == userId).toList();
          final dtos =
              filtered.map((json) => NotificationDTO.fromJson(json)).toList();
          dtos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return dtos;
        });
  }
}
