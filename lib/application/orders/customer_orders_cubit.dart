import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/order_repository.dart';

class CustomerOrdersCubit extends Cubit<CustomerOrdersState> {
  final OrderRepository _orderRepository;
  StreamSubscription<List<Map<String, dynamic>>>? _ordersSubscription;
  String? _watchedCustomerId;
  final Map<String, String> _lastSeenStatus = {};

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

  Future<void> placeOrder({
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
    emit(state.copyWith(status: CustomerOrdersStatus.placing));
    final result = await _orderRepository.createOrder(
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
      discountAmount: discountAmount,
      deliveryFee: deliveryFee,
      deliveryZoneId: deliveryZoneId,
      deliveryZoneName: deliveryZoneName,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: CustomerOrdersStatus.error,
        failure: failure,
      )),
      (_) => emit(state.copyWith(status: CustomerOrdersStatus.placed)),
    );
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
