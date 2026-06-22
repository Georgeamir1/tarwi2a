import 'package:dartz/dartz.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/device_token_repository.dart';
import '../datasources/remote/device_token_remote_datasource.dart';

class DeviceTokenRepositoryImpl implements DeviceTokenRepository {
  final DeviceTokenRemoteDataSource _remoteDataSource;

  DeviceTokenRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, void>> registerToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    try {
      await _remoteDataSource.registerToken(
        userId: userId,
        token: token,
        platform: platform,
      );
      return right<Failure, void>(null);
    } catch (e, st) {
      appLogger.e('[DeviceTokenRepository] registerToken failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unregisterToken({required String token}) async {
    try {
      await _remoteDataSource.unregisterToken(token: token);
      return right<Failure, void>(null);
    } catch (e, st) {
      appLogger.e('[DeviceTokenRepository] unregisterToken failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getTokensForUser({
    required String userId,
  }) async {
    try {
      final tokens = await _remoteDataSource.getTokensForUser(userId: userId);
      return right(tokens);
    } catch (e, st) {
      appLogger.e('[DeviceTokenRepository] getTokensForUser failed',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }
}
