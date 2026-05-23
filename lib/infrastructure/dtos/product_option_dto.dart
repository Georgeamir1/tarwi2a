import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/product_option.dart';

part 'product_option_dto.g.dart';

@JsonSerializable()
class ProductOptionDTO {
  final String id;
  @JsonKey(name: 'product_id')
  final String productId;
  final String name;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  @JsonKey(name: 'price_delta')
  final double priceDelta;
  @JsonKey(name: 'is_required')
  final bool isRequired;
  @JsonKey(name: 'max_selections')
  final int maxSelections;
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  const ProductOptionDTO({
    required this.id,
    required this.productId,
    required this.name,
    this.nameAr,
    required this.priceDelta,
    required this.isRequired,
    required this.maxSelections,
    required this.sortOrder,
  });

  factory ProductOptionDTO.fromJson(Map<String, dynamic> json) =>
      _$ProductOptionDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ProductOptionDTOToJson(this);

  ProductOption toDomain() => ProductOption(
        id: id,
        productId: productId,
        name: name,
        nameAr: nameAr,
        priceDelta: priceDelta,
        isRequired: isRequired,
        maxSelections: maxSelections,
        sortOrder: sortOrder,
      );
}
