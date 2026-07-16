// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_rating_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderRatingDTO _$OrderRatingDTOFromJson(Map<String, dynamic> json) =>
    OrderRatingDTO(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$OrderRatingDTOToJson(OrderRatingDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
    };
