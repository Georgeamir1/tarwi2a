import 'package:dartz/dartz.dart' hide Order;
import 'package:uuid/uuid.dart';
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
    String? requestId,
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
    String? couponCode,
    double? discountAmount,
    double? deliveryFee,
    String? deliveryZoneId,
    String? deliveryZoneName,
  }) async {
    try {
      final effectiveRequestId =
          (requestId != null && requestId.trim().isNotEmpty)
              ? requestId.trim()
              : const Uuid().v4();

      final payload = <String, dynamic>{
        'request_id': effectiveRequestId,
        'order_type': orderType ?? 'delivery',
        'payment_method': paymentMethod,
        'items': items,
        if (addressId != null) 'address_id': addressId,
        if (couponId != null) 'coupon_id': couponId,
        if (couponCode != null) 'coupon_code': couponCode,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        if (scheduledFor != null)
          'scheduled_for': scheduledFor.toIso8601String(),
        if (customerName.trim().isNotEmpty)
          'customer_name': customerName.trim(),
        if (customerPhone.trim().isNotEmpty)
          'customer_phone': customerPhone.trim(),
      };

      appLogger.d(
          '[OrderRepo] createAuthoritativeOrder — calling datasource with request_id: $effectiveRequestId');
      final dto = await _remoteDataSource.createOrder(payload: payload);
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
  Future<Either<Failure, Order?>> getOrderById(String orderId) async {
    try {
      final dto = await _remoteDataSource.getOrderById(orderId);
      return right(dto?.toDomain());
    } catch (e, st) {
      appLogger.e('[OrderRepo] getOrderById FAILED', error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStatus(
      String orderId, String status) async {
    try {
      await _remoteDataSource.updateStatus(orderId, status);
      return right<Failure, void>(null);
    } catch (e, st) {
      appLogger.e('[OrderRepo] updateStatus FAILED', error: e, stackTrace: st);
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
    } catch (e, st) {
      appLogger.e('[OrderRepo] updatePaymentStatus FAILED',
          error: e, stackTrace: st);
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
