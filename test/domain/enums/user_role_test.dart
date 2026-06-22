import 'package:flutter_test/flutter_test.dart';
import 'package:tarwi2a/domain/enums/user_role.dart';

void main() {
  group('UserRole', () {
    group('factory fromString', () {
      test('returns admin for "admin"', () {
        expect(UserRole.fromString('admin'), UserRole.admin);
      });

      test('returns customer for "customer"', () {
        expect(UserRole.fromString('customer'), UserRole.customer);
      });

      test('returns customer for unknown role', () {
        expect(UserRole.fromString('garbage'), UserRole.customer);
        expect(UserRole.fromString(''), UserRole.customer);
      });
    });

    group('value property', () {
      test('admin value is "admin"', () {
        expect(UserRole.admin.value, 'admin');
      });

      test('customer value is "customer"', () {
        expect(UserRole.customer.value, 'customer');
      });
    });

    group('isAdmin', () {
      test('admin returns true', () {
        expect(UserRole.admin.isAdmin, isTrue);
      });

      test('customer returns false', () {
        expect(UserRole.customer.isAdmin, isFalse);
      });
    });
  });
}
