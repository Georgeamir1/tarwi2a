import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/order_status.dart';
import '../enums/payment_method.dart';
import 'order_item.dart';

part 'order.freezed.dart';

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    String? customerId,
    required String customerName,
    required String customerPhone,
    String? customerAddress,
    String? notes,
    required PaymentMethod paymentMethod,
    required OrderStatus status,
    required double totalAmount,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<OrderItem> items,
    DateTime? scheduledFor,
    @Default('delivery') String orderType,
    String? addressId,
    @Default('pending') String paymentStatus,
    String? paymentProofUrl,
    String? couponId,
    @Default(0.0) double discountAmount,
    @Default(0.0) double deliveryFee,
    String? deliveryZoneId,
    String? deliveryZoneName,
  }) = _Order;
}
