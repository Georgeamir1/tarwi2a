import 'package:flutter_test/flutter_test.dart';
import 'package:tarwi2a/application/auth/auth_cubit.dart';
import 'package:tarwi2a/domain/entities/user_profile.dart';
import 'package:tarwi2a/domain/enums/user_role.dart';
import 'package:tarwi2a/domain/failures/failure.dart';

void main() {
  final testProfile = UserProfile(
    id: 'user-1',
    name: 'محمد',
    role: UserRole.customer,
    createdAt: DateTime(2026, 1, 1),
  );

  const testFailure = Failure.server(message: 'error');

  group('AuthState', () {
    test('AuthInitial props are empty', () {
      const state = AuthState.initial();
      expect(state.props, isEmpty);
      expect(state, isA<AuthInitial>());
      expect(state, isA<AuthState>());
    });

    test('AuthLoading props are empty', () {
      const state = AuthState.loading();
      expect(state.props, isEmpty);
      expect(state, isA<AuthLoading>());
      expect(state, isA<AuthState>());
    });

    test('Authenticated contains profile', () {
      final state = AuthState.authenticated(testProfile);
      expect(state, isA<Authenticated>());
      expect(state.props, [testProfile]);
    });

    test('Unauthenticated props are empty', () {
      const state = AuthState.unauthenticated();
      expect(state.props, isEmpty);
      expect(state, isA<Unauthenticated>());
      expect(state, isA<AuthState>());
    });

    test('AuthError contains failure', () {
      const state = AuthState.error(testFailure);
      expect(state, isA<AuthError>());
      expect(state.props, [testFailure]);
    });

    test('factory constructors produce correct subtypes', () {
      expect(const AuthState.initial(), isA<AuthInitial>());
      expect(const AuthState.loading(), isA<AuthLoading>());
      expect(AuthState.authenticated(testProfile), isA<Authenticated>());
      expect(const AuthState.unauthenticated(), isA<Unauthenticated>());
      expect(const AuthState.error(testFailure), isA<AuthError>());
    });
  });
}
