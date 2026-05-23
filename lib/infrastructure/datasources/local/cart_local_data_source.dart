import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dtos/cart_item_dto.dart';

class CartLocalDataSource {
  static const _cartKey = 'cart_items';

  Future<List<CartItemDTO>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson == null) return [];

    final List<dynamic> decoded = jsonDecode(cartJson);
    return decoded
        .map((item) => CartItemDTO.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCart(List<CartItemDTO> items) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
  }
}
