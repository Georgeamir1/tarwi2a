import '../../../domain/enums/coupon_type.dart';

extension CouponTypeX on CouponType {
  String get arabicLabel {
    switch (this) {
      case CouponType.percentage:
        return 'نسبة %';
      case CouponType.fixed:
        return 'مبلغ ثابت';
    }
  }
}
