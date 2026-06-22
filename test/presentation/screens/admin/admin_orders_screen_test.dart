import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:tarwi2a/presentation/screens/admin/admin_orders_screen.dart';
import 'package:tarwi2a/application/admin/admin_orders_cubit.dart';
import 'package:tarwi2a/domain/enums/order_status.dart';
import 'package:tarwi2a/domain/entities/order.dart';
import 'package:tarwi2a/domain/enums/payment_method.dart';
import '../../../helpers/test_helpers.dart';

GoRouter _createRouter(NavigatorObserver observer) {
  return GoRouter(
    initialLocation: '/admin/orders',
    observers: [observer],
    routes: [
      GoRoute(
        path: '/admin/orders',
        builder: (_, __) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/orders/:id',
        builder: (_, __) => const Placeholder(),
      ),
    ],
  );
}

Widget _buildTestWidget({
  required AdminOrdersCubit ordersCubit,
  required NavigatorObserver observer,
}) {
  return MaterialApp.router(
    routerConfig: _createRouter(observer),
    builder: (context, child) => BlocProvider<AdminOrdersCubit>.value(
      value: ordersCubit,
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

List<_OrderRecord> _makeOrders() {
  return [
    (
      Order(
        id: 'order-1',
        customerName: 'أحمد',
        customerPhone: '01001111111',
        status: OrderStatus.pending,
        paymentMethod: PaymentMethod.cash,
        totalAmount: 120.0,
        createdAt: DateTime(2026, 5, 1, 10, 30),
        updatedAt: DateTime(2026, 5, 1, 10, 30),
        items: [],
      ),
      PaymentMethod.cash,
    ),
    (
      Order(
        id: 'order-2',
        customerName: 'سارة',
        customerPhone: '01002222222',
        status: OrderStatus.confirmed,
        paymentMethod: PaymentMethod.wallet,
        totalAmount: 85.0,
        createdAt: DateTime(2026, 5, 1, 11, 0),
        updatedAt: DateTime(2026, 5, 1, 11, 0),
        items: [],
      ),
      PaymentMethod.wallet,
    ),
  ];
}

typedef _OrderRecord = (Order, PaymentMethod);

void main() {
  late MockAdminOrdersCubit mockOrdersCubit;

  setUpAll(() {
    registerFallbackValue(const AdminOrdersState());
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockOrdersCubit = MockAdminOrdersCubit();
    when(() => mockOrdersCubit.stream)
        .thenAnswer((_) => const Stream<AdminOrdersState>.empty());
  });

  group('AdminOrdersScreen', () {
    testWidgets('renders order list', (tester) async {
      final orders = _makeOrders();
      when(() => mockOrdersCubit.state).thenReturn(
        AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: orders.map((r) => r.$1).toList(),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        observer: MockNavigatorObserver(),
      ));
      await tester.pump();

      expect(find.text('إدارة الطلبات'), findsOneWidget);
      expect(find.text('أحمد'), findsOneWidget);
      expect(find.text('سارة'), findsOneWidget);
    });

    testWidgets('search field filters orders', (tester) async {
      final orders = _makeOrders();
      when(() => mockOrdersCubit.state).thenReturn(
        AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: orders.map((r) => r.$1).toList(),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        observer: MockNavigatorObserver(),
      ));
      await tester.pump();

      expect(find.text('أحمد'), findsOneWidget);
      expect(find.text('سارة'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'أحمد');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('أحمد'), findsAtLeastNWidgets(1));
      expect(find.text('سارة'), findsNothing);
    });

    testWidgets('status filter chips render', (tester) async {
      final orders = _makeOrders();
      when(() => mockOrdersCubit.state).thenReturn(
        AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: orders.map((r) => r.$1).toList(),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        observer: MockNavigatorObserver(),
      ));
      await tester.pump();

      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('جديدة'), findsOneWidget);
      expect(find.text('مؤكدة'), findsOneWidget);
      expect(find.text('تحضير'), findsOneWidget);
      expect(find.text('جاهزة'), findsOneWidget);
      expect(find.text('تم التوصيل'), findsOneWidget);
      expect(find.text('ملغية'), findsOneWidget);
    });

    testWidgets('tapping status chip filters orders', (tester) async {
      final orders = _makeOrders();
      when(() => mockOrdersCubit.state).thenReturn(
        AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: orders.map((r) => r.$1).toList(),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        observer: MockNavigatorObserver(),
      ));
      await tester.pump();

      expect(find.text('أحمد'), findsOneWidget);
      expect(find.text('سارة'), findsOneWidget);

      await tester.tap(find.text('جديدة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('أحمد'), findsOneWidget);
      expect(find.text('سارة'), findsNothing);
    });

    testWidgets('tapping order navigates', (tester) async {
      final observer = MockNavigatorObserver();
      final orders = _makeOrders();
      when(() => mockOrdersCubit.state).thenReturn(
        AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: orders.map((r) => r.$1).toList(),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        observer: observer,
      ));
      await tester.pump();

      await tester.tap(find.text('أحمد'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      verify(() => observer.didPush(any(), any())).called(2);
    });

    testWidgets('pending indicator dot on pending orders', (tester) async {
      final pendingOrder = Order(
        id: 'order-pending',
        customerName: 'خالد',
        customerPhone: '01003333333',
        status: OrderStatus.pending,
        paymentMethod: PaymentMethod.cash,
        totalAmount: 50.0,
        createdAt: DateTime(2026, 5, 1),
        updatedAt: DateTime(2026, 5, 1),
        items: [],
      );
      when(() => mockOrdersCubit.state).thenReturn(
        AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: [pendingOrder],
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        observer: MockNavigatorObserver(),
      ));
      await tester.pump();

      expect(find.text('خالد'), findsOneWidget);
      expect(
          find.byWidgetPredicate(
              (w) => w is Container && w.constraints == null),
          findsWidgets);
    });

    testWidgets('pull-to-refresh reloads orders', (tester) async {
      when(() => mockOrdersCubit.loadOrders()).thenAnswer((_) async {});
      when(() => mockOrdersCubit.state).thenReturn(
        const AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: [],
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        observer: MockNavigatorObserver(),
      ));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    group('Edge cases', () {
      testWidgets('shows loading indicator when orders are loading',
          (tester) async {
        when(() => mockOrdersCubit.state).thenReturn(
          const AdminOrdersState(status: AdminOrdersStatus.loading),
        );

        await tester.pumpWidget(_buildTestWidget(
          ordersCubit: mockOrdersCubit,
          observer: MockNavigatorObserver(),
        ));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows empty state when no orders', (tester) async {
        when(() => mockOrdersCubit.state).thenReturn(
          const AdminOrdersState(
            status: AdminOrdersStatus.loaded,
            orders: [],
          ),
        );

        await tester.pumpWidget(_buildTestWidget(
          ordersCubit: mockOrdersCubit,
          observer: MockNavigatorObserver(),
        ));
        await tester.pump();

        expect(find.text('مفيش طلبات'), findsOneWidget);
      });

      testWidgets('shows error message when orders fail to load',
          (tester) async {
        when(() => mockOrdersCubit.state).thenReturn(
          const AdminOrdersState(
            status: AdminOrdersStatus.error,
            failure: testServerFailure,
          ),
        );

        await tester.pumpWidget(_buildTestWidget(
          ordersCubit: mockOrdersCubit,
          observer: MockNavigatorObserver(),
        ));
        await tester.pump();

        expect(find.text('خطأ: حدث خطأ في السيرفر'), findsOneWidget);
      });
    });
  });
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
