// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDTO _$ProductDTOFromJson(Map<String, dynamic> json) => ProductDTO(
      id: json['id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool,
      sortOrder: (json['sort_order'] as num).toInt(),
      preparationTime: (json['preparation_time'] as num?)?.toInt(),
      calories: (json['calories'] as num?)?.toInt(),
      tags: json['tags'] == null
          ? const []
          : ProductDTO._tagsFromJson(json['tags']),
      showInBanner: json['show_in_banner'] as bool? ?? false,
    );

Map<String, dynamic> _$ProductDTOToJson(ProductDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'name': instance.name,
      'name_ar': instance.nameAr,
      'description': instance.description,
      'description_ar': instance.descriptionAr,
      'price': instance.price,
      'image_url': instance.imageUrl,
      'is_available': instance.isAvailable,
      'sort_order': instance.sortOrder,
      'preparation_time': instance.preparationTime,
      'calories': instance.calories,
      'tags': instance.tags,
      'show_in_banner': instance.showInBanner,
    };
