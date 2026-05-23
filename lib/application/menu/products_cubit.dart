import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/product_repository.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository _repository;

  ProductsCubit(this._repository) : super(ProductsState.initial());

  Future<void> loadProducts({String? categoryId}) async {
    emit(state.copyWith(status: ProductsStatus.loading));
    final result = await _repository.getProducts(categoryId: categoryId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductsStatus.error,
        failure: failure,
      )),
      (products) {
        for (final p in products) {
          appLogger.d('[ProductsCubit] ${p.nameAr} — imageUrl: ${p.imageUrl}');
        }
        emit(state.copyWith(
          status: ProductsStatus.loaded,
          products: products,
        ));
      },
    );
  }

  void selectCategory(String? categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
    loadProducts(categoryId: categoryId);
  }
}

enum ProductsStatus { initial, loading, loaded, error }

class ProductsState extends Equatable {
  final List<Product> products;
  final String? selectedCategoryId;
  final ProductsStatus status;
  final Failure? failure;

  const ProductsState({
    this.products = const [],
    this.selectedCategoryId,
    this.status = ProductsStatus.initial,
    this.failure,
  });

  factory ProductsState.initial() => const ProductsState();

  ProductsState copyWith({
    List<Product>? products,
    String? selectedCategoryId,
    ProductsStatus? status,
    Failure? failure,
  }) {
    return ProductsState(
      products: products ?? this.products,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [products, selectedCategoryId, status, failure];
}
