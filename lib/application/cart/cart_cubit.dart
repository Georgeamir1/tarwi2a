import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/selected_option.dart';
import '../../../infrastructure/datasources/local/cart_local_data_source.dart';
import '../../../infrastructure/dtos/cart_item_dto.dart';

const Object _notProvided = Object();

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
    final optionSnapshot = List<SelectedOption>.unmodifiable(selectedOptions);
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere(
      (item) =>
          item.productId == product.id &&
          _optionsEqual(item.selectedOptions, optionSnapshot),
    );
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(
        productId: product.id,
        productNameAr: product.nameAr,
        productPrice: product.price,
        productImageUrl: product.imageUrl,
        quantity: 1,
        selectedOptions: optionSnapshot,
      ));
    }
    emit(CartState(items: items));
    _saveCart();
  }

  void addItems(List<CartItem> newItems) {
    final items = List<CartItem>.from(state.items);
    for (final item in newItems) {
      final newItem = item.copyWith(
        selectedOptions: List<SelectedOption>.unmodifiable(
          item.selectedOptions,
        ),
      );
      final index = items.indexWhere(
        (item) =>
            item.productId == newItem.productId &&
            _optionsEqual(item.selectedOptions, newItem.selectedOptions),
      );
      if (index >= 0) {
        items[index] = items[index]
            .copyWith(quantity: items[index].quantity + newItem.quantity);
      } else {
        items.add(newItem);
      }
    }
    emit(state.copyWith(items: items));
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

  void setDeliveryZone({
    required String deliveryZoneId,
    required String deliveryZoneName,
    required double deliveryFee,
  }) {
    emit(state.copyWith(
      deliveryZoneId: deliveryZoneId,
      deliveryZoneName: deliveryZoneName,
      deliveryFee: deliveryFee,
    ));
  }

  void clearDeliveryZone() {
    emit(state.copyWith(
      deliveryZoneId: null,
      deliveryZoneName: null,
      deliveryFee: 0,
    ));
  }

  void applyCoupon(String couponId, double discountAmount) {
    emit(state.copyWith(
      appliedCouponId: couponId,
      discountAmount: discountAmount,
    ));
  }

  void removeCoupon() {
    emit(state.copyWith(appliedCouponId: null, discountAmount: 0));
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
  final String? appliedCouponId;
  final double discountAmount;
  final String? deliveryZoneId;
  final String? deliveryZoneName;
  final double deliveryFee;

  const CartState({
    this.items = const [],
    this.appliedCouponId,
    this.discountAmount = 0,
    this.deliveryZoneId,
    this.deliveryZoneName,
    this.deliveryFee = 0,
  });

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  double get finalTotal =>
      (total - discountAmount + deliveryFee).clamp(0, double.infinity);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItem>? items,
    Object? appliedCouponId = _notProvided,
    double? discountAmount,
    Object? deliveryZoneId = _notProvided,
    Object? deliveryZoneName = _notProvided,
    double? deliveryFee,
  }) {
    return CartState(
      items: items ?? this.items,
      appliedCouponId: identical(appliedCouponId, _notProvided)
          ? this.appliedCouponId
          : appliedCouponId as String?,
      discountAmount: discountAmount ?? this.discountAmount,
      deliveryZoneId: identical(deliveryZoneId, _notProvided)
          ? this.deliveryZoneId
          : deliveryZoneId as String?,
      deliveryZoneName: identical(deliveryZoneName, _notProvided)
          ? this.deliveryZoneName
          : deliveryZoneName as String?,
      deliveryFee: deliveryFee ?? this.deliveryFee,
    );
  }

  @override
  List<Object?> get props => [
        items,
        appliedCouponId,
        discountAmount,
        deliveryZoneId,
        deliveryZoneName,
        deliveryFee,
      ];
}
