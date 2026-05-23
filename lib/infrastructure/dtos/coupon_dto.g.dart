// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponDTO _$CouponDTOFromJson(Map<String, dynamic> json) => CouponDTO(
      id: json['id'] as String,
      code: json['code'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      minOrder: (json['min_order'] as num).toDouble(),
      maxDiscount: (json['max_discount'] as num?)?.toDouble(),
      maxUses: (json['max_uses'] as num?)?.toInt(),
      usedCount: (json['used_count'] as num).toInt(),
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CouponDTOToJson(CouponDTO instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'type': instance.type,
      'value': instance.value,
      'min_order': instance.minOrder,
      'max_discount': instance.maxDiscount,
      'max_uses': instance.maxUses,
      'used_count': instance.usedCount,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };
