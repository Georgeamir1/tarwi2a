import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_option.freezed.dart';

@freezed
class ProductOption with _$ProductOption {
  const factory ProductOption({
    required String id,
    required String productId,
    required String name,
    String? nameAr,
    @Default(0.0) double priceDelta,
    @Default(false) bool isRequired,
    @Default(1) int maxSelections,
    @Default(0) int sortOrder,
  }) = _ProductOption;
}
