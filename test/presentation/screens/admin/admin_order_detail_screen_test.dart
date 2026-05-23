import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:matbakhy/presentation/screens/admin/admin_order_detail_screen.dart';
import 'package:matbakhy/application/admin/admin_orders_cubit.dart';
import 'package:matbakhy/domain/entities/order.dart';
import 'package:matbakhy/domain/enums/order_status.dart';
import 'package:matbakhy/domain/enums/payment_method.dart';
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

void main() {
  late MockAdminOrdersCubit mockOrdersCubit;

  setUpAll(() {
    registerFallbackValue(const AdminOrdersState());
  });

  setUp(() {
    mockOrdersCubit = MockAdminOrdersCubit();
    when(() => mockOrdersCubit.stream)
        .thenAnswer((_) => const Stream<AdminOrdersState>.empty());
    when(() => mockOrdersCubit.state).thenReturn(const AdminOrdersState());
  });

  group('AdminOrderDetailScreen', () {
    testWidgets('status stepper renders with 5 steps', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('انتظار'), findsOneWidget);
      expect(find.text('تأكيد'), findsOneWidget);
      expect(find.text('تحضير'), findsOneWidget);
      expect(find.text('جاهز'), findsOneWidget);
      expect(find.text('توصيل'), findsOneWidget);
    });

    testWidgets('current step highlighted', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsWidgets);
    });

    testWidgets('customer info shown', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('بيانات العميل'), findsOneWidget);
      expect(find.text(_testOrder.customerName), findsOneWidget);
      expect(find.text(_testOrder.customerPhone), findsOneWidget);
      expect(find.text(_testOrder.customerAddress!), findsOneWidget);
    });

    testWidgets('order items list with quantities and subtotals',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('الأصناف'), findsOneWidget);
      expect(find.textContaining(testOrderItem.productName), findsOneWidget);
      expect(find.textContaining('150'), findsWidgets);
    });

    testWidgets('advance status button triggers updateStatus', (tester) async {
      when(() => mockOrdersCubit.updateStatus(any(), any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      ));
      await tester.pump();

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
          .thenAnswer((_) async {});

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
        order: _testOrder,
      ));
      await tester.pump();

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
  });
}
