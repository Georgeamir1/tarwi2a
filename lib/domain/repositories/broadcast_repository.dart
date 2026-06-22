import 'package:dartz/dartz.dart';
import '../entities/broadcast_log.dart';
import '../entities/broadcast_notification.dart';
import '../enums/broadcast_target.dart';
import '../failures/failure.dart';

class BroadcastResult {
  final int recipientCount;
  final int sentCount;
  final int skippedCount;
  final String? broadcastLogId;

  const BroadcastResult({
    required this.recipientCount,
    required this.sentCount,
    required this.skippedCount,
    this.broadcastLogId,
  });
}

abstract class BroadcastRepository {
  Future<Either<Failure, BroadcastResult>> sendBroadcast({
    required BroadcastNotification broadcast,
    required String senderId,
  });

  Future<Either<Failure, List<BroadcastLog>>> getHistory({int limit = 50});

  Future<Either<Failure, int>> getRecipientsCount({
    required BroadcastTargetType targetType,
    List<String> targetUserIds = const [],
  });
}
