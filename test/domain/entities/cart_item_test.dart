import 'package:flutter_test/flutter_test.dart';
import 'package:matbakhy/domain/entities/cart_item.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('CartItem', () {
    test('two cart items with same fields are equal', () {
      const a = testCartItem;
      const b = CartItem(
        productId: 'prod-1',
        productNameAr: 'مارجريتا',
        productPrice: 75.0,
        quantity: 2,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith changes a field', () {
      final updated = testCartItem.copyWith(quantity: 5);

      expect(updated.quantity, 5);
      expect(updated.productId, testCartItem.productId);
      expect(updated.productPrice, testCartItem.productPrice);
    });

    test('subtotal equals productPrice * quantity', () {
      const item = CartItem(
        productId: 'prod-99',
        productNameAr: 'بيتزا',
        productPrice: 60.0,
        quantity: 3,
      );

      expect(item.subtotal, 180.0);
    });
  });
}
