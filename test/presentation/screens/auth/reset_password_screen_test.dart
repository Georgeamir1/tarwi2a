import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:go_router/go_router.dart';

import 'package:tarwi2a/presentation/screens/auth/reset_password_screen.dart';
import 'package:tarwi2a/application/auth/auth_cubit.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import 'package:tarwi2a/app/theme/app_theme.dart';
import '../../../helpers/test_helpers.dart';

Widget _buildTestWidget(AuthCubit authCubit) {
  final router = GoRouter(
    initialLocation: '/reset-password',
    routes: [
      GoRoute(
        path: '/reset-password',
        builder: (_, __) => BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: const ResetPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const Scaffold(body: Text('Login Screen')),
      ),
    ],
  );

  return MaterialApp.router(
    theme: AppTheme.light,
    routerConfig: router,
  );
}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state)
        .thenReturn(const AuthState.recoveryRequired());
    when(() => mockAuthCubit.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => mockAuthCubit.close()).thenAnswer((_) async {});
  });

  group('ResetPasswordScreen', () {
    testWidgets('renders all fields and submit button', (tester) async {
      await tester.pumpWidget(_buildTestWidget(mockAuthCubit));
      await tester.pumpAndSettle();

      expect(find.text('تعيين كلمة المرور الجديدة'), findsOneWidget);
      expect(find.text('أدخل كلمة المرور الجديدة'), findsOneWidget);
      expect(find.text('حفظ كلمة المرور'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('shows validation error when password is less than 6 chars',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(mockAuthCubit));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'كلمة المرور الجديدة'), '123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'تأكيد كلمة المرور'), '123');

      await tester.tap(find.text('حفظ كلمة المرور'));
      await tester.pumpAndSettle();

      expect(find.text('كلمة المرور يجب ألا تقل عن 6 أحرف'), findsOneWidget);
      verifyNever(() => mockAuthCubit.updatePassword(any()));
    });

    testWidgets('shows validation error when passwords do not match',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(mockAuthCubit));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'كلمة المرور الجديدة'), '123456');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'تأكيد كلمة المرور'), '654321');

      await tester.tap(find.text('حفظ كلمة المرور'));
      await tester.pumpAndSettle();

      expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
      verifyNever(() => mockAuthCubit.updatePassword(any()));
    });

    testWidgets('submits new password to AuthCubit and signs out on success',
        (tester) async {
      when(() => mockAuthCubit.updatePassword('newSecret123'))
          .thenAnswer((_) async => right(null));
      when(() => mockAuthCubit.signOut()).thenAnswer((_) async => right(null));

      await tester.pumpWidget(_buildTestWidget(mockAuthCubit));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'كلمة المرور الجديدة'),
          'newSecret123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'تأكيد كلمة المرور'),
          'newSecret123');

      await tester.tap(find.text('حفظ كلمة المرور'));
      await tester.pumpAndSettle();

      verify(() => mockAuthCubit.updatePassword('newSecret123')).called(1);
      verify(() => mockAuthCubit.signOut()).called(1);
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('displays error message when updatePassword fails',
        (tester) async {
      when(() => mockAuthCubit.updatePassword(any())).thenAnswer((_) async =>
          left(const Failure.server(message: 'انتهت صلاحية الرابط')));

      await tester.pumpWidget(_buildTestWidget(mockAuthCubit));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'كلمة المرور الجديدة'),
          'newSecret123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'تأكيد كلمة المرور'),
          'newSecret123');

      await tester.tap(find.text('حفظ كلمة المرور'));
      await tester.pumpAndSettle();

      expect(find.text('انتهت صلاحية الرابط'), findsOneWidget);
    });

    testWidgets('tapping back button calls signOut and navigates to login',
        (tester) async {
      when(() => mockAuthCubit.signOut()).thenAnswer((_) async => right(null));

      await tester.pumpWidget(_buildTestWidget(mockAuthCubit));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      verify(() => mockAuthCubit.signOut()).called(1);
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}
