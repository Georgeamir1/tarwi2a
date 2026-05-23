import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/selected_option.dart';

part 'cart_item_dto.g.dart';

@JsonSerializable()
class CartItemDTO {
  final String productId;
  final String productNameAr;
  final double productPrice;
  final int quantity;
  final List<Map<String, dynamic>>? selectedOptions;

  const CartItemDTO({
    required this.productId,
    required this.productNameAr,
    required this.productPrice,
    required this.quantity,
    this.selectedOptions,
  });

  factory CartItemDTO.fromJson(Map<String, dynamic> json) =>
      _$CartItemDTOFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemDTOToJson(this);

  CartItem toDomain() => CartItem(
        productId: productId,
        productNameAr: productNameAr,
        productPrice: productPrice,
        quantity: quantity,
        selectedOptions: (selectedOptions ?? [])
            .map((e) => SelectedOption(
                  optionId: e['option_id'] as String? ?? '',
                  name: e['option_name'] as String? ?? '',
                  priceAdjustment:
                      (e['price_adjustment'] as num?)?.toDouble() ?? 0.0,
                ))
            .toList(),
      );

  factory CartItemDTO.fromDomain(CartItem item) => CartItemDTO(
        productId: item.productId,
        productNameAr: item.productNameAr,
        productPrice: item.productPrice,
        quantity: item.quantity,
        selectedOptions: item.selectedOptions
            .map((e) => {
                  'option_id': e.optionId,
                  'option_name': e.name,
                  'price_adjustment': e.priceAdjustment,
                })
            .toList(),
      );
}
