import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse;

import 'package:tarwi2a/presentation/screens/auth/login_screen.dart';
import 'package:tarwi2a/application/auth/auth_cubit.dart';
import 'package:tarwi2a/domain/entities/user_profile.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import 'package:tarwi2a/presentation/widgets/error_banner.dart';
import '../../../helpers/test_helpers.dart';

Widget _buildTestWidget(AuthCubit cubit) {
  return MaterialApp(
    home: BlocProvider<AuthCubit>.value(
      value: cubit,
      child: const LoginScreen(),
    ),
  );
}

void main() {
  late MockAuthCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(MockUser());
    registerFallbackValue(MockAuthResponse());
    registerFallbackValue(MockSession());
    registerFallbackValue(
      left<Failure, AuthResponse>(testServerFailure),
    );
    registerFallbackValue(
      right<Failure, AuthResponse>(MockAuthResponse()),
    );
    registerFallbackValue(
      right<Failure, void>(null),
    );
    registerFallbackValue(
      right<Failure, UserProfile?>(testUserProfile),
    );
  });

  setUp(() {
    mockCubit = MockAuthCubit();
    when(() => mockCubit.state).thenReturn(const AuthState.initial());
    when(() => mockCubit.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());

    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    if (binding.platformDispatcher.views.isNotEmpty) {
      final view = binding.platformDispatcher.views.first;
      if (view is TestFlutterView) {
        view.physicalSize = const Size(800, 1200);
        view.devicePixelRatio = 1.0;
      }
    }
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    if (binding.platformDispatcher.views.isNotEmpty) {
      final view = binding.platformDispatcher.views.first;
      if (view is TestFlutterView) {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      }
    }
  });

  group('LoginScreen', () {
    group('render', () {
      testWidgets(
          'shows email field, password field, login button, and register link',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockCubit));
        // Use pump() instead of pumpAndSettle() because LoginScreen has
        // endless ambient background animations.
        await tester.pump();

        expect(find.text('تسجيل الدخول'), findsOneWidget);
        expect(find.byIcon(Icons.email_outlined), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
        expect(find.text('سجّل دلوقتي'), findsOneWidget);
      });
    });

    group('form validation', () {
      testWidgets('shows validation errors when submitting empty form',
          (tester) async {
        when(() => mockCubit.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async {});

        await tester.pumpWidget(_buildTestWidget(mockCubit));
        await tester.pump();

        await tester.tap(find.text('تسجيل الدخول'));
        await tester.pump();

        expect(find.text('أدخل البريد الإلكتروني'), findsOneWidget);
        expect(find.text('أدخل كلمة المرور'), findsOneWidget);
      });
    });

    group('loading state', () {
      testWidgets('shows CircularProgressIndicator when login is in progress',
          (tester) async {
        when(() => mockCubit.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async {});

        await tester.pumpWidget(_buildTestWidget(mockCubit));
        await tester.pump();

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'test@test.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          '123456',
        );
        await tester.pump();

        await tester.tap(find.text('تسجيل الدخول'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('error state', () {
      testWidgets('shows ErrorBanner when AuthError is emitted',
          (tester) async {
        final mockAuthRepo = MockAuthRepository();
        final mockProfileRepo = MockProfileRepository();

        when(() => mockAuthRepo.currentUser).thenReturn(null);
        when(() => mockAuthRepo.authStateChanges)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockAuthRepo.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => left(testServerFailure));

        final cubit = AuthCubit(
          authRepository: mockAuthRepo,
          profileRepository: mockProfileRepo,
        );
        addTearDown(() => cubit.close());

        await tester.pumpWidget(_buildTestWidget(cubit));
        await tester.pump();

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'test@test.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'wrongpassword',
        );
        await tester.pump();

        await tester.tap(find.text('تسجيل الدخول'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(ErrorBanner), findsOneWidget);
        expect(
          find.text('البريد الإلكتروني أو كلمة المرور غير صحيحة'),
          findsOneWidget,
        );
      });
    });

    group('calls signIn', () {
      testWidgets('calls cubit.signIn with correct email and password',
          (tester) async {
        when(() => mockCubit.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async {});

        await tester.pumpWidget(_buildTestWidget(mockCubit));
        await tester.pump();

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'user@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'mypassword',
        );
        await tester.pump();

        await tester.tap(find.text('تسجيل الدخول'));
        await tester.pump();

        verify(() => mockCubit.signIn(
              email: 'user@example.com',
              password: 'mypassword',
            )).called(1);
      });
    });
  });
}
