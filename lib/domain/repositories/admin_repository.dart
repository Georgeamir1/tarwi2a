import 'package:dartz/dartz.dart';
import '../entities/user_profile.dart';
import '../entities/coupon.dart';
import '../entities/delivery_zone.dart';
import '../entities/business_setting.dart';
import '../failures/failure.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<UserProfile>>> getCustomers();
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats();
  Future<Either<Failure, List<Coupon>>> getCoupons();
  Future<Either<Failure, void>> upsertCoupon(Map<String, dynamic> data, {String? id});
  Future<Either<Failure, void>> toggleCouponActive(String id, bool isActive);
  Future<Either<Failure, List<DeliveryZone>>> getDeliveryZones();
  Future<Either<Failure, void>> upsertDeliveryZone(Map<String, dynamic> data, {String? id});
  Future<Either<Failure, List<BusinessSetting>>> getBusinessSettings();
  Future<Either<Failure, void>> upsertBusinessSetting(String key, Map<String, dynamic> value);
}
