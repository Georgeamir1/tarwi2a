import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_option.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    String? categoryId,
    required String name,
    required String nameAr,
    String? description,
    String? descriptionAr,
    required double price,
    String? imageUrl,
    required bool isAvailable,
    required int sortOrder,
    int? preparationTime,
    int? calories,
    @Default([]) List<String> tags,
    Map<String, dynamic>? businessHours,
    @Default([]) List<ProductOption> options,
    @Default(false) bool showInBanner,
  }) = _Product;
}
