import 'package:dartz/dartz.dart';
import '../../../domain/entities/business_profile.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/business_profile_repository.dart';
import '../datasources/remote/business_profile_remote_datasource.dart';

class BusinessProfileRepositoryImpl implements BusinessProfileRepository {
  final BusinessProfileRemoteDataSource _remoteDataSource;

  BusinessProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, BusinessProfile>> get() async {
    try {
      final dto = await _remoteDataSource.get();
      if (dto == null) {
        return left(const Failure.unexpected(
            message: 'لم يتم العثور على الملف التجاري'));
      }
      return right(dto.toDomain());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> update(Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.update(data);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAcceptOrders(bool accept) async {
    try {
      final dto = await _remoteDataSource.get();
      if (dto == null) {
        return left(const Failure.unexpected(
            message: 'لم يتم العثور على الملف التجاري'));
      }
      await _remoteDataSource.toggleAcceptOrders(dto.id, accept);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleBusyMode({
    required bool isBusy,
    String? message,
  }) async {
    try {
      final dto = await _remoteDataSource.get();
      if (dto == null) {
        return left(const Failure.unexpected(
            message: 'لم يتم العثور على الملف التجاري'));
      }
      await _remoteDataSource.toggleBusyMode(dto.id, isBusy, message);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Stream<BusinessProfile?> watchProfile() {
    return _remoteDataSource.watchBusinessProfile().map(
          (dto) => dto?.toDomain(),
        );
  }
}
