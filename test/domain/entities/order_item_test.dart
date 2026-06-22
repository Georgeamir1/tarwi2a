import 'package:flutter_test/flutter_test.dart';
import 'package:tarwi2a/domain/entities/order_item.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('OrderItem', () {
    test('two order items with same fields are equal', () {
      const a = testOrderItem;
      const b = OrderItem(
        id: 'oi-1',
        orderId: 'order-1',
        productId: 'prod-1',
        productName: 'مارجريتا',
        productPrice: 75.0,
        quantity: 2,
        subtotal: 150.0,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith changes a field', () {
      final updated = testOrderItem.copyWith(quantity: 3, subtotal: 225.0);

      expect(updated.quantity, 3);
      expect(updated.subtotal, 225.0);
      expect(updated.id, testOrderItem.id);
      expect(updated.productName, testOrderItem.productName);
    });

    test('props are accessible', () {
      expect(testOrderItem.id, 'oi-1');
      expect(testOrderItem.orderId, 'order-1');
      expect(testOrderItem.productName, 'مارجريتا');
      expect(testOrderItem.productPrice, 75.0);
      expect(testOrderItem.quantity, 2);
      expect(testOrderItem.subtotal, 150.0);
    });
  });
}
