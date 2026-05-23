import 'package:flutter_test/flutter_test.dart';
import 'package:matbakhy/domain/entities/order.dart';
import 'package:matbakhy/domain/entities/order_item.dart';
import 'package:matbakhy/domain/enums/order_status.dart';
import 'package:matbakhy/domain/enums/payment_method.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('Order', () {
    test('two orders with same fields and items list are equal', () {
      final a = testOrder;
      final b = Order(
        id: 'order-1',
        customerId: 'user-123',
        customerName: 'محمد',
        customerPhone: '01001234567',
        customerAddress: 'القاهرة',
        notes: 'بدون بصل',
        paymentMethod: PaymentMethod.cash,
        status: OrderStatus.pending,
        totalAmount: 150.0,
        createdAt: DateTime(2026, 5, 1, 10, 0),
        updatedAt: DateTime(2026, 5, 1, 10, 0),
        items: [
          const OrderItem(
            id: 'oi-1',
            orderId: 'order-1',
            productId: 'prod-1',
            productName: 'مارجريتا',
            productPrice: 75.0,
            quantity: 2,
            subtotal: 150.0,
          ),
        ],
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith changes a field', () {
      final updated = testOrder.copyWith(status: OrderStatus.confirmed);

      expect(updated.status, OrderStatus.confirmed);
      expect(updated.id, testOrder.id);
      expect(updated.totalAmount, testOrder.totalAmount);
    });

    test('props are accessible', () {
      expect(testOrder.id, 'order-1');
      expect(testOrder.customerName, 'محمد');
      expect(testOrder.status, OrderStatus.pending);
      expect(testOrder.paymentMethod, PaymentMethod.cash);
      expect(testOrder.totalAmount, 150.0);
      expect(testOrder.items.length, 1);
    });
  });
}
