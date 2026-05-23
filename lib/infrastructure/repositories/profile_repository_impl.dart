import 'package:dartz/dartz.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../datasources/remote/profile_remote_data_source.dart';
import '../dtos/user_profile_dto.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, UserProfile?>> getProfile(String userId) async {
    try {
      appLogger.d('[ProfileRepo] getProfile called — userId: $userId');
      final dto = await _remoteDataSource.getProfile(userId);
      if (dto == null) {
        appLogger.d('[ProfileRepo] getProfile ⚠ — no profile found in DB');
        return right(null);
      }
      appLogger.d(
          '[ProfileRepo] getProfile ✅ — name: ${dto.name ?? "null"}, role: ${dto.role ?? "null"}');
      return right(dto.toDomain());
    } catch (e, s) {
      appLogger.e('[ProfileRepo] getProfile ❌ failed', error: e, stackTrace: s);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserProfile profile) async {
    try {
      appLogger.d('[ProfileRepo] updateProfile called — name: ${profile.name}');
      final dto = UserProfileDTO(
        id: profile.id,
        name: profile.name,
        phone: profile.phone,
        role: profile.role.value,
        createdAt: profile.createdAt,
      );
      await _remoteDataSource.updateProfile(dto);
      appLogger.d('[ProfileRepo] updateProfile ✅');
      return right<Failure, void>(null);
    } catch (e, s) {
      appLogger.e('[ProfileRepo] updateProfile ❌ failed',
          error: e, stackTrace: s);
      return left(Failure.unexpected(message: e.toString()));
    }
  }
}
