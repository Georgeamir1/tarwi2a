import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/category.dart';

part 'category_dto.g.dart';

@JsonSerializable()
class CategoryDTO {
  final String id;
  final String name;
  @JsonKey(name: 'name_ar')
  final String nameAr;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const CategoryDTO({
    required this.id,
    required this.name,
    required this.nameAr,
    this.imageUrl,
    required this.sortOrder,
    required this.isActive,
  });

  factory CategoryDTO.fromJson(Map<String, dynamic> json) =>
      _$CategoryDTOFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryDTOToJson(this);

  Category toDomain() => Category(
        id: id,
        name: name,
        nameAr: nameAr,
        imageUrl: imageUrl,
        sortOrder: sortOrder,
        isActive: isActive,
      );
}
