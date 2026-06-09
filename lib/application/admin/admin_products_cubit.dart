import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/product_repository.dart';

class AdminProductsCubit extends Cubit<AdminProductsState> {
  final ProductRepository _repository;
  StreamSubscription? _subscription;

  AdminProductsCubit(this._repository) : super(AdminProductsState.initial());

  Future<void> loadProducts() async {
    emit(state.copyWith(status: AdminProductsStatus.loading));
    final result = await _repository.getAllAdmin();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminProductsStatus.error,
        failure: failure,
      )),
      (products) => emit(state.copyWith(
        status: AdminProductsStatus.loaded,
        products: products,
      )),
    );
    _listenToStream();
  }

  void _listenToStream() {
    _subscription?.cancel();
    _subscription = _repository.watchProducts().listen(
      (products) {
        if (!isClosed) {
          emit(state.copyWith(
            products: products,
            status: AdminProductsStatus.loaded,
          ));
        }
      },
      onError: (e) {
        if (!isClosed) {
          emit(state.copyWith(
            failure: Failure.unexpected(message: e.toString()),
          ));
        }
      },
    );
  }

  Future<void> upsert(Map<String, dynamic> data, {String? id}) async {
    emit(state.copyWith(status: AdminProductsStatus.loading));
    final result = await _repository.upsertProduct(data, id: id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminProductsStatus.error,
        failure: failure,
      )),
      (_) => loadProducts(),
    );
  }

  Future<void> toggleAvailable(String id, bool isAvailable) async {
    emit(state.copyWith(status: AdminProductsStatus.loading));
    final result = await _repository.toggleAvailable(id, isAvailable);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminProductsStatus.error,
        failure: failure,
      )),
      (_) => loadProducts(),
    );
  }

  Future<void> deleteProduct(String id) async {
    emit(state.copyWith(status: AdminProductsStatus.loading));
    final result = await _repository.deleteProduct(id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminProductsStatus.error,
        failure: failure,
      )),
      (_) => loadProducts(),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

enum AdminProductsStatus { initial, loading, loaded, error }

class AdminProductsState extends Equatable {
  final List<Product> products;
  final AdminProductsStatus status;
  final Failure? failure;

  const AdminProductsState({
    this.products = const [],
    this.status = AdminProductsStatus.initial,
    this.failure,
  });

  factory AdminProductsState.initial() => const AdminProductsState();

  AdminProductsState copyWith({
    List<Product>? products,
    AdminProductsStatus? status,
    Failure? failure,
  }) {
    return AdminProductsState(
      products: products ?? this.products,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [products, status, failure];
}
