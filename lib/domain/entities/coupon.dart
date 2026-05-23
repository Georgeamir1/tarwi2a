import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/coupon_type.dart';

part 'coupon.freezed.dart';

@freezed
class Coupon with _$Coupon {
  const factory Coupon({
    required String id,
    required String code,
    required CouponType type,
    required double value,
    required double minOrder,
    double? maxDiscount,
    int? maxUses,
    required int usedCount,
    DateTime? startDate,
    DateTime? endDate,
    required bool isActive,
    required DateTime createdAt,
  }) = _Coupon;
}
