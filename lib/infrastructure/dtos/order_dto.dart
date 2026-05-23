import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_status.dart';
import '../../../domain/enums/payment_method.dart';

import 'order_item_dto.dart';

part 'order_dto.g.dart';

@JsonSerializable()
class OrderDTO {
  final String id;
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @JsonKey(name: 'customer_name')
  final String customerName;
  @JsonKey(name: 'customer_phone')
  final String customerPhone;
  @JsonKey(name: 'customer_address')
  final String? customerAddress;
  final String? notes;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  final String status;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'order_items')
  final List<OrderItemDTO>? items;
  @JsonKey(name: 'scheduled_for')
  final DateTime? scheduledFor;
  @JsonKey(name: 'order_type')
  final String? orderType;
  @JsonKey(name: 'address_id')
  final String? addressId;
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;
  @JsonKey(name: 'payment_proof_url')
  final String? paymentProofUrl;
  @JsonKey(name: 'coupon_id')
  final String? couponId;
  @JsonKey(name: 'discount_amount')
  final double? discountAmount;

  const OrderDTO({
    required this.id,
    this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress,
    this.notes,
    required this.paymentMethod,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.items,
    this.scheduledFor,
    this.orderType,
    this.addressId,
    this.paymentStatus,
    this.paymentProofUrl,
    this.couponId,
    this.discountAmount,
  });

  factory OrderDTO.fromJson(Map<String, dynamic> json) =>
      _$OrderDTOFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDTOToJson(this);

  Order toDomain() => Order(
        id: id,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        notes: notes,
        paymentMethod: PaymentMethod.fromString(paymentMethod),
        status: OrderStatus.fromString(status),
        totalAmount: totalAmount,
        createdAt: createdAt,
        updatedAt: updatedAt,
        items: (items ?? []).map((e) => e.toDomain()).toList(),
        scheduledFor: scheduledFor,
        orderType: orderType ?? 'delivery',
        addressId: addressId,
        paymentStatus: paymentStatus ?? 'pending',
        paymentProofUrl: paymentProofUrl,
        couponId: couponId,
        discountAmount: discountAmount ?? 0.0,
      );
}
