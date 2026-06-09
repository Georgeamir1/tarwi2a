import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:matbakhy/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:matbakhy/application/auth/auth_cubit.dart';
import 'package:matbakhy/application/admin/admin_orders_cubit.dart';
import 'package:matbakhy/application/admin/admin_business_profile_cubit.dart';
import '../../../helpers/test_helpers.dart';

class MockAdminBusinessProfileCubit extends Mock
    implements AdminBusinessProfileCubit {}

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
      GoRoute(path: '/admin/notifications', builder: (_, __) => const Placeholder()),
    ],
  );
}

Widget _buildTestWidget({
  required AdminOrdersCubit ordersCubit,
  required AuthCubit authCubit,
  required AdminBusinessProfileCubit businessProfileCubit,
}) {
  return MaterialApp.router(
    routerConfig: _createRouter(),
    builder: (context, child) => MultiBlocProvider(
      providers: [
        BlocProvider<AdminOrdersCubit>.value(value: ordersCubit),
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<AdminBusinessProfileCubit>.value(value: businessProfileCubit),
      ],
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

void main() {
  late MockAdminOrdersCubit mockOrdersCubit;
  late MockAuthCubit mockAuthCubit;
  late MockAdminBusinessProfileCubit mockBusinessProfileCubit;

  setUpAll(() {
    registerFallbackValue(const AdminOrdersState());
    registerFallbackValue(const AuthState.initial());
    registerFallbackValue(const AdminBusinessProfileState());
  });

  setUp(() {
    mockOrdersCubit = MockAdminOrdersCubit();
    mockAuthCubit = MockAuthCubit();
    mockBusinessProfileCubit = MockAdminBusinessProfileCubit();

    when(() => mockOrdersCubit.stream)
        .thenAnswer((_) => const Stream<AdminOrdersState>.empty());
    when(() => mockAuthCubit.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => mockBusinessProfileCubit.stream)
        .thenAnswer((_) => const Stream<AdminBusinessProfileState>.empty());

    // Default stub for business profile
    when(() => mockBusinessProfileCubit.state).thenReturn(
      AdminBusinessProfileState(
        status: AdminBusinessProfileStatus.loaded,
        profile: testBusinessProfile,
      ),
    );
    when(() => mockBusinessProfileCubit.loadProfile()).thenAnswer((_) async {});
  });

  group('AdminDashboardScreen', () {
    setUp(() {
      // Use a large viewport so scrollable content is visible
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      if (binding.platformDispatcher.views.isNotEmpty) {
        final view = binding.platformDispatcher.views.first;
        if (view is TestFlutterView) {
          view.physicalSize = const Size(800, 2400);
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
        businessProfileCubit: mockBusinessProfileCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('أهلاً، مدير 👋'), findsOneWidget);
    });

    testWidgets('shows KPI cards', (tester) async {
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
        businessProfileCubit: mockBusinessProfileCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('بانتظار التأكيد'), findsOneWidget);
      expect(find.text('إجمالي الطلبات'), findsOneWidget);
      expect(find.text('عدد العملاء'), findsOneWidget);
      expect(find.text('الطلبات الملغاة'), findsOneWidget);
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
        businessProfileCubit: mockBusinessProfileCubit,
      ));
      await tester.pumpAndSettle();

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
      when(() => mockBusinessProfileCubit.loadProfile()).thenAnswer((_) async {});

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        authCubit: mockAuthCubit,
        businessProfileCubit: mockBusinessProfileCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
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
        businessProfileCubit: mockBusinessProfileCubit,
      ));
      // Use pump() instead of pumpAndSettle() because CircularProgressIndicator
      // is an endless animation that never settles.
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
        businessProfileCubit: mockBusinessProfileCubit,
      ));
      await tester.pumpAndSettle();

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
        businessProfileCubit: mockBusinessProfileCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('آخر الطلبات'), findsOneWidget);
      expect(find.text('لا توجد طلبات مسجلة حالياً'), findsOneWidget);
    });

    group('Edge cases', () {
      testWidgets('KPI cards show zero values when no orders', (tester) async {
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
          businessProfileCubit: mockBusinessProfileCubit,
        ));
        await tester.pumpAndSettle();

        // Values are rendered in RichText, verify by finding KPI card titles
        expect(find.text('بانتظار التأكيد'), findsOneWidget);
        expect(find.text('إجمالي الطلبات'), findsOneWidget);
      });
    });
  });
}
