import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:tarwi2a/presentation/screens/admin/admin_order_detail_screen.dart';
import 'package:tarwi2a/application/admin/admin_orders_cubit.dart';
import 'package:tarwi2a/application/rating/rating_cubit.dart';
import 'package:tarwi2a/core/di/injection_container.dart';
import 'package:tarwi2a/domain/entities/order.dart';
import 'package:tarwi2a/domain/enums/order_status.dart';
import 'package:tarwi2a/domain/enums/payment_method.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import 'package:tarwi2a/domain/repositories/order_repository.dart';
import '../../../helpers/test_helpers.dart';

final _testOrder = Order(
  id: 'order-12', // at least 8 chars for substring(0,8)
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
    testOrderItem,
  ],
);

GoRouter _createRouter(Order order) {
  return GoRouter(
    initialLocation: '/admin/orders/detail',
    routes: [
      GoRoute(
        path: '/admin/orders/detail',
        builder: (_, __) => AdminOrderDetailScreen(order: order),
      ),
    ],
  );
}

Widget _buildTestWidget({
  required AdminOrdersCubit ordersCubit,
  required Order order,
}) {
  return MaterialApp.router(
    routerConfig: _createRouter(order),
    builder: (context, child) => BlocProvider<AdminOrdersCubit>.value(
      value: ordersCubit,
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

class _AdminOrderDetailRobot {
  final WidgetTester tester;

  const _AdminOrderDetailRobot(this.tester);

  Future<void> tapStatusConfirmation() async {
    await tester.tap(find.text('تأكيد الطلب'));
    await tester.pump();
  }

  Future<void> tapPaymentConfirmation() async {
    await tester.tap(find.text('تأكيد استلام الدفع'));
    await tester.pump();
  }

  void expectStatusConfirmationVisible() {
    expect(find.text('تأكيد الطلب'), findsOneWidget);
  }

  void expectPreparingVisible() {
    expect(find.text('بدء التحضير'), findsOneWidget);
  }

  void expectPaymentConfirmationVisible() {
    expect(find.text('تأكيد استلام الدفع'), findsOneWidget);
  }

  void expectSuccessNotVisible() {
    expect(find.text('تم تأكيد استلام الدفع'), findsNothing);
  }

  void expectPaymentSuccessVisible() {
    expect(find.text('تم تأكيد استلام الدفع'), findsOneWidget);
  }

  void expectFailureVisible(String message) {
    expect(find.text(message), findsOneWidget);
  }
}

void main() {
  late MockAdminOrdersCubit mockOrdersCubit;
  late MockRatingCubit mockRatingCubit;

  setUpAll(() {
    registerFallbackValue(const AdminOrdersState());
    registerFallbackValue(const RatingState());
  });

  setUp(() {
    mockOrdersCubit = MockAdminOrdersCubit();
    when(() => mockOrdersCubit.stream)
        .thenAnswer((_) => const Stream<AdminOrdersState>.empty());
    when(() => mockOrdersCubit.state).thenReturn(const AdminOrdersState());

    mockRatingCubit = MockRatingCubit();
    when(() => mockRatingCubit.state).thenReturn(const RatingState());
    when(() => mockRatingCubit.stream)
        .thenAnswer((_) => const Stream<RatingState>.empty());
    when(() => mockRatingCubit.loadOrderRating(any())).thenAnswer((_) async {});
    when(() => mockRatingCubit.close()).thenAnswer((_) async {});

    if (sl.isRegistered<RatingCubit>()) {
      sl.unregister<RatingCubit>();
    }
    sl.registerFactory<RatingCubit>(() => mockRatingCubit);
  });

  tearDown(() {
    if (sl.isRegistered<RatingCubit>()) {
      sl.unregister<RatingCubit>();
    }
  });

  Future<void> pumpOrderDetail(
    WidgetTester tester, {
    required AdminOrdersCubit ordersCubit,
    required Order order,
  }) async {
    tester.view.physicalSize = const Size(1800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(_buildTestWidget(
      ordersCubit: ordersCubit,
      order: order,
    ));
    await tester.pump();
    await tester.pump();
  }

  group('AdminOrderDetailScreen', () {
    testWidgets('status stepper renders with 5 steps', (tester) async {
      await pumpOrderDetail(
        tester,
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      );

      expect(find.text('انتظار'), findsOneWidget);
      expect(find.text('تأكيد'), findsOneWidget);
      expect(find.text('تحضير'), findsOneWidget);
      expect(find.text('جاهز'), findsOneWidget);
      expect(find.text('توصيل'), findsOneWidget);
    });

    testWidgets('current step highlighted', (tester) async {
      await pumpOrderDetail(
        tester,
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsWidgets);
    });

    testWidgets('customer info shown', (tester) async {
      await pumpOrderDetail(
        tester,
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      );

      expect(find.text('بيانات العميل'), findsOneWidget);
      expect(find.text(_testOrder.customerName), findsOneWidget);
      expect(find.text(_testOrder.customerPhone), findsOneWidget);
      expect(find.text(_testOrder.customerAddress!), findsOneWidget);
    });

    testWidgets('order items list with quantities and subtotals',
        (tester) async {
      await pumpOrderDetail(
        tester,
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      );

      expect(find.text('الأصناف'), findsOneWidget);
      expect(find.textContaining(testOrderItem.productName), findsOneWidget);
      expect(find.textContaining('150'), findsWidgets);
    });

    testWidgets('advance status button triggers updateStatus', (tester) async {
      when(() => mockOrdersCubit.updateStatus(any(), any()))
          .thenAnswer((_) async => right<Failure, void>(null));

      await pumpOrderDetail(
        tester,
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      );

      final advanceButton = find.text('تأكيد الطلب');
      expect(advanceButton, findsOneWidget);

      await tester.ensureVisible(advanceButton);
      await tester.pumpAndSettle();
      await tester.tap(advanceButton);
      await tester.pump();

      verify(() => mockOrdersCubit.updateStatus(
            _testOrder.id,
            'confirmed',
          )).called(1);
    });

    testWidgets('cancel button triggers updateStatus + confirmation',
        (tester) async {
      when(() => mockOrdersCubit.updateStatus(any(), any()))
          .thenAnswer((_) async => right<Failure, void>(null));

      await pumpOrderDetail(
        tester,
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      );

      await tester.tap(find.text('إلغاء الطلب').last);
      await tester.pumpAndSettle();

      expect(find.text('هل أنت متأكد من إلغاء هذا الطلب؟'), findsOneWidget);

      await tester.tap(find.text('إلغاء الطلب').last);
      await tester.pump();

      verify(() => mockOrdersCubit.updateStatus(
            _testOrder.id,
            'cancelled',
          )).called(1);
    });

    testWidgets('status failure keeps current action and shows failure',
        (tester) async {
      when(() => mockOrdersCubit.updateStatus(any(), any())).thenAnswer(
        (_) async => left(testServerFailure),
      );
      await pumpOrderDetail(
        tester,
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      );
      final robot = _AdminOrderDetailRobot(tester);

      await robot.tapStatusConfirmation();

      robot.expectStatusConfirmationVisible();
      robot.expectFailureVisible(testServerFailure.message);
      robot.expectSuccessNotVisible();
    });

    testWidgets('status success advances to preparing', (tester) async {
      when(() => mockOrdersCubit.updateStatus(any(), any())).thenAnswer(
        (_) async => right<Failure, void>(null),
      );
      await pumpOrderDetail(
        tester,
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      );
      final robot = _AdminOrderDetailRobot(tester);

      await robot.tapStatusConfirmation();

      robot.expectPreparingVisible();
    });

    testWidgets('payment failure keeps action and does not show success',
        (tester) async {
      final walletOrder = _testOrder.copyWith(
        paymentMethod: PaymentMethod.wallet,
        paymentStatus: 'pending',
      );
      when(() => mockOrdersCubit.confirmPayment(any())).thenAnswer(
        (_) async => left(testServerFailure),
      );
      await pumpOrderDetail(
        tester,
        ordersCubit: mockOrdersCubit,
        order: walletOrder,
      );
      final robot = _AdminOrderDetailRobot(tester);

      await robot.tapPaymentConfirmation();

      robot.expectPaymentConfirmationVisible();
      robot.expectFailureVisible(testServerFailure.message);
      robot.expectSuccessNotVisible();
    });

    testWidgets('payment success shows confirmation', (tester) async {
      final walletOrder = _testOrder.copyWith(
        paymentMethod: PaymentMethod.wallet,
        paymentStatus: 'pending',
      );
      when(() => mockOrdersCubit.confirmPayment(any())).thenAnswer(
        (_) async => right<Failure, void>(null),
      );
      await pumpOrderDetail(
        tester,
        ordersCubit: mockOrdersCubit,
        order: walletOrder,
      );
      final robot = _AdminOrderDetailRobot(tester);

      await robot.tapPaymentConfirmation();

      robot.expectPaymentSuccessVisible();
    });

    testWidgets(
        'fetches order by orderId when order is null and renders detail',
        (tester) async {
      final mockOrderRepo = MockOrderRepository();
      when(() => mockOrderRepo.getOrderById('order-12'))
          .thenAnswer((_) async => right(_testOrder));

      if (sl.isRegistered<OrderRepository>()) {
        sl.unregister<OrderRepository>();
      }
      sl.registerLazySingleton<OrderRepository>(() => mockOrderRepo);
      addTearDown(() {
        if (sl.isRegistered<OrderRepository>()) {
          sl.unregister<OrderRepository>();
        }
      });

      tester.view.physicalSize = const Size(1800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: '/admin/orders/detail',
        routes: [
          GoRoute(
            path: '/admin/orders/detail',
            builder: (_, __) =>
                const AdminOrderDetailScreen(orderId: 'order-12'),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => BlocProvider<AdminOrdersCubit>.value(
            value: mockOrdersCubit,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('محمد'), findsOneWidget);
      expect(find.text('01001234567'), findsOneWidget);
      expect(find.text('تأكيد الطلب'), findsOneWidget);
    });

    testWidgets('shows not-found message when orderId returns null order',
        (tester) async {
      final mockOrderRepo = MockOrderRepository();
      when(() => mockOrderRepo.getOrderById('order-missing'))
          .thenAnswer((_) async => right(null));

      if (sl.isRegistered<OrderRepository>()) {
        sl.unregister<OrderRepository>();
      }
      sl.registerLazySingleton<OrderRepository>(() => mockOrderRepo);
      addTearDown(() {
        if (sl.isRegistered<OrderRepository>()) {
          sl.unregister<OrderRepository>();
        }
      });

      tester.view.physicalSize = const Size(1800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: '/admin/orders/detail',
        routes: [
          GoRoute(
            path: '/admin/orders/detail',
            builder: (_, __) =>
                const AdminOrderDetailScreen(orderId: 'order-missing'),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => BlocProvider<AdminOrdersCubit>.value(
            value: mockOrdersCubit,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('الطلب غير موجود أو تم حذفه'), findsOneWidget);
    });
  });
}
