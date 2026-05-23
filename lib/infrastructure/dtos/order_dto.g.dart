// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDTO _$OrderDTOFromJson(Map<String, dynamic> json) => OrderDTO(
      id: json['id'] as String,
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      customerAddress: json['customer_address'] as String?,
      notes: json['notes'] as String?,
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: (json['order_items'] as List<dynamic>?)
          ?.map((e) => OrderItemDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      scheduledFor: json['scheduled_for'] == null
          ? null
          : DateTime.parse(json['scheduled_for'] as String),
      orderType: json['order_type'] as String?,
      addressId: json['address_id'] as String?,
      paymentStatus: json['payment_status'] as String?,
      paymentProofUrl: json['payment_proof_url'] as String?,
      couponId: json['coupon_id'] as String?,
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OrderDTOToJson(OrderDTO instance) => <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
      'customer_address': instance.customerAddress,
      'notes': instance.notes,
      'payment_method': instance.paymentMethod,
      'status': instance.status,
      'total_amount': instance.totalAmount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'order_items': instance.items,
      'scheduled_for': instance.scheduledFor?.toIso8601String(),
      'order_type': instance.orderType,
      'address_id': instance.addressId,
      'payment_status': instance.paymentStatus,
      'payment_proof_url': instance.paymentProofUrl,
      'coupon_id': instance.couponId,
      'discount_amount': instance.discountAmount,
    };
