import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/core/services/notification_navigation_resolver.dart';
import 'package:tarwi2a/domain/entities/user_profile.dart';
import 'package:tarwi2a/domain/enums/user_role.dart';
import 'package:tarwi2a/domain/repositories/profile_repository.dart';
import '../../helpers/test_helpers.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockProfileRepository mockProfileRepo;
  late NotificationNavigationResolver resolver;

  final testCustomerProfile = UserProfile(
    id: 'user-cust-1',
    name: 'عميل',
    phone: '01012345678',
    role: UserRole.customer,
    createdAt: DateTime(2026),
  );

  final testAdminProfile = UserProfile(
    id: 'user-admin-1',
    name: 'مدير',
    phone: '01098765432',
    role: UserRole.admin,
    createdAt: DateTime(2026),
  );

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockProfileRepo = MockProfileRepository();
    resolver = NotificationNavigationResolver(
      authRepository: mockAuthRepo,
      profileRepository: mockProfileRepo,
    );
  });

  group('NotificationNavigationResolver', () {
    test('resolves to /orders?expand=id for authenticated customer', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-cust-1');
      when(() => mockAuthRepo.currentUser).thenReturn(mockUser);
      when(() => mockProfileRepo.getProfile('user-cust-1'))
          .thenAnswer((_) async => right(testCustomerProfile));

      final route = await resolver.resolveRoute({
        'reference_type': 'order',
        'reference_id': 'ord-456',
      });

      expect(route, equals('/orders?expand=ord-456'));
    });

    test('resolves to /admin/orders/id for authenticated admin', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-admin-1');
      when(() => mockAuthRepo.currentUser).thenReturn(mockUser);
      when(() => mockProfileRepo.getProfile('user-admin-1'))
          .thenAnswer((_) async => right(testAdminProfile));

      final route = await resolver.resolveRoute({
        'reference_type': 'order',
        'reference_id': 'ord-456',
      });

      expect(route, equals('/admin/orders/ord-456'));
    });

    test('ignores spoofed admin claims in notification payload', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-cust-1');
      when(() => mockAuthRepo.currentUser).thenReturn(mockUser);
      when(() => mockProfileRepo.getProfile('user-cust-1'))
          .thenAnswer((_) async => right(testCustomerProfile));

      // Payload malicious claim: is_admin = true, role = 'admin'
      final route = await resolver.resolveRoute({
        'reference_type': 'order',
        'reference_id': 'ord-456',
        'is_admin': true,
        'role': 'admin',
        'admin': true,
      });

      // Role is derived from verified profile ONLY, resulting in customer route
      expect(route, equals('/orders?expand=ord-456'));
    });

    test('returns null when user is unauthenticated', () async {
      when(() => mockAuthRepo.currentUser).thenReturn(null);

      final route = await resolver.resolveRoute({
        'reference_type': 'order',
        'reference_id': 'ord-456',
      });

      expect(route, isNull);
      verifyNever(() => mockProfileRepo.getProfile(any()));
    });

    test('returns null when reference_id is missing or empty', () async {
      final mockUser = MockUser();
      when(() => mockAuthRepo.currentUser).thenReturn(mockUser);

      final route1 = await resolver.resolveRoute({
        'reference_type': 'order',
      });
      final route2 = await resolver.resolveRoute({
        'reference_type': 'order',
        'reference_id': '   ',
      });

      expect(route1, isNull);
      expect(route2, isNull);
    });

    test('returns null when reference_type is unsupported', () async {
      final mockUser = MockUser();
      when(() => mockAuthRepo.currentUser).thenReturn(mockUser);

      final route = await resolver.resolveRoute({
        'reference_type': 'unknown_type',
        'reference_id': '123',
      });

      expect(route, isNull);
    });
  });
}
