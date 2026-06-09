import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse;

import 'package:matbakhy/presentation/screens/auth/register_screen.dart';
import 'package:matbakhy/application/auth/auth_cubit.dart';
import 'package:matbakhy/domain/entities/user_profile.dart';
import 'package:matbakhy/domain/failures/failure.dart';
import 'package:matbakhy/presentation/widgets/error_banner.dart';
import '../../../helpers/test_helpers.dart';

Widget _buildTestWidget(AuthCubit cubit) {
  return MaterialApp(
    home: BlocProvider<AuthCubit>.value(
      value: cubit,
      child: const RegisterScreen(),
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

  group('RegisterScreen', () {
    group('render', () {
      testWidgets(
          'shows name, email, password fields, register button, and back button',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockCubit));
        await tester.pumpAndSettle();

        expect(find.text('إنشاء الحساب'), findsOneWidget);
        expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
        expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
        expect(find.byIcon(Icons.email_outlined), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(4));
      });
    });

    group('form validation', () {
      testWidgets('shows validation errors when submitting empty form',
          (tester) async {
        when(() => mockCubit.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
              role: any(named: 'role'),
            )).thenAnswer((_) async {});

        await tester.pumpWidget(_buildTestWidget(mockCubit));
        await tester.pump();

        await tester.tap(find.text('إنشاء الحساب'));
        await tester.pump();

        expect(find.text('أدخل اسمك'), findsOneWidget);
        expect(find.text('أدخل البريد الإلكتروني'), findsOneWidget);
        expect(find.text('أدخل كلمة المرور'), findsOneWidget);
      });
    });

    group('loading state', () {
      testWidgets(
          'shows CircularProgressIndicator when registration is in progress',
          (tester) async {
        when(() => mockCubit.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
              role: any(named: 'role'),
            )).thenAnswer((_) async {});

        await tester.pumpWidget(_buildTestWidget(mockCubit));
        await tester.pump();

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'محمد',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'test@test.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(3),
          '123456',
        );
        await tester.pump();

        await tester.tap(find.text('إنشاء الحساب'));
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
        when(() => mockAuthRepo.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
              role: any(named: 'role'),
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
          'محمد',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'test@test.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(3),
          '123456',
        );
        await tester.pump();

        await tester.tap(find.text('إنشاء الحساب'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(ErrorBanner), findsOneWidget);
        expect(
          find.text('حصل خطأ أثناء التسجيل، حاول تاني'),
          findsOneWidget,
        );
      });
    });

    group('calls signUp', () {
      testWidgets('calls cubit.signUp with correct name, email, and password',
          (tester) async {
        when(() => mockCubit.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
              role: any(named: 'role'),
            )).thenAnswer((_) async {});

        await tester.pumpWidget(_buildTestWidget(mockCubit));
        await tester.pump();

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'محمد',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'user@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(3),
          'mypassword',
        );
        await tester.pump();

        await tester.tap(find.text('إنشاء الحساب'));
        await tester.pump();

        verify(() => mockCubit.signUp(
              email: 'user@example.com',
              password: 'mypassword',
              name: 'محمد',
              role: 'customer',
            )).called(1);
      });
    });
  });
}
