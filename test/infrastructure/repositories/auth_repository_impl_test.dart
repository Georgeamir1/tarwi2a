import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException;
import 'package:matbakhy/domain/failures/failure.dart';
import 'package:matbakhy/infrastructure/repositories/auth_repository_impl.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late AuthRepositoryImpl repository;
  late MockAuthResponse mockAuthResponse;

  setUpAll(() {
    registerFallbackValue(MockAuthResponse());
    registerFallbackValue(MockUser());
  });

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    mockAuthResponse = MockAuthResponse();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  group('AuthRepositoryImpl', () {
    group('signUp', () {
      test('returns Right(AuthResponse) on success', () async {
        when(() => mockDataSource.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
              role: any(named: 'role'),
            )).thenAnswer((_) async => mockAuthResponse);

        final result = await repository.signUp(
          email: 'test@test.com',
          password: '123456',
          name: 'محمد',
        );

        expect(result.isRight(), isTrue);
      });

      test('returns Left(ServerFailure) on AuthException', () async {
        when(() => mockDataSource.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
              role: any(named: 'role'),
            )).thenThrow(const AuthException('error'));

        final result = await repository.signUp(
          email: 'test@test.com',
          password: '123456',
          name: 'محمد',
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(UnexpectedFailure) on generic Exception', () async {
        when(() => mockDataSource.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
              role: any(named: 'role'),
            )).thenThrow(Exception('network error'));

        final result = await repository.signUp(
          email: 'test@test.com',
          password: '123456',
          name: 'محمد',
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<UnexpectedFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('signIn', () {
      test('returns Right(AuthResponse) on success', () async {
        when(() => mockDataSource.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockAuthResponse);

        final result = await repository.signIn(
          email: 'test@test.com',
          password: '123456',
        );

        expect(result.isRight(), isTrue);
      });

      test('returns Left(ServerFailure) on AuthException', () async {
        when(() => mockDataSource.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(const AuthException('invalid'));

        final result = await repository.signIn(
          email: 'test@test.com',
          password: 'wrong',
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('signOut', () {
      test('returns Right(void) on success', () async {
        when(() => mockDataSource.signOut()).thenAnswer((_) async => {});

        final result = await repository.signOut();

        expect(result.isRight(), isTrue);
      });

      test('returns Left(UnexpectedFailure) on Exception', () async {
        when(() => mockDataSource.signOut())
            .thenThrow(Exception('sign out failed'));

        final result = await repository.signOut();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<UnexpectedFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('currentUser', () {
      test('delegates to data source', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('test-id');
        when(() => mockDataSource.currentUser).thenReturn(mockUser);
        expect(repository.currentUser, mockUser);
      });

      test('returns null when data source returns null', () {
        when(() => mockDataSource.currentUser).thenReturn(null);
        expect(repository.currentUser, isNull);
      });
    });
  });
}
