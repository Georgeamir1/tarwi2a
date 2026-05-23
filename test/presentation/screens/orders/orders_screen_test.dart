import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:matbakhy/presentation/screens/orders/orders_screen.dart';
import 'package:matbakhy/application/orders/customer_orders_cubit.dart';
import 'package:matbakhy/application/auth/auth_cubit.dart';
import 'package:matbakhy/domain/entities/order.dart';
import 'package:matbakhy/domain/entities/order_item.dart';
import 'package:matbakhy/domain/enums/order_status.dart';
import 'package:matbakhy/domain/enums/payment_method.dart';
import 'package:matbakhy/app/theme/app_theme.dart';
import 'package:matbakhy/presentation/widgets/skeleton_card.dart';
import '../../../helpers/test_helpers.dart';

final _testOrder = Order(
  id: 'order-001',
  customerId: 'user-123',
  customerName: 'محمد',
  customerPhone: '01001234567',
  customerAddress: 'القاهرة',
  notes: 'بدون بصل',
  paymentMethod: PaymentMethod.cash,
  status: OrderStatus.pending,
  totalAmount: 150.0,
  createdAt: DateTime(2026, 5, 1, 10, 0),
  updatedAt: DateTime(2026, 5, 1, 10, 0),
  items: [
    const OrderItem(
      id: 'oi-001',
      orderId: 'order-001',
      productId: 'prod-1',
      productName: 'مارجريتا',
      productPrice: 75.0,
      quantity: 2,
      subtotal: 150.0,
    ),
  ],
);

final _testDeliveredOrder = Order(
  id: 'order-002',
  customerId: 'user-123',
  customerName: 'محمد',
  customerPhone: '01001234567',
  paymentMethod: PaymentMethod.wallet,
  status: OrderStatus.delivered,
  totalAmount: 75.0,
  createdAt: DateTime(2026, 5, 10, 14, 0),
  updatedAt: DateTime(2026, 5, 10, 14, 30),
  items: [
    const OrderItem(
      id: 'oi-002',
      orderId: 'order-002',
      productId: 'prod-2',
      productName: 'بيبسي',
      productPrice: 15.0,
      quantity: 5,
      subtotal: 75.0,
    ),
  ],
);

Widget _buildTestWidget({
  required AuthCubit authCubit,
  required CustomerOrdersCubit ordersCubit,
}) {
  final router = GoRouter(
    initialLocation: '/orders',
    routes: [
      GoRoute(
        path: '/orders',
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<CustomerOrdersCubit>.value(value: ordersCubit),
          ],
          child: const OrdersScreen(),
        ),
        routes: [
          GoRoute(
            path: 'order-001',
            builder: (_, __) => const Placeholder(),
          ),
          GoRoute(
            path: 'order-002',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
      GoRoute(path: '/home', builder: (_, __) => const Placeholder()),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.light,
  );
}

class OrdersRobot {
  final WidgetTester tester;

  const OrdersRobot(this.tester);

  Future<void> pumpScreen({
    required AuthCubit authCubit,
    required CustomerOrdersCubit ordersCubit,
  }) async {
    await tester.pumpWidget(_buildTestWidget(
        authCubit: authCubit, ordersCubit: ordersCubit));
    await tester.pump();
  }

  void expectAppBarVisible() {
    expect(find.text('طلباتي'), findsOneWidget);
  }

  void expectStatusBadgeVisible(String arabicLabel) {
    expect(find.text(arabicLabel), findsOneWidget);
  }

  void expectOrderTotalVisible(int amount) {
    expect(find.text('$amount جنيه'), findsWidgets);
  }

  void expectItemCountVisible() {
    expect(find.textContaining('أصناف'), findsWidgets);
  }

  void expectEmptyStateVisible() {
    expect(find.text('مفيش طلبات لحد دلوقتي'), findsOneWidget);
    expect(find.text('اطلب دلوقتي'), findsOneWidget);
  }

  void expectLoadingSkeletonVisible() {
    expect(find.byType(SkeletonListTile), findsWidgets);
  }

  void expectErrorVisible() {
    expect(find.textContaining('حصل خطأ'), findsOneWidget);
  }

  Future<void> tapOrder() async {
    await tester.tap(find.text('في الانتظار').first);
    await tester.pumpAndSettle();
  }

  void expectNavigatedToDetail() {
    expect(find.byType(Placeholder), findsOneWidget);
  }
}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockCustomerOrdersCubit mockOrdersCubit;

  setUpAll(() {
    registerFallbackValue(RouteFake<dynamic>());
  });

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockOrdersCubit = MockCustomerOrdersCubit();

    when(() => mockAuthCubit.state)
        .thenReturn(AuthState.authenticated(testUserProfile));
    when(() => mockAuthCubit.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => mockAuthCubit.close()).thenAnswer((_) async {});

    when(() => mockOrdersCubit.stream)
        .thenAnswer((_) => const Stream<CustomerOrdersState>.empty());
    when(() => mockOrdersCubit.close()).thenAnswer((_) async {});
    when(() => mockOrdersCubit.loadOrders(any()))
        .thenAnswer((_) async {});

    GetIt.instance.registerLazySingleton<CustomerOrdersCubit>(
        () => mockOrdersCubit);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('OrdersScreen', () {
    group('render', () {
      testWidgets('should show AppBar with title when loaded', (tester) async {
        when(() => mockOrdersCubit.state).thenReturn(
          CustomerOrdersState.initial().copyWith(
            status: CustomerOrdersStatus.loaded,
            orders: [_testOrder, _testDeliveredOrder],
          ),
        );

        final robot = OrdersRobot(tester);
        await robot.pumpScreen(
            authCubit: mockAuthCubit, ordersCubit: mockOrdersCubit);
        robot.expectAppBarVisible();
      });

      testWidgets('should show order list with status badges when loaded',
          (tester) async {
        when(() => mockOrdersCubit.state).thenReturn(
          CustomerOrdersState.initial().copyWith(
            status: CustomerOrdersStatus.loaded,
            orders: [_testOrder, _testDeliveredOrder],
          ),
        );

        final robot = OrdersRobot(tester);
        await robot.pumpScreen(
            authCubit: mockAuthCubit, ordersCubit: mockOrdersCubit);

        robot.expectStatusBadgeVisible('في الانتظار');
        robot.expectStatusBadgeVisible('تم التوصيل');
        robot.expectOrderTotalVisible(150);
        robot.expectOrderTotalVisible(75);
        robot.expectItemCountVisible();
      });

      testWidgets('should show empty state when orders list is empty',
          (tester) async {
        when(() => mockOrdersCubit.state).thenReturn(
          CustomerOrdersState.initial().copyWith(
            status: CustomerOrdersStatus.loaded,
            orders: [],
          ),
        );

        final robot = OrdersRobot(tester);
        await robot.pumpScreen(
            authCubit: mockAuthCubit, ordersCubit: mockOrdersCubit);
        robot.expectEmptyStateVisible();
      });

      testWidgets('should show loading skeleton when loading', (tester) async {
        when(() => mockOrdersCubit.state).thenReturn(
          CustomerOrdersState.initial().copyWith(
            status: CustomerOrdersStatus.loading,
          ),
        );

        final robot = OrdersRobot(tester);
        await robot.pumpScreen(
            authCubit: mockAuthCubit, ordersCubit: mockOrdersCubit);
        robot.expectLoadingSkeletonVisible();
      });

      testWidgets('should show error message when error', (tester) async {
        when(() => mockOrdersCubit.state).thenReturn(
          CustomerOrdersState.initial().copyWith(
            status: CustomerOrdersStatus.error,
            failure: testServerFailure,
          ),
        );

        final robot = OrdersRobot(tester);
        await robot.pumpScreen(
            authCubit: mockAuthCubit, ordersCubit: mockOrdersCubit);
        robot.expectErrorVisible();
      });
    });

    group('navigation', () {
      testWidgets('should navigate to order detail when tapping order',
          (tester) async {
        when(() => mockOrdersCubit.state).thenReturn(
          CustomerOrdersState.initial().copyWith(
            status: CustomerOrdersStatus.loaded,
            orders: [_testOrder],
          ),
        );

        final robot = OrdersRobot(tester);
        await robot.pumpScreen(
            authCubit: mockAuthCubit, ordersCubit: mockOrdersCubit);
        await robot.tapOrder();
        robot.expectNavigatedToDetail();
      });
    });

    group('edge cases', () {
      testWidgets('should handle unauthenticated state gracefully',
          (tester) async {
        when(() => mockAuthCubit.state)
            .thenReturn(const AuthState.unauthenticated());
        when(() => mockOrdersCubit.state).thenReturn(
          CustomerOrdersState.initial().copyWith(
            status: CustomerOrdersStatus.loaded,
            orders: [],
          ),
        );

        final robot = OrdersRobot(tester);
        await robot.pumpScreen(
            authCubit: mockAuthCubit, ordersCubit: mockOrdersCubit);
        robot.expectEmptyStateVisible();
      });
    });
  });
}

class RouteFake<T> extends Route<T> {
  @override
  Future<RoutePopDisposition> willPop() async => RoutePopDisposition.pop;
}
