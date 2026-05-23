import 'package:flutter_test/flutter_test.dart';
import 'package:matbakhy/domain/enums/payment_method.dart';

void main() {
  group('PaymentMethod', () {
    group('fromString', () {
      test('returns cash for "cash"', () {
        expect(PaymentMethod.fromString('cash'), PaymentMethod.cash);
      });

      test('returns wallet for "wallet"', () {
        expect(PaymentMethod.fromString('wallet'), PaymentMethod.wallet);
      });

      test('returns instapay for "instapay"', () {
        expect(PaymentMethod.fromString('instapay'), PaymentMethod.instapay);
      });

      test('returns cash for unknown string', () {
        expect(PaymentMethod.fromString('unknown'), PaymentMethod.cash);
      });
    });

    group('value', () {
      test('each value matches the expected string', () {
        expect(PaymentMethod.cash.value, 'cash');
        expect(PaymentMethod.wallet.value, 'wallet');
        expect(PaymentMethod.instapay.value, 'instapay');
      });
    });
  });
}
