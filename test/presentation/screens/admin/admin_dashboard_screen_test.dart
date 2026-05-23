import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:matbakhy/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:matbakhy/application/auth/auth_cubit.dart';
import 'package:matbakhy/application/admin/admin_orders_cubit.dart';
import '../../../helpers/test_helpers.dart';

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: '/admin',
    routes: [
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(path: '/admin/orders', builder: (_, __) => const Placeholder()),
      GoRoute(path: '/admin/menu', builder: (_, __) => const Placeholder()),
      GoRoute(path: '/login', builder: (_, __) => const Placeholder()),
    ],
  );
}

Widget _buildTestWidget({
  required AdminOrdersCubit ordersCubit,
  required AuthCubit authCubit,
}) {
  return MaterialApp.router(
    routerConfig: _createRouter(),
    builder: (context, child) => MultiBlocProvider(
      providers: [
        BlocProvider<AdminOrdersCubit>.value(value: ordersCubit),
        BlocProvider<AuthCubit>.value(value: authCubit),
      ],
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

void main() {
  late MockAdminOrdersCubit mockOrdersCubit;
  late MockAuthCubit mockAuthCubit;

  setUpAll(() {
    registerFallbackValue(const AdminOrdersState());
    registerFallbackValue(const AuthState.initial());
  });

  setUp(() {
    mockOrdersCubit = MockAdminOrdersCubit();
    mockAuthCubit = MockAuthCubit();

    when(() => mockOrdersCubit.stream)
        .thenAnswer((_) => const Stream<AdminOrdersState>.empty());
    when(() => mockAuthCubit.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());
  });

  group('AdminDashboardScreen', () {
    testWidgets('shows greeting with admin name', (tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(AuthState.authenticated(testAdminProfile));
      when(() => mockOrdersCubit.state).thenReturn(
        const AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: [],
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      expect(find.text('أهلاً مدير'), findsOneWidget);
      expect(find.text('لوحة التحكم'), findsOneWidget);
    });

    testWidgets('shows 3 stat cards', (tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(AuthState.authenticated(testAdminProfile));
      when(() => mockOrdersCubit.state).thenReturn(
        const AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: [],
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      expect(find.text('طلبات جديدة'), findsOneWidget);
      expect(find.text('مبيعات اليوم'), findsOneWidget);
      expect(find.text('إجمالي الطلبات'), findsOneWidget);
    });

    testWidgets('action cards render', (tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(AuthState.authenticated(testAdminProfile));
      when(() => mockOrdersCubit.state).thenReturn(
        const AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: [],
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      expect(find.text('الإجراءات السريعة'), findsOneWidget);
      expect(find.text('إدارة الطلبات'), findsOneWidget);
      expect(find.text('إدارة المنيو'), findsOneWidget);
    });

    testWidgets('pull-to-refresh renders', (tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(AuthState.authenticated(testAdminProfile));
      when(() => mockOrdersCubit.state).thenReturn(
        const AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: [],
        ),
      );
      when(() => mockOrdersCubit.loadOrders()).thenAnswer((_) async {});
      when(() => mockAuthCubit.checkAuthStatus()).thenAnswer((_) {});

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('logout button visible with confirmation dialog',
        (tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(AuthState.authenticated(testAdminProfile));
      when(() => mockOrdersCubit.state).thenReturn(
        const AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: [],
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.logout), findsOneWidget);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.text('تسجيل الخروج'), findsOneWidget);
      expect(find.text('هل أنت متأكد من تسجيل الخروج؟'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('خروج'), findsOneWidget);
    });

    testWidgets('shows loading indicator when orders status is loading',
        (tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(AuthState.authenticated(testAdminProfile));
      when(() => mockOrdersCubit.state).thenReturn(
        const AdminOrdersState(status: AdminOrdersStatus.loading),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when orders status is error',
        (tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(AuthState.authenticated(testAdminProfile));
      when(() => mockOrdersCubit.state).thenReturn(
        const AdminOrdersState(
          status: AdminOrdersStatus.error,
          failure: testServerFailure,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      expect(find.text('خطأ: حدث خطأ في السيرفر'), findsOneWidget);
    });

    testWidgets('shows empty message when no recent orders', (tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(AuthState.authenticated(testAdminProfile));
      when(() => mockOrdersCubit.state).thenReturn(
        const AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: [],
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      expect(find.text('آخر الطلبات'), findsOneWidget);
      expect(find.text('مفيش طلبات لسه'), findsOneWidget);
    });

    group('Edge cases', () {
      testWidgets('stat cards show zero values when no orders',
          (tester) async {
        when(() => mockAuthCubit.state)
            .thenReturn(AuthState.authenticated(testAdminProfile));
        when(() => mockOrdersCubit.state).thenReturn(
          const AdminOrdersState(
            status: AdminOrdersStatus.loaded,
            orders: [],
          ),
        );

        await tester.pumpWidget(_buildTestWidget(
          ordersCubit: mockOrdersCubit,
          authCubit: mockAuthCubit,
        ));
        await tester.pump();

        expect(find.text('0'), findsAtLeastNWidgets(2));
        expect(find.text('0 ج'), findsOneWidget);
      });
    });
  });
}
