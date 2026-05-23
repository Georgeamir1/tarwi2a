// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryDTO _$CategoryDTOFromJson(Map<String, dynamic> json) => CategoryDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String,
      imageUrl: json['image_url'] as String?,
      sortOrder: (json['sort_order'] as num).toInt(),
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$CategoryDTOToJson(CategoryDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_ar': instance.nameAr,
      'image_url': instance.imageUrl,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
    };
