import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/customer_repository.dart';

class AdminCustomersCubit extends Cubit<AdminCustomersState> {
  final CustomerRepository _repository;
  StreamSubscription? _subscription;
  String _currentQuery = '';

  AdminCustomersCubit(this._repository) : super(AdminCustomersState.initial());

  Future<void> loadCustomers() async {
    appLogger.i('📥 loadCustomers() called');
    emit(state.copyWith(status: AdminCustomersStatus.loading));
    final result = await _repository.getAll();
    result.fold(
      (failure) {
        appLogger.e('📥 loadCustomers() FAILED: ${failure.runtimeType}');
        emit(state.copyWith(
          status: AdminCustomersStatus.error,
          failure: failure,
        ));
      },
      (customers) {
        appLogger.i(
            '📥 loadCustomers() SUCCESS — ${customers.length} customers loaded');
        emit(state.copyWith(
          status: AdminCustomersStatus.loaded,
          customers: customers,
          filteredCustomers: customers,
        ));
      },
    );
    appLogger.i('📡 subscribing to customers realtime stream');
    _listenToStream();
  }

  void _listenToStream() {
    _subscription?.cancel();
    _subscription = _repository.watchCustomers().listen(
      (customers) {
        if (!isClosed) {
          if (customers.isEmpty && state.customers.isNotEmpty) {
            return;
          }
          final filtered = _currentQuery.isEmpty
              ? customers
              : customers.where((c) {
                  return c.name.toLowerCase().contains(_currentQuery) ||
                      (c.phone?.contains(_currentQuery) ?? false);
                }).toList();
          emit(state.copyWith(
            customers: customers,
            filteredCustomers: filtered,
            status: AdminCustomersStatus.loaded,
          ));
        }
      },
      onError: (e) {
        if (!isClosed) {
          appLogger.w('Customers realtime stream error (kept cached data)',
              error: e);
        }
      },
    );
  }

  void search(String query) {
    _currentQuery = query.trim().toLowerCase();
    if (_currentQuery.isEmpty) {
      emit(state.copyWith(filteredCustomers: state.customers));
      return;
    }
    final filtered = state.customers.where((c) {
      return c.name.toLowerCase().contains(_currentQuery) ||
          (c.phone?.contains(query) ?? false);
    }).toList();
    emit(state.copyWith(filteredCustomers: filtered));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

enum AdminCustomersStatus { initial, loading, loaded, error }

class AdminCustomersState extends Equatable {
  final List<Customer> customers;
  final List<Customer> filteredCustomers;
  final AdminCustomersStatus status;
  final Failure? failure;

  const AdminCustomersState({
    this.customers = const [],
    this.filteredCustomers = const [],
    this.status = AdminCustomersStatus.initial,
    this.failure,
  });

  factory AdminCustomersState.initial() => const AdminCustomersState();

  AdminCustomersState copyWith({
    List<Customer>? customers,
    List<Customer>? filteredCustomers,
    AdminCustomersStatus? status,
    Failure? failure,
  }) {
    return AdminCustomersState(
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [customers, filteredCustomers, status, failure];
}
