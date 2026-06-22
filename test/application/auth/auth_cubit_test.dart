import 'dart:async';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse;
import 'package:tarwi2a/application/auth/auth_cubit.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import 'package:tarwi2a/domain/entities/user_profile.dart';
import '../../helpers/test_helpers.dart';

class MockSupabaseAuthState extends Mock implements supabase.AuthState {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockProfileRepository mockProfileRepo;
  late MockUser mockUser;
  late MockAuthResponse mockAuthResponse;
  late MockSession mockSession;
  late AuthCubit cubit;

  setUpAll(() {
    registerFallbackValue(MockUser());
    registerFallbackValue(MockAuthResponse());
    registerFallbackValue(MockSession());
    registerFallbackValue(MockSupabaseAuthState());
    registerFallbackValue(right<Failure, AuthResponse>(MockAuthResponse()));
    registerFallbackValue(right<Failure, void>(null));
    registerFallbackValue(right<Failure, UserProfile?>(testUserProfile));
    registerFallbackValue(left<Failure, UserProfile?>(testServerFailure));
    registerFallbackValue(left<Failure, AuthResponse>(testServerFailure));
  });

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockProfileRepo = MockProfileRepository();
    mockUser = MockUser();
    mockAuthResponse = MockAuthResponse();
    mockSession = MockSession();

    when(() => mockUser.id).thenReturn('user-123');
    when(() => mockSession.user).thenReturn(mockUser);
  });

  AuthCubit createCubit() {
    return AuthCubit(
      authRepository: mockAuthRepo,
      profileRepository: mockProfileRepo,
    );
  }

  group('AuthCubit', () {
    group('initial state', () {
      test('emits AuthInitial on creation', () {
        cubit = createCubit();
        expect(cubit.state, const AuthState.initial());
      });
    });

    group('checkAuthStatus - no user', () {
      test('emits Unauthenticated when currentUser is null', () {
        when(() => mockAuthRepo.currentUser).thenReturn(null);
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => const Stream.empty());

        cubit = createCubit();
        cubit.checkAuthStatus();

        expect(cubit.state, const AuthState.unauthenticated());
      });
    });

    group('checkAuthStatus - user with profile', () {
      test('emits Loading then Authenticated when profile is found', () async {
        when(() => mockAuthRepo.currentUser).thenReturn(mockUser);
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockProfileRepo.getProfile('user-123'))
            .thenAnswer((_) async => right(testUserProfile));

        cubit = createCubit();
        final states = <AuthState>[];
        cubit.stream.listen(states.add);

        cubit.checkAuthStatus();
        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, contains(const AuthState.loading()));
        expect(states.last, AuthState.authenticated(testUserProfile));
      });
    });

    group('checkAuthStatus - user without profile', () {
      test('emits Loading then Unauthenticated when profile is null', () async {
        when(() => mockAuthRepo.currentUser).thenReturn(mockUser);
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockProfileRepo.getProfile('user-123'))
            .thenAnswer((_) async => right(null));

        cubit = createCubit();
        final states = <AuthState>[];
        cubit.stream.listen(states.add);

        cubit.checkAuthStatus();
        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, contains(const AuthState.loading()));
        expect(states.last, const AuthState.unauthenticated());
      });
    });

    group('checkAuthStatus - profile error', () {
      test('emits Loading then AuthError when profile fetch fails', () async {
        when(() => mockAuthRepo.currentUser).thenReturn(mockUser);
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockProfileRepo.getProfile('user-123'))
            .thenAnswer((_) async => left(testServerFailure));

        cubit = createCubit();
        final states = <AuthState>[];
        cubit.stream.listen(states.add);

        cubit.checkAuthStatus();
        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, contains(const AuthState.loading()));
        expect(states.last, const AuthState.error(testServerFailure));
      });
    });

    group('signIn', () {
      test('emits Loading and delegates to repository', () async {
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockAuthRepo.currentUser).thenReturn(null);
        when(() => mockAuthRepo.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => right(mockAuthResponse));

        cubit = createCubit();
        await cubit.signIn(email: 'test@test.com', password: '123456');

        expect(cubit.state, const AuthState.loading());
        verify(() => mockAuthRepo.signIn(
              email: 'test@test.com',
              password: '123456',
            )).called(1);
      });

      test('emits AuthError when signIn fails', () async {
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockAuthRepo.currentUser).thenReturn(null);
        when(() => mockAuthRepo.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => left(testServerFailure));

        cubit = createCubit();
        await cubit.signIn(email: 'test@test.com', password: '123456');

        expect(cubit.state, const AuthState.error(testServerFailure));
      });
    });

    group('signUp', () {
      test('emits Loading and delegates to repository', () async {
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockAuthRepo.currentUser).thenReturn(null);
        when(() => mockAuthRepo.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
              role: any(named: 'role'),
            )).thenAnswer((_) async => right(mockAuthResponse));

        cubit = createCubit();
        await cubit.signUp(
            email: 'test@test.com', password: '123456', name: 'محمد');

        expect(cubit.state, const AuthState.loading());
        verify(() => mockAuthRepo.signUp(
              email: 'test@test.com',
              password: '123456',
              name: 'محمد',
              role: 'customer',
            )).called(1);
      });

      test('emits AuthError when signUp fails', () async {
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockAuthRepo.currentUser).thenReturn(null);
        when(() => mockAuthRepo.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
              role: any(named: 'role'),
            )).thenAnswer((_) async => left(testServerFailure));

        cubit = createCubit();
        await cubit.signUp(
            email: 'test@test.com', password: '123456', name: 'محمد');

        expect(cubit.state, const AuthState.error(testServerFailure));
      });
    });

    group('signOut', () {
      test('delegates signOut to repository and returns Right on success',
          () async {
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockAuthRepo.currentUser).thenReturn(null);
        when(() => mockAuthRepo.signOut())
            .thenAnswer((_) async => right<Failure, void>(null));

        cubit = createCubit();
        final result = await cubit.signOut();

        verify(() => mockAuthRepo.signOut()).called(1);
        expect(result.isRight(), true);
      });

      test('returns Left on signOut failure', () async {
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockAuthRepo.currentUser).thenReturn(null);
        when(() => mockAuthRepo.signOut()).thenAnswer((_) async =>
            left<Failure, void>(const Failure.unexpected(message: 'fail')));

        cubit = createCubit();
        final result = await cubit.signOut();

        verify(() => mockAuthRepo.signOut()).called(1);
        expect(result.isLeft(), true);
      });
    });

    group('authStateChanges listener', () {
      test('emits unauthenticated on signedOut event', () async {
        final controller = StreamController<supabase.AuthState>.broadcast();
        when(() => mockAuthRepo.currentUser).thenReturn(null);
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => controller.stream);

        cubit = createCubit();
        cubit.checkAuthStatus();

        final signedOutState = MockSupabaseAuthState();
        when(() => signedOutState.event)
            .thenReturn(supabase.AuthChangeEvent.signedOut);
        when(() => signedOutState.session).thenReturn(null);

        controller.add(signedOutState);

        await Future.delayed(Duration.zero);

        expect(cubit.state, const AuthState.unauthenticated());

        await controller.close();
      });

      test('fetches profile on signedIn event', () async {
        final controller = StreamController<supabase.AuthState>.broadcast();

        when(() => mockAuthRepo.currentUser).thenReturn(null);
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => controller.stream);
        when(() => mockProfileRepo.getProfile('user-123'))
            .thenAnswer((_) async => right(testUserProfile));

        cubit = createCubit();
        cubit.checkAuthStatus();

        final signedInState = MockSupabaseAuthState();
        when(() => signedInState.event)
            .thenReturn(supabase.AuthChangeEvent.signedIn);
        when(() => signedInState.session).thenReturn(mockSession);

        controller.add(signedInState);

        await expectLater(
          cubit.stream,
          emitsInOrder([
            const AuthState.loading(),
            AuthState.authenticated(testUserProfile),
          ]),
        );

        await controller.close();
      });
    });
  });
}
