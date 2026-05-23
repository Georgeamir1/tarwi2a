import 'package:dartz/dartz.dart';
import '../../../domain/entities/coupon.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/coupon_repository.dart';
import '../datasources/remote/coupon_remote_datasource.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponRemoteDataSource _remoteDataSource;

  CouponRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Coupon>>> getAll() async {
    try {
      final dtos = await _remoteDataSource.getAll();
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> create(Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.create(data);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> update(
      String id, Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.update(id, data);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleActive(String id, bool isActive) async {
    try {
      await _remoteDataSource.toggleActive(id, isActive);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await _remoteDataSource.delete(id);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Stream<List<Coupon>> watchCoupons() {
    return _remoteDataSource.watchCoupons().map(
          (dtos) => dtos.map((dto) => dto.toDomain()).toList(),
        );
  }
}
