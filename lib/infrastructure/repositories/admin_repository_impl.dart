import 'package:dartz/dartz.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/entities/coupon.dart';
import '../../../domain/entities/delivery_zone.dart';
import '../../../domain/entities/business_setting.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../datasources/remote/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<UserProfile>>> getCustomers() async {
    try {
      final dtos = await _remoteDataSource.getCustomers();
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats() async {
    try {
      final stats = await _remoteDataSource.getDashboardStats();
      return right(stats);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Coupon>>> getCoupons() async {
    try {
      final dtos = await _remoteDataSource.getCoupons();
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> upsertCoupon(Map<String, dynamic> data, {String? id}) async {
    try {
      await _remoteDataSource.upsertCoupon(data, id: id);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCouponActive(String id, bool isActive) async {
    try {
      await _remoteDataSource.toggleCouponActive(id, isActive);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DeliveryZone>>> getDeliveryZones() async {
    try {
      final dtos = await _remoteDataSource.getDeliveryZones();
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> upsertDeliveryZone(Map<String, dynamic> data, {String? id}) async {
    try {
      await _remoteDataSource.upsertDeliveryZone(data, id: id);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BusinessSetting>>> getBusinessSettings() async {
    try {
      final data = await _remoteDataSource.getBusinessSettings();
      final settings = data.map((e) => BusinessSetting(
        id: e['id'] as String,
        key: e['key'] as String,
        value: Map<String, dynamic>.from(e['value'] as Map),
      )).toList();
      return right(settings);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> upsertBusinessSetting(String key, Map<String, dynamic> value) async {
    try {
      await _remoteDataSource.upsertBusinessSetting(key, value);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }
}
