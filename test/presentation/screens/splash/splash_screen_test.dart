import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse;

import 'package:matbakhy/presentation/screens/splash/splash_screen.dart';
import 'package:matbakhy/application/auth/auth_cubit.dart';
import 'package:matbakhy/domain/entities/user_profile.dart';
import 'package:matbakhy/domain/failures/failure.dart';
import 'package:matbakhy/core/constants/app_constants.dart';
import '../../../helpers/test_helpers.dart';

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const Placeholder()),
      GoRoute(path: '/home', builder: (_, __) => const Placeholder()),
      GoRoute(path: '/admin', builder: (_, __) => const Placeholder()),
    ],
  );
}

Widget _buildTestWidget(AuthCubit cubit) {
  return MaterialApp.router(
    routerConfig: _createRouter(),
    builder: (context, child) => BlocProvider<AuthCubit>.value(
      value: cubit,
      child: child ?? const SizedBox.shrink(),
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
    when(() => mockCubit.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());
  });

  group('SplashScreen', () {
    group('render', () {
      testWidgets('shows app logo and name', (tester) async {
        when(() => mockCubit.state)
            .thenReturn(const AuthState.unauthenticated());

        await tester.pumpWidget(_buildTestWidget(mockCubit));
        await tester.pump();

        expect(find.byIcon(Icons.restaurant_menu_rounded), findsOneWidget);
        expect(find.text(AppConstants.appName), findsOneWidget);
        expect(
          find.text('أطيب الأكلات على بابك'),
          findsOneWidget,
        );

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
      });

      testWidgets('shows CircularProgressIndicator', (tester) async {
        when(() => mockCubit.state)
            .thenReturn(const AuthState.unauthenticated());

        await tester.pumpWidget(_buildTestWidget(mockCubit));
        await tester.pump();

        expect(
          find.byWidgetPredicate(
            (w) => w is LinearProgressIndicator,
          ),
          findsOneWidget,
        );

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
      });
    });

    group('authenticated state', () {
      testWidgets('renders correctly when user is authenticated as customer',
          (tester) async {
        when(() => mockCubit.state)
            .thenReturn(AuthState.authenticated(testUserProfile));

        await tester.pumpWidget(_buildTestWidget(mockCubit));
        await tester.pump();

        expect(find.byIcon(Icons.restaurant_menu_rounded), findsOneWidget);
        expect(find.text(AppConstants.appName), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
      });
    });
  });
}
