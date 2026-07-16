import 'package:freezed_annotation/freezed_annotation.dart';
import 'selected_option.dart';

part 'cart_item.freezed.dart';

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String productId,
    required String productNameAr,
    required double productPrice,
    required int quantity,
    @Default([]) List<SelectedOption> selectedOptions,
    String? productImageUrl,
  }) = _CartItem;

  const CartItem._();

  double get optionsTotal => selectedOptions.fold(
        0.0,
        (sum, option) => sum + option.priceAdjustment,
      );

  double get subtotal => (productPrice + optionsTotal) * quantity;
}
