import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/broadcast_notification.dart';
import '../../../domain/enums/broadcast_target.dart';
import '../../../domain/repositories/broadcast_repository.dart';
import '../../dtos/broadcast_log_dto.dart';

class BroadcastRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<BroadcastResultDto> sendBroadcast({
    required BroadcastNotification broadcast,
    required String senderId,
  }) async {
    try {
      final targetMap = <String, dynamic>{
        'type': broadcast.targetType.value,
      };
      if (broadcast.targetType == BroadcastTargetType.specific) {
        targetMap['userIds'] = broadcast.targetUserIds;
      }

      final body = <String, dynamic>{
        'titleAr': broadcast.titleAr,
        'bodyAr': broadcast.bodyAr,
        'type': broadcast.type.value,
        'target': targetMap,
        if (broadcast.referenceType != null) 'referenceType': broadcast.referenceType,
        if (broadcast.referenceId != null) 'referenceId': broadcast.referenceId,
        'senderId': senderId,
      };

      final response = await _client.functions.invoke(
        'send-push-notification',
        body: body,
      );

      final status = response.status;
      if (status >= 400) {
        String? err;
        if (response.data is Map) {
          err = response.data['error'] as String?;
        }
        throw Exception(err ?? 'HTTP $status');
      }

      final data = response.data as Map<String, dynamic>;
      final result = BroadcastResultDto.fromJson(data);
      if (result.sentCount == 0 && result.skippedCount > 0) {
        throw Exception('فشل إرسال الإشعار لجميع المستخدمين المستهدفين.');
      }
      return result;
    } catch (e) {
      appLogger.e('[BroadcastDataSource] sendBroadcast edge function failed', error: e);
      rethrow;
    }
  }

  Future<List<BroadcastLogDTO>> getHistory({int limit = 50}) async {
    final data = await _client
        .from('broadcast_logs')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    appLogger.d('📡 broadcast history count=${(data as List).length}');
    return (data as List).map((e) => BroadcastLogDTO.fromJson(e)).toList();
  }

  Future<int> getRecipientsCount({
    required BroadcastTargetType targetType,
    List<String> targetUserIds = const [],
  }) async {
    try {
      switch (targetType) {
        case BroadcastTargetType.all:
          final res = await _client
              .from('profiles')
              .select('id')
              .count(CountOption.exact);
          return res.count;
        case BroadcastTargetType.customers:
          final res = await _client
              .from('profiles')
              .select('id')
              .eq('role', 'customer')
              .count(CountOption.exact);
          return res.count;
        case BroadcastTargetType.admins:
          final res = await _client
              .from('profiles')
              .select('id')
              .eq('role', 'admin')
              .count(CountOption.exact);
          return res.count;
        case BroadcastTargetType.specific:
          return targetUserIds.length;
      }
    } catch (e) {
      appLogger.e('[BroadcastDataSource] getRecipientsCount failed', error: e);
      rethrow;
    }
  }
}

class BroadcastResultDto {
  final int recipientCount;
  final int sentCount;
  final int skippedCount;
  final String? broadcastLogId;

  const BroadcastResultDto({
    required this.recipientCount,
    required this.sentCount,
    required this.skippedCount,
    this.broadcastLogId,
  });

  factory BroadcastResultDto.fromJson(Map<String, dynamic> json) {
    return BroadcastResultDto(
      recipientCount: (json['recipientCount'] as int?) ?? 0,
      sentCount: (json['sentCount'] as int?) ?? 0,
      skippedCount: (json['skipped'] as int?) ?? 0,
      broadcastLogId: (json['notificationIds'] as List?)?.isNotEmpty == true
          ? (json['notificationIds'] as List).first as String
          : null,
    );
  }

  BroadcastResult toDomain() => BroadcastResult(
        recipientCount: recipientCount,
        sentCount: sentCount,
        skippedCount: skippedCount,
        broadcastLogId: broadcastLogId,
      );
}
