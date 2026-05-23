// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_zone_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryZoneDTO _$DeliveryZoneDTOFromJson(Map<String, dynamic> json) =>
    DeliveryZoneDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      fee: (json['fee'] as num).toDouble(),
      minOrderAmount: (json['min_order'] as num).toDouble(),
      estimatedTime: json['estimated_time'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      coordinates: json['coordinates'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DeliveryZoneDTOToJson(DeliveryZoneDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'fee': instance.fee,
      'min_order': instance.minOrderAmount,
      'estimated_time': instance.estimatedTime,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'coordinates': instance.coordinates,
    };
