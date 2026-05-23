import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/order_repository.dart';

class CustomerOrdersCubit extends Cubit<CustomerOrdersState> {
  final OrderRepository _orderRepository;

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
      (orders) => emit(state.copyWith(
        status: CustomerOrdersStatus.loaded,
        orders: orders,
      )),
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
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: CustomerOrdersStatus.error,
        failure: failure,
      )),
      (_) => emit(state.copyWith(status: CustomerOrdersStatus.placed)),
    );
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
