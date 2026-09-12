import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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
        final filterId = categoryId ?? state.selectedCategoryId;
        final query = state.searchQuery;
        emit(state.copyWith(
          status: ProductsStatus.loaded,
          allProducts: products,
          products: _filter(products, filterId, query),
          selectedCategoryId: filterId,
        ));
      },
    );
  }

  void selectCategory(String? categoryId) {
    emit(state.copyWith(
      selectedCategoryId: categoryId,
      products: _filter(state.allProducts, categoryId, state.searchQuery),
    ));
  }

  void searchProducts(String query) {
    emit(state.copyWith(
      searchQuery: query,
      products: _filter(
        state.allProducts,
        state.selectedCategoryId,
        query,
      ),
    ));
  }

  List<Product> _filter(
    List<Product> source,
    String? categoryId,
    String query,
  ) {
    var result = source;
    if (categoryId != null) {
      result = result.where((p) => p.categoryId == categoryId).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where(
            (p) =>
                p.nameAr.toLowerCase().contains(q) ||
                p.name.toLowerCase().contains(q) ||
                (p.descriptionAr?.toLowerCase().contains(q) ?? false) ||
                (p.description?.toLowerCase().contains(q) ?? false) ||
                p.tags.any((t) => t.toLowerCase().contains(q)),
          )
          .toList();
    }
    return result;
  }
}

enum ProductsStatus { initial, loading, loaded, error }

class ProductsState extends Equatable {
  final List<Product> products;
  final List<Product> allProducts;
  final String? selectedCategoryId;
  final String searchQuery;
  final ProductsStatus status;
  final Failure? failure;

  const ProductsState({
    this.products = const [],
    this.allProducts = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.status = ProductsStatus.initial,
    this.failure,
  });

  factory ProductsState.initial() => const ProductsState();

  ProductsState copyWith({
    List<Product>? products,
    List<Product>? allProducts,
    String? selectedCategoryId,
    bool clearSelectedCategory = false,
    String? searchQuery,
    ProductsStatus? status,
    Failure? failure,
  }) {
    return ProductsState(
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props =>
      [products, allProducts, selectedCategoryId, searchQuery, status, failure];
}
