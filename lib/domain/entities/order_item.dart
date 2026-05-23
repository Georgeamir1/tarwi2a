import 'package:freezed_annotation/freezed_annotation.dart';
import 'selected_option.dart';

part 'order_item.freezed.dart';

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    required String orderId,
    String? productId,
    required String productName,
    required double productPrice,
    required int quantity,
    required double subtotal,
    @Default([]) List<SelectedOption> selectedOptions,
  }) = _OrderItem;
}
