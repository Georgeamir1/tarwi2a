import 'package:flutter_test/flutter_test.dart';
import 'package:matbakhy/domain/enums/order_status.dart';

void main() {
  group('OrderStatus', () {
    group('fromString', () {
      test('returns pending for "pending"', () {
        expect(OrderStatus.fromString('pending'), OrderStatus.pending);
      });

      test('returns confirmed for "confirmed"', () {
        expect(OrderStatus.fromString('confirmed'), OrderStatus.confirmed);
      });

      test('returns preparing for "preparing"', () {
        expect(OrderStatus.fromString('preparing'), OrderStatus.preparing);
      });

      test('returns ready for "ready"', () {
        expect(OrderStatus.fromString('ready'), OrderStatus.ready);
      });

      test('returns delivered for "delivered"', () {
        expect(OrderStatus.fromString('delivered'), OrderStatus.delivered);
      });

      test('returns cancelled for "cancelled"', () {
        expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
      });

      test('returns pending for unknown string', () {
        expect(OrderStatus.fromString('garbage'), OrderStatus.pending);
      });
    });

    group('value', () {
      test('each value matches the expected string', () {
        expect(OrderStatus.pending.value, 'pending');
        expect(OrderStatus.confirmed.value, 'confirmed');
        expect(OrderStatus.preparing.value, 'preparing');
        expect(OrderStatus.ready.value, 'ready');
        expect(OrderStatus.delivered.value, 'delivered');
        expect(OrderStatus.cancelled.value, 'cancelled');
      });
    });
  });
}
