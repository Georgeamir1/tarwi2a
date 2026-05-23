import 'package:flutter_test/flutter_test.dart';
import 'package:matbakhy/domain/entities/user_profile.dart';
import 'package:matbakhy/domain/enums/user_role.dart';

void main() {
  final profile = UserProfile(
    id: 'user-1',
    name: 'محمد',
    phone: '01001234567',
    role: UserRole.customer,
    createdAt: DateTime(2026, 1, 1),
  );

  group('UserProfile', () {
    test('equals with same fields returns true', () {
      final other = UserProfile(
        id: 'user-1',
        name: 'محمد',
        phone: '01001234567',
        role: UserRole.customer,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(profile, other);
    });

    test('not equal when any field differs', () {
      final other = profile.copyWith(id: 'different');
      expect(profile, isNot(other));
    });

    test('copyWith creates new instance with updated field', () {
      final updated = profile.copyWith(name: 'أحمد');
      expect(updated.name, 'أحمد');
      expect(updated.id, 'user-1');
    });

    test('props are accessible', () {
      expect(profile.id, 'user-1');
      expect(profile.name, 'محمد');
      expect(profile.phone, '01001234567');
      expect(profile.role, UserRole.customer);
      expect(profile.createdAt, DateTime(2026, 1, 1));
    });
  });
}
