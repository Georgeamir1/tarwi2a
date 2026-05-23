// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessProfileDTO _$BusinessProfileDTOFromJson(Map<String, dynamic> json) =>
    BusinessProfileDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logo_url'] as String?,
      openingHours: json['opening_hours'] as Map<String, dynamic>?,
      minOrder: (json['min_order'] as num).toDouble(),
      defaultPrepTime: (json['default_prep_time'] as num).toInt(),
      isBusy: json['is_busy'] as bool,
      busyMessage: json['busy_message'] as String?,
      acceptOrders: json['accept_orders'] as bool,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BusinessProfileDTOToJson(BusinessProfileDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
      'logo_url': instance.logoUrl,
      'opening_hours': instance.openingHours,
      'min_order': instance.minOrder,
      'default_prep_time': instance.defaultPrepTime,
      'is_busy': instance.isBusy,
      'busy_message': instance.busyMessage,
      'accept_orders': instance.acceptOrders,
      'updated_at': instance.updatedAt.toIso8601String(),
    };
