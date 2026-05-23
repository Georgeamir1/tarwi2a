import 'package:dartz/dartz.dart';
import '../entities/coupon.dart';
import '../failures/failure.dart';

abstract class CouponRepository {
  Future<Either<Failure, List<Coupon>>> getAll();
  Future<Either<Failure, void>> create(Map<String, dynamic> data);
  Future<Either<Failure, void>> update(String id, Map<String, dynamic> data);
  Future<Either<Failure, void>> toggleActive(String id, bool isActive);
  Future<Either<Failure, void>> delete(String id);
  Stream<List<Coupon>> watchCoupons();
}
