import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_option_group.freezed.dart';

@freezed
class ProductOptionGroup with _$ProductOptionGroup {
  const factory ProductOptionGroup({
    required String id,
    required String productId,
    required String name,
    @Default('single') String type,
    @Default(false) bool isRequired,
    @Default(0) int sortOrder,
  }) = _ProductOptionGroup;
}
