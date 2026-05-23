import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/services/notification_service.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/order_repository.dart';

class AdminOrdersCubit extends Cubit<AdminOrdersState> {
  final OrderRepository _orderRepository;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  AdminOrdersCubit(this._orderRepository) : super(AdminOrdersState.initial());

  Future<void> loadOrders() async {
    emit(state.copyWith(status: AdminOrdersStatus.loading));
    final result = await _orderRepository.getAllAdmin();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminOrdersStatus.error,
        failure: failure,
      )),
      (orders) => emit(state.copyWith(
        status: AdminOrdersStatus.loaded,
        orders: orders,
      )),
    );
    _listenToStream();
  }

  void _listenToStream() {
    _subscription?.cancel();
    _subscription = _orderRepository.watchOrders().listen((_) {
      _silentRefresh();
    });
  }

  Future<void> _silentRefresh() async {
    final result = await _orderRepository.getAllAdmin();
    result.fold(
      (failure) {
        appLogger.e('[AdminOrdersCubit] silent refresh failed', error: failure);
      },
      (orders) {
        if (!isClosed) {
          _checkNewOrders(orders);
          emit(state.copyWith(orders: orders));
        }
      },
    );
  }

  void _checkNewOrders(List<Order> newOrders) {
    final oldIds = state.orders.map((o) => o.id).toSet();
    for (final order in newOrders) {
      if (!oldIds.contains(order.id) && order.status.value == 'pending') {
        NotificationService.showNewOrderNotification(
          orderId: order.id,
          customerName: order.customerName,
          total: order.totalAmount,
        );
        appLogger.d('[AdminOrdersCubit] new order detected: ${order.id}');
        break; // notify only once per refresh
      }
    }
  }

  Future<void> updateStatus(String orderId, String status) async {
    await _orderRepository.updateStatus(orderId, status);
    loadOrders();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

enum AdminOrdersStatus { initial, loading, loaded, error }

class AdminOrdersState extends Equatable {
  final List<Order> orders;
  final AdminOrdersStatus status;
  final Failure? failure;

  const AdminOrdersState({
    this.orders = const [],
    this.status = AdminOrdersStatus.initial,
    this.failure,
  });

  factory AdminOrdersState.initial() => const AdminOrdersState();

  AdminOrdersState copyWith({
    List<Order>? orders,
    AdminOrdersStatus? status,
    Failure? failure,
  }) {
    return AdminOrdersState(
      orders: orders ?? this.orders,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [orders, status, failure];
}
