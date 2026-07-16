// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItemDTO _$CartItemDTOFromJson(Map<String, dynamic> json) => CartItemDTO(
      productId: json['productId'] as String,
      productNameAr: json['productNameAr'] as String,
      productPrice: (json['productPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      selectedOptions: (json['selectedOptions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      productImageUrl: json['productImageUrl'] as String?,
    );

Map<String, dynamic> _$CartItemDTOToJson(CartItemDTO instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productNameAr': instance.productNameAr,
      'productPrice': instance.productPrice,
      'quantity': instance.quantity,
      'selectedOptions': instance.selectedOptions,
      'productImageUrl': instance.productImageUrl,
    };
