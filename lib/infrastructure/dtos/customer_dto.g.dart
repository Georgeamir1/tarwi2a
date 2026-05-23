// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerDTO _$CustomerDTOFromJson(Map<String, dynamic> json) => CustomerDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      totalOrders: (json['total_orders'] as num?)?.toInt(),
      totalSpent: (json['total_spent'] as num?)?.toDouble(),
      lastOrderAt: json['last_order_at'] == null
          ? null
          : DateTime.parse(json['last_order_at'] as String),
    );

Map<String, dynamic> _$CustomerDTOToJson(CustomerDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'role': instance.role,
      'created_at': instance.createdAt?.toIso8601String(),
      'total_orders': instance.totalOrders,
      'total_spent': instance.totalSpent,
      'last_order_at': instance.lastOrderAt?.toIso8601String(),
    };
