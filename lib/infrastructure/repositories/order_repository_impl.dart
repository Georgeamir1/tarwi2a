import 'package:dartz/dartz.dart' hide Order;
import '../../../domain/entities/order.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../core/logger/app_logger.dart';
import '../datasources/remote/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  @override
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
  }) async {
    try {
      final orderData = {
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_address': customerAddress,
        'notes': notes,
        'payment_method': paymentMethod,
        'total_amount': totalAmount,
        'status': 'pending',
        if (scheduledFor != null)
          'scheduled_for': scheduledFor.toIso8601String(),
        if (orderType != null) 'order_type': orderType,
        if (addressId != null) 'address_id': addressId,
        if (couponId != null) 'coupon_id': couponId,
        if (discountAmount != null) 'discount_amount': discountAmount,
        if (deliveryFee != null) 'delivery_fee': deliveryFee,
        if (deliveryZoneId != null) 'delivery_zone_id': deliveryZoneId,
        if (deliveryZoneName != null) 'delivery_zone_name': deliveryZoneName,
      };
      appLogger.d('[OrderRepo] createOrder — calling datasource...');
      final dto = await _remoteDataSource.createOrder(
        orderData: orderData,
        itemsData: items,
      );
      appLogger.d('[OrderRepo] createOrder — success, id: ${dto.id}');
      return right(dto.toDomain());
    } catch (e, st) {
      appLogger.e('[OrderRepo] createOrder FAILED', error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getCustomerOrders(
      String customerId) async {
    try {
      final dtos = await _remoteDataSource.getCustomerOrders(customerId);
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getAllAdmin() async {
    try {
      final dtos = await _remoteDataSource.getAllAdmin();
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStatus(
      String orderId, String status) async {
    try {
      await _remoteDataSource.updateStatus(orderId, status);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePaymentStatus(
    String orderId,
    String paymentStatus, {
    String? paymentProofUrl,
  }) async {
    try {
      await _remoteDataSource.updatePaymentStatus(
        orderId,
        paymentStatus,
        paymentProofUrl: paymentProofUrl,
      );
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchOrders() {
    return _remoteDataSource.watchOrders();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchCustomerOrders(String customerId) {
    return _remoteDataSource.watchCustomerOrders(customerId);
  }
}
