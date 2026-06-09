import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/product.dart';

part 'product_dto.g.dart';

@JsonSerializable()
class ProductDTO {
  final String id;
  @JsonKey(name: 'category_id')
  final String? categoryId;
  final String name;
  @JsonKey(name: 'name_ar')
  final String nameAr;
  final String? description;
  @JsonKey(name: 'description_ar')
  final String? descriptionAr;
  final double price;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'preparation_time')
  final int? preparationTime;
  final int? calories;
  @JsonKey(name: 'tags', fromJson: _tagsFromJson)
  final List<String> tags;
  @JsonKey(name: 'show_in_banner')
  final bool showInBanner;

  const ProductDTO({
    required this.id,
    this.categoryId,
    required this.name,
    required this.nameAr,
    this.description,
    this.descriptionAr,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    required this.sortOrder,
    this.preparationTime,
    this.calories,
    this.tags = const [],
    this.showInBanner = false,
  });

  factory ProductDTO.fromJson(Map<String, dynamic> json) =>
      _$ProductDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDTOToJson(this);

  Product toDomain() => Product(
        id: id,
        categoryId: categoryId,
        name: name,
        nameAr: nameAr,
        description: description,
        descriptionAr: descriptionAr,
        price: price,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        sortOrder: sortOrder,
        preparationTime: preparationTime,
        calories: calories,
        tags: tags,
        showInBanner: showInBanner,
      );

  static List<String> _tagsFromJson(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    return [];
  }
}
