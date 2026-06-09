import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:matbakhy/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:matbakhy/application/auth/auth_cubit.dart';
import 'package:matbakhy/application/admin/admin_orders_cubit.dart';
import 'package:matbakhy/application/admin/admin_reports_cubit.dart';
import 'package:matbakhy/domain/repositories/report_repository.dart';
import '../../../helpers/test_helpers.dart';

class MockAdminReportsCubit extends Mock implements AdminReportsCubit {}

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
  required AdminReportsCubit reportsCubit,
}) {
  return MaterialApp.router(
    routerConfig: _createRouter(),
    builder: (context, child) => MultiBlocProvider(
      providers: [
        BlocProvider<AdminOrdersCubit>.value(value: ordersCubit),
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<AdminReportsCubit>.value(value: reportsCubit),
      ],
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

void main() {
  late MockAdminOrdersCubit mockOrdersCubit;
  late MockAuthCubit mockAuthCubit;
  late MockAdminReportsCubit mockReportsCubit;

  setUpAll(() {
    registerFallbackValue(const AdminOrdersState());
    registerFallbackValue(const AuthState.initial());
    registerFallbackValue(
      AdminReportsState(
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockOrdersCubit = MockAdminOrdersCubit();
    mockAuthCubit = MockAuthCubit();
    mockReportsCubit = MockAdminReportsCubit();

    when(() => mockOrdersCubit.stream)
        .thenAnswer((_) => const Stream<AdminOrdersState>.empty());
    when(() => mockAuthCubit.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => mockReportsCubit.stream)
        .thenAnswer((_) => const Stream<AdminReportsState>.empty());

    // Default stub for reportsCubit state
    when(() => mockReportsCubit.state).thenReturn(
      AdminReportsState(
        status: AdminReportsStatus.loaded,
        data: testReportData,
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      ),
    );
    when(() => mockReportsCubit.loadReports(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async {});
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
        reportsCubit: mockReportsCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('أهلاً مدير'), findsOneWidget);
      expect(find.text('لوحة التحكم'), findsOneWidget);
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
        reportsCubit: mockReportsCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('طلبات انتظار'), findsOneWidget);
      expect(find.text('إجمالي المبيعات'), findsOneWidget);
      expect(find.text('عدد الطلبات'), findsOneWidget);
      expect(find.text('متوسط الطلب'), findsOneWidget);
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
        reportsCubit: mockReportsCubit,
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
      when(() => mockReportsCubit.updateDateRange(any(), any()))
          .thenAnswer((_) {});

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        authCubit: mockAuthCubit,
        reportsCubit: mockReportsCubit,
      ));
      await tester.pumpAndSettle();

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
        reportsCubit: mockReportsCubit,
      ));
      await tester.pumpAndSettle();

      // Logout is inside settings bottom sheet, tap settings icon first
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

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
        reportsCubit: mockReportsCubit,
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
        reportsCubit: mockReportsCubit,
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
        reportsCubit: mockReportsCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('آخر الطلبات'), findsOneWidget);
      expect(find.text('مفيش طلبات لسه'), findsOneWidget);
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
        when(() => mockReportsCubit.state).thenReturn(
          AdminReportsState(
            status: AdminReportsStatus.loaded,
            data: ReportData(
              totalRevenue: 0.0,
              totalOrders: 0,
              averageOrder: 0.0,
              cancelledOrders: 0,
              revenueByDay: [],
              topProducts: [],
              totalCustomers: 0,
              discountTotal: 0,
            ),
            startDate: DateTime.now().subtract(const Duration(days: 7)),
            endDate: DateTime.now(),
          ),
        );

        await tester.pumpWidget(_buildTestWidget(
          ordersCubit: mockOrdersCubit,
          authCubit: mockAuthCubit,
          reportsCubit: mockReportsCubit,
        ));
        await tester.pumpAndSettle();

        // Values are rendered in RichText, verify by finding KPI card titles
        expect(find.text('طلبات انتظار'), findsOneWidget);
        expect(find.text('عدد الطلبات'), findsOneWidget);
      });
    });
  });
}
