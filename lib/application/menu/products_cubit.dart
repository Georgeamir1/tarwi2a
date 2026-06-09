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
    final result = await _repository.getProducts();
    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductsStatus.error,
        failure: failure,
      )),
      (products) {
        for (final p in products) {
          appLogger.d('[ProductsCubit] ${p.nameAr} — imageUrl: ${p.imageUrl}');
        }
        final filterId = categoryId ?? state.selectedCategoryId;
        emit(state.copyWith(
          status: ProductsStatus.loaded,
          allProducts: products,
          products: _filterByCategory(products, filterId),
        ));
      },
    );
  }

  void selectCategory(String? categoryId) {
    emit(state.copyWith(
      selectedCategoryId: categoryId,
      products: _filterByCategory(state.allProducts, categoryId),
    ));
  }

  List<Product> _filterByCategory(List<Product> source, String? categoryId) {
    if (categoryId == null) return source;
    return source.where((p) => p.categoryId == categoryId).toList();
  }
}

enum ProductsStatus { initial, loading, loaded, error }

class ProductsState extends Equatable {
  final List<Product> products;
  final List<Product> allProducts;
  final String? selectedCategoryId;
  final ProductsStatus status;
  final Failure? failure;

  const ProductsState({
    this.products = const [],
    this.allProducts = const [],
    this.selectedCategoryId,
    this.status = ProductsStatus.initial,
    this.failure,
  });

  factory ProductsState.initial() => const ProductsState();

  ProductsState copyWith({
    List<Product>? products,
    List<Product>? allProducts,
    String? selectedCategoryId,
    bool clearSelectedCategory = false,
    ProductsStatus? status,
    Failure? failure,
  }) {
    return ProductsState(
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props =>
      [products, allProducts, selectedCategoryId, status, failure];
}
