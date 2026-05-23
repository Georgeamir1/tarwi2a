import 'package:flutter/material.dart';

enum OrderType {
  delivery('delivery'),
  pickup('pickup'),
  dineIn('dine_in');

  final String value;
  const OrderType(this.value);

  factory OrderType.fromString(String type) {
    return OrderType.values.firstWhere(
      (t) => t.value == type,
      orElse: () => OrderType.delivery,
    );
  }
}

extension OrderTypeX on OrderType {
  String get arabicLabel {
    switch (this) {
      case OrderType.delivery:
        return 'توصيل';
      case OrderType.pickup:
        return 'استلام من الفرع';
      case OrderType.dineIn:
        return 'تناول في المطعم';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderType.delivery:
        return Icons.delivery_dining_outlined;
      case OrderType.pickup:
        return Icons.storefront_outlined;
      case OrderType.dineIn:
        return Icons.restaurant_outlined;
    }
  }
}
