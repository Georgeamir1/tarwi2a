import 'package:dartz/dartz.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/broadcast_log.dart';
import '../../../domain/entities/broadcast_notification.dart';
import '../../../domain/enums/broadcast_target.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/broadcast_repository.dart';
import '../datasources/remote/broadcast_remote_datasource.dart';

class BroadcastRepositoryImpl implements BroadcastRepository {
  final BroadcastRemoteDataSource _remoteDataSource;

  BroadcastRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, BroadcastResult>> sendBroadcast({
    required BroadcastNotification broadcast,
    required String senderId,
  }) async {
    try {
      final dto = await _remoteDataSource.sendBroadcast(
        broadcast: broadcast,
        senderId: senderId,
      );
      return right(dto.toDomain());
    } catch (e, st) {
      appLogger.e('[BroadcastRepository] sendBroadcast failed',
          error: e, stackTrace: st);
      final message = e.toString().contains('Failed to fetch')
          ? 'فشل الاتصال بخادم الإشعارات. تأكد من نشر Edge Function أو اختبر من تطبيق الموبايل.'
          : e.toString();
      return left(Failure.unexpected(message: message));
    }
  }

  @override
  Future<Either<Failure, List<BroadcastLog>>> getHistory({
    int limit = 50,
  }) async {
    try {
      final dtos = await _remoteDataSource.getHistory(limit: limit);
      return right(dtos.map((d) => d.toDomain()).toList());
    } catch (e, st) {
      appLogger.e('[BroadcastRepository] getHistory failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getRecipientsCount({
    required BroadcastTargetType targetType,
    List<String> targetUserIds = const [],
  }) async {
    try {
      final count = await _remoteDataSource.getRecipientsCount(
        targetType: targetType,
        targetUserIds: targetUserIds,
      );
      return right(count);
    } catch (e, st) {
      appLogger.e('[BroadcastRepository] getRecipientsCount failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }
}
