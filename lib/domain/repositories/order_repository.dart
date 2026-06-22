import 'package:dartz/dartz.dart' hide Order;
import '../entities/order.dart';
import '../failures/failure.dart';

abstract class OrderRepository {
  Future<Either<Failure, Order>> createOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    String? customerAddress,
    String? notes,
    required String paymentMethod,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    DateTime? scheduledFor,
    String? orderType,
    String? addressId,
    String? couponId,
    double? discountAmount,
    double? deliveryFee,
    String? deliveryZoneId,
    String? deliveryZoneName,
  });

  Future<Either<Failure, List<Order>>> getCustomerOrders(String customerId);
  Future<Either<Failure, List<Order>>> getAllAdmin();
  Future<Either<Failure, void>> updateStatus(String orderId, String status);
  Future<Either<Failure, void>> updatePaymentStatus(
    String orderId,
    String paymentStatus, {
    String? paymentProofUrl,
  });
  Stream<List<Map<String, dynamic>>> watchOrders();
  Stream<List<Map<String, dynamic>>> watchCustomerOrders(String customerId);
}
