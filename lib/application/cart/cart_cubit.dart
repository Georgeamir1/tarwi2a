import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/selected_option.dart';
import '../../../infrastructure/datasources/local/cart_local_data_source.dart';
import '../../../infrastructure/dtos/cart_item_dto.dart';

class CartCubit extends Cubit<CartState> {
  final CartLocalDataSource _localDataSource;

  CartCubit(this._localDataSource) : super(const CartState());

  Future<void> loadCart() async {
    final dtos = await _localDataSource.loadCart();
    final items = dtos.map((dto) => dto.toDomain()).toList();
    emit(CartState(items: items));
  }

  void addItem(Product product,
      {List<SelectedOption> selectedOptions = const []}) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere(
      (item) =>
          item.productId == product.id &&
          _optionsEqual(item.selectedOptions, selectedOptions),
    );
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(
        productId: product.id,
        productNameAr: product.nameAr,
        productPrice: product.price,
        quantity: 1,
        selectedOptions: selectedOptions,
      ));
    }
    emit(CartState(items: items));
    _saveCart();
  }

  void removeItem(String productId,
      {List<SelectedOption> selectedOptions = const []}) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere(
      (item) =>
          item.productId == productId &&
          _optionsEqual(item.selectedOptions, selectedOptions),
    );
    if (index >= 0) {
      if (items[index].quantity > 1) {
        items[index] =
            items[index].copyWith(quantity: items[index].quantity - 1);
      } else {
        items.removeAt(index);
      }
    }
    emit(CartState(items: items));
    _saveCart();
  }

  void deleteItem(String productId,
      {List<SelectedOption> selectedOptions = const []}) {
    final items = state.items
        .where((item) => !(item.productId == productId &&
            _optionsEqual(item.selectedOptions, selectedOptions)))
        .toList();
    emit(CartState(items: items));
    _saveCart();
  }

  void clearCart() {
    emit(const CartState());
    _saveCart();
  }

  bool _optionsEqual(List<SelectedOption> a, List<SelectedOption> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((e) => e.optionId).toList()..sort();
    final bIds = b.map((e) => e.optionId).toList()..sort();
    return aIds.join(',') == bIds.join(',');
  }

  Future<void> _saveCart() async {
    final dtos =
        state.items.map((item) => CartItemDTO.fromDomain(item)).toList();
    await _localDataSource.saveCart(dtos);
  }
}

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items];
}
