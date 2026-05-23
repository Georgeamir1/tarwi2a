// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_option_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductOptionDTO _$ProductOptionDTOFromJson(Map<String, dynamic> json) =>
    ProductOptionDTO(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String?,
      priceDelta: (json['price_delta'] as num).toDouble(),
      isRequired: json['is_required'] as bool,
      maxSelections: (json['max_selections'] as num).toInt(),
      sortOrder: (json['sort_order'] as num).toInt(),
    );

Map<String, dynamic> _$ProductOptionDTOToJson(ProductOptionDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'name': instance.name,
      'name_ar': instance.nameAr,
      'price_delta': instance.priceDelta,
      'is_required': instance.isRequired,
      'max_selections': instance.maxSelections,
      'sort_order': instance.sortOrder,
    };
