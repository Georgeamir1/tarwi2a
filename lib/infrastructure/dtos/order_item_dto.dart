import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/order_item.dart';
import '../../../domain/entities/selected_option.dart';

part 'order_item_dto.g.dart';

@JsonSerializable()
class OrderItemDTO {
  final String id;
  @JsonKey(name: 'order_id')
  final String orderId;
  @JsonKey(name: 'product_id')
  final String? productId;
  @JsonKey(name: 'product_name')
  final String productName;
  @JsonKey(name: 'product_price')
  final double productPrice;
  final int quantity;
  final double subtotal;
  @JsonKey(name: 'selected_options')
  final List<Map<String, dynamic>>? selectedOptions;

  const OrderItemDTO({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.subtotal,
    this.selectedOptions,
  });

  factory OrderItemDTO.fromJson(Map<String, dynamic> json) =>
      _$OrderItemDTOFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemDTOToJson(this);

  OrderItem toDomain() => OrderItem(
        id: id,
        orderId: orderId,
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        quantity: quantity,
        subtotal: subtotal,
        selectedOptions: (selectedOptions ?? [])
            .map((e) => SelectedOption(
                  optionId: e['option_id'] as String? ?? '',
                  name: e['option_name'] as String? ?? '',
                  priceAdjustment:
                      (e['price_adjustment'] as num?)?.toDouble() ?? 0.0,
                ))
            .toList(),
      );

  static Map<String, dynamic> selectedOptionToJson(SelectedOption option) => {
        'option_id': option.optionId,
        'option_name': option.name,
        'price_adjustment': option.priceAdjustment,
      };
}
