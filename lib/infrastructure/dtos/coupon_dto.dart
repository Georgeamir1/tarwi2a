import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/coupon.dart';
import '../../../domain/enums/coupon_type.dart';

part 'coupon_dto.g.dart';

@JsonSerializable()
class CouponDTO {
  final String id;
  final String code;
  final String type;
  final double value;
  @JsonKey(name: 'min_order')
  final double minOrder;
  @JsonKey(name: 'max_discount')
  final double? maxDiscount;
  @JsonKey(name: 'max_uses')
  final int? maxUses;
  @JsonKey(name: 'used_count')
  final int usedCount;
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const CouponDTO({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minOrder,
    this.maxDiscount,
    this.maxUses,
    required this.usedCount,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
  });

  factory CouponDTO.fromJson(Map<String, dynamic> json) =>
      _$CouponDTOFromJson(json);

  Map<String, dynamic> toJson() => _$CouponDTOToJson(this);

  Coupon toDomain() => Coupon(
        id: id,
        code: code,
        type: CouponType.fromString(type),
        value: value,
        minOrder: minOrder,
        maxDiscount: maxDiscount,
        maxUses: maxUses,
        usedCount: usedCount,
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,
        createdAt: createdAt,
      );
}
