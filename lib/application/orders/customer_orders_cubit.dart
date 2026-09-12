import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../core/logger/app_logger.dart';
import 'package:dartz/dartz.dart' hide Order;
import '../../../domain/entities/order.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/order_repository.dart';

class CustomerOrdersCubit extends Cubit<CustomerOrdersState> {
  final OrderRepository _orderRepository;
  StreamSubscription<List<Map<String, dynamic>>>? _ordersSubscription;
  String? _watchedCustomerId;
  final Map<String, String> _lastSeenStatus = {};
  String? _activeRequestId;
  String? _activeRequestFingerprint;
  bool _isPlacing = false;

  String? get activeRequestId => _activeRequestId;

  void clearActiveRequestId() {
    _activeRequestId = null;
    _activeRequestFingerprint = null;
  }

  CustomerOrdersCubit(this._orderRepository)
      : super(CustomerOrdersState.initial());

  Future<void> loadOrders(String customerId) async {
    emit(state.copyWith(status: CustomerOrdersStatus.loading));
    final result = await _orderRepository.getCustomerOrders(customerId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: CustomerOrdersStatus.error,
        failure: failure,
      )),
      (orders) {
        for (final order in orders) {
          _lastSeenStatus[order.id] = order.status.value;
        }
        emit(state.copyWith(
          status: CustomerOrdersStatus.loaded,
          orders: orders,
        ));
      },
    );
    _watchOrders(customerId);
  }

  void _watchOrders(String customerId) {
    if (_watchedCustomerId == customerId) return;
    _ordersSubscription?.cancel();
    _watchedCustomerId = customerId;
    _ordersSubscription =
        _orderRepository.watchCustomerOrders(customerId).listen(
      (rows) {
        if (isClosed) return;
        _onCustomerOrdersChanged(rows);
      },
      onError: (Object e) {
        appLogger.e('[CustomerOrdersCubit] watchCustomerOrders error',
            error: e);
      },
    );
  }

  void _onCustomerOrdersChanged(List<Map<String, dynamic>> rows) {
    for (final row in rows) {
      final orderId = row['id'] as String;
      final status = row['status'] as String? ?? 'pending';
      final previousStatus = _lastSeenStatus[orderId];
      _lastSeenStatus[orderId] = status;
      if (previousStatus != null && previousStatus != status) {
        appLogger.d(
          '[CustomerOrdersCubit] order $orderId status changed '
          '$previousStatus → $status (server-side trigger will handle push)',
        );
      }
    }
    _silentRefresh();
  }

  Future<void> _silentRefresh() async {
    final id = _watchedCustomerId;
    if (id == null) return;
    final result = await _orderRepository.getCustomerOrders(id);
    result.fold(
      (failure) {
        appLogger.e('[CustomerOrdersCubit] silent refresh failed',
            error: failure);
      },
      (orders) {
        if (!isClosed) {
          emit(state.copyWith(
            status: CustomerOrdersStatus.loaded,
            orders: orders,
          ));
        }
      },
    );
  }

  Future<Either<Failure, Order>> placeOrder({
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
    if (isClosed || _isPlacing) {
      return left(const Failure.unexpected(message: 'الطلب قيد التنفيذ'));
    }

    // Refresh/realtime can change the visible status while submission is still
    // pending. Keep the request lock independent of that presentation state.
    _isPlacing = true;
    final fingerprint = jsonEncode([
      customerId,
      customerName.trim(),
      customerPhone.trim(),
      paymentMethod,
      items,
      orderType,
      addressId,
      couponId,
      couponCode,
      notes?.trim(),
      scheduledFor?.toIso8601String(),
    ]);
    if (_activeRequestFingerprint != fingerprint) {
      _activeRequestId = null;
      _activeRequestFingerprint = fingerprint;
    }
    final effectiveRequestId =
        requestId ?? _activeRequestId ?? const Uuid().v4();
    _activeRequestId = effectiveRequestId;

    if (!isClosed) emit(state.copyWith(status: CustomerOrdersStatus.placing));
    try {
      final result = await _orderRepository.createOrder(
        requestId: effectiveRequestId,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        notes: notes,
        paymentMethod: paymentMethod,
        totalAmount: totalAmount,
        items: items,
        scheduledFor: scheduledFor,
        orderType: orderType,
        addressId: addressId,
        couponId: couponId,
        couponCode: couponCode,
        discountAmount: discountAmount,
        deliveryFee: deliveryFee,
        deliveryZoneId: deliveryZoneId,
        deliveryZoneName: deliveryZoneName,
      );
      return result.fold(
        (failure) {
          if (!isClosed) {
            emit(state.copyWith(
              status: CustomerOrdersStatus.error,
              failure: failure,
            ));
          }
          // Retain _activeRequestId on failure for idempotent retry
          return left(failure);
        },
        (order) {
          // Clear active request ID on success
          clearActiveRequestId();
          if (!isClosed) {
            emit(state.copyWith(status: CustomerOrdersStatus.placed));
          }
          return right(order);
        },
      );
    } finally {
      _isPlacing = false;
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}

enum CustomerOrdersStatus { initial, loading, loaded, placing, placed, error }

class CustomerOrdersState extends Equatable {
  final List<Order> orders;
  final CustomerOrdersStatus status;
  final Failure? failure;

  const CustomerOrdersState({
    this.orders = const [],
    this.status = CustomerOrdersStatus.initial,
    this.failure,
  });

  factory CustomerOrdersState.initial() => const CustomerOrdersState();

  CustomerOrdersState copyWith({
    List<Order>? orders,
    CustomerOrdersStatus? status,
    Failure? failure,
  }) {
    return CustomerOrdersState(
      orders: orders ?? this.orders,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [orders, status, failure];
}
