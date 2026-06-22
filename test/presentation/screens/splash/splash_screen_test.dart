import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse;

import 'package:tarwi2a/presentation/screens/splash/splash_screen.dart';
import 'package:tarwi2a/application/auth/auth_cubit.dart';
import 'package:tarwi2a/domain/entities/user_profile.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import 'package:tarwi2a/core/constants/app_constants.dart';
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
      testWidgets('shows logo asset and no texts', (tester) async {
        when(() => mockCubit.state)
            .thenReturn(const AuthState.unauthenticated());

        await tester.pumpWidget(_buildTestWidget(mockCubit));
        await tester.pump();

        // Should find the asset logo image
        final imageFinder = find.byType(Image);
        expect(imageFinder, findsOneWidget);
        final image = tester.widget<Image>(imageFinder);
        expect((image.image as AssetImage).assetName, 'assets/images/splash_logo-removebg-preview.png');

        // Should NOT find app name, tagline, or loader texts
        expect(find.text(AppConstants.appName), findsNothing);
        expect(find.text('أطيب الأكلات على بابك'), findsNothing);
        expect(find.text('جاري التحميل للتذوق...'), findsNothing);
        expect(find.byIcon(Icons.restaurant_menu_rounded), findsNothing);

        await tester.pump(const Duration(seconds: 4));
      });
    });

    group('authenticated state', () {
      testWidgets('renders logo correctly when user is authenticated as customer',
          (tester) async {
        when(() => mockCubit.state)
            .thenReturn(AuthState.authenticated(testUserProfile));

        await tester.pumpWidget(_buildTestWidget(mockCubit));
        await tester.pump();

        // Should show the logo
        final imageFinder = find.byType(Image);
        expect(imageFinder, findsOneWidget);
        final image = tester.widget<Image>(imageFinder);
        expect((image.image as AssetImage).assetName, 'assets/images/splash_logo-removebg-preview.png');

        // Should NOT show old widgets
        expect(find.text(AppConstants.appName), findsNothing);

        await tester.pump(const Duration(seconds: 4));
      });
    });
  });
}
