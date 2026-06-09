import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:matbakhy/presentation/screens/orders/order_detail_screen.dart';
import 'package:matbakhy/domain/entities/order.dart';
import 'package:matbakhy/domain/entities/order_item.dart';
import 'package:matbakhy/domain/enums/payment_method.dart';
import 'package:matbakhy/domain/enums/order_status.dart';
import 'package:matbakhy/domain/entities/user_profile.dart';
import 'package:matbakhy/domain/enums/user_role.dart';
import 'package:matbakhy/app/theme/app_theme.dart';
import 'package:matbakhy/application/auth/auth_cubit.dart';
import 'package:matbakhy/application/orders/customer_orders_cubit.dart';
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
  discountAmount: 0,
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

final _testOrderWithDiscount = Order(
  id: 'order-002',
  customerId: 'user-456',
  customerName: 'أحمد',
  customerPhone: '0100999888',
  notes: '',
  paymentMethod: PaymentMethod.wallet,
  status: OrderStatus.preparing,
  totalAmount: 200.0,
  discountAmount: 50.0,
  createdAt: DateTime(2026, 5, 15, 18, 0),
  updatedAt: DateTime(2026, 5, 15, 18, 5),
  items: [
    const OrderItem(
      id: 'oi-003',
      orderId: 'order-002',
      productId: 'prod-3',
      productName: 'مشاوي',
      productPrice: 100.0,
      quantity: 2,
      subtotal: 200.0,
    ),
  ],
);

Widget _buildTestWidget(Order order) {
  final mockAuthCubit = MockAuthCubit();
  final mockCustomerOrdersCubit = MockCustomerOrdersCubit();

  when(() => mockAuthCubit.state).thenReturn(Authenticated(
    UserProfile(
      id: order.customerId ?? 'user-123',
      name: order.customerName,
      phone: order.customerPhone,
      role: UserRole.customer,
      createdAt: DateTime.now(),
    ),
  ));
  when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream<AuthState>.empty());
  when(() => mockAuthCubit.close()).thenAnswer((_) async {});

  when(() => mockCustomerOrdersCubit.state).thenReturn(CustomerOrdersState(
    orders: [order],
    status: CustomerOrdersStatus.loaded,
  ));
  when(() => mockCustomerOrdersCubit.stream).thenAnswer((_) => const Stream<CustomerOrdersState>.empty());
  when(() => mockCustomerOrdersCubit.close()).thenAnswer((_) async {});
  when(() => mockCustomerOrdersCubit.loadOrders(any())).thenAnswer((_) async {});

  return MaterialApp(
    theme: AppTheme.light,
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        BlocProvider<CustomerOrdersCubit>.value(value: mockCustomerOrdersCubit),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: OrderDetailScreen(orderId: order.id, initialOrder: order),
      ),
    ),
  );
}

class OrderDetailRobot {
  final WidgetTester tester;

  const OrderDetailRobot(this.tester);

  Future<void> pumpScreen(Order order) async {
    await tester.pumpWidget(_buildTestWidget(order));
    await tester.pump();
  }

  void expectCustomerInfoVisible() {
    expect(find.text('الاسم'), findsOneWidget);
    expect(find.text('محمد'), findsOneWidget);
    expect(find.text('01001234567'), findsOneWidget);
    expect(find.text('القاهرة'), findsOneWidget);
  }

  void expectOrderItemsVisible() {
    expect(find.text('مارجريتا × 2'), findsOneWidget);
    expect(find.textContaining('150 ج'), findsWidgets);
    expect(find.text('الإجمالي'), findsOneWidget);
    expect(find.textContaining('150 جنيه'), findsWidgets);
  }

  void expectPaymentInfoVisible() {
    expect(find.text('طريقة الدفع'), findsOneWidget);
    expect(find.text('كاش'), findsOneWidget);
  }

  void expectNotesVisible() {
    expect(find.text('ملاحظات'), findsOneWidget);
    expect(find.text('بدون بصل'), findsOneWidget);
  }

  void expectNoNotesVisible() {
    expect(find.text('ملاحظات'), findsNothing);
  }

  void expectDiscountVisible() {
    expect(find.text('الخصم'), findsOneWidget);
    expect(find.textContaining('-50 ج'), findsOneWidget);
  }

  void expectNoDiscountVisible() {
    expect(find.text('الخصم'), findsNothing);
  }

  void expectAppBarShowsOrderId() {
    expect(find.textContaining('ORDER-00'), findsWidgets);
  }
}

void main() {
  group('OrderDetailScreen', () {
    group('customer info', () {
      testWidgets('should show customer name, phone, and address',
          (tester) async {
        final robot = OrderDetailRobot(tester);
        await robot.pumpScreen(_testOrder);
        robot.expectCustomerInfoVisible();
      });

      testWidgets('should show payment method', (tester) async {
        final robot = OrderDetailRobot(tester);
        await robot.pumpScreen(_testOrder);
        robot.expectPaymentInfoVisible();
      });
    });

    group('order items', () {
      testWidgets('should show items with quantity and subtotal',
          (tester) async {
        final robot = OrderDetailRobot(tester);
        await robot.pumpScreen(_testOrder);
        robot.expectOrderItemsVisible();
      });
    });

    group('notes', () {
      testWidgets('should show notes when present', (tester) async {
        final robot = OrderDetailRobot(tester);
        await robot.pumpScreen(_testOrder);
        robot.expectNotesVisible();
      });

      testWidgets('should hide notes section when notes are empty',
          (tester) async {
        final robot = OrderDetailRobot(tester);
        await robot.pumpScreen(_testOrderWithDiscount);
        robot.expectNoNotesVisible();
      });
    });

    group('discount', () {
      testWidgets('should show discount row when discount > 0',
          (tester) async {
        final robot = OrderDetailRobot(tester);
        await robot.pumpScreen(_testOrderWithDiscount);
        robot.expectDiscountVisible();
      });

      testWidgets('should not show discount when discount is 0',
          (tester) async {
        final robot = OrderDetailRobot(tester);
        await robot.pumpScreen(_testOrder);
        robot.expectNoDiscountVisible();
      });
    });

    group('appbar', () {
      testWidgets('should display truncated order ID in AppBar',
          (tester) async {
        final robot = OrderDetailRobot(tester);
        await robot.pumpScreen(_testOrder);
        robot.expectAppBarShowsOrderId();
      });
    });

    group('edge cases', () {
      testWidgets('should handle order with single item', (tester) async {
        final singleItemOrder = Order(
          id: 'order-003',
          customerId: 'user-789',
          customerName: 'سارة',
          customerPhone: '0100555666',
          paymentMethod: PaymentMethod.instapay,
          status: OrderStatus.confirmed,
          totalAmount: 45.0,
          createdAt: DateTime(2026, 5, 12),
          updatedAt: DateTime(2026, 5, 12),
          items: [
            const OrderItem(
              id: 'oi-010',
              orderId: 'order-003',
              productId: 'prod-5',
              productName: 'شاورما',
              productPrice: 45.0,
              quantity: 1,
              subtotal: 45.0,
            ),
          ],
        );

        await tester.pumpWidget(_buildTestWidget(singleItemOrder));
        await tester.pump();

        expect(find.text('شاورما × 1'), findsOneWidget);
        expect(find.text('45 جنيه'), findsWidgets);
      });

      testWidgets('should handle order with many items', (tester) async {
        final manyItemsOrder = Order(
          id: 'order-004',
          customerId: 'user-111',
          customerName: 'كريم',
          customerPhone: '0100111222',
          paymentMethod: PaymentMethod.cash,
          status: OrderStatus.delivered,
          totalAmount: 300.0,
          createdAt: DateTime(2026, 5, 18),
          updatedAt: DateTime(2026, 5, 18),
          items: List.generate(
            10,
            (i) => OrderItem(
              id: 'oi-$i',
              orderId: 'order-004',
              productId: 'prod-$i',
              productName: 'منتج $i',
              productPrice: 30.0,
              quantity: 1,
              subtotal: 30.0,
            ),
          ),
        );

        await tester.pumpWidget(_buildTestWidget(manyItemsOrder));
        await tester.pump();

        expect(find.text('الأصناف المطلوبة'), findsOneWidget);
        expect(find.text('300 جنيه'), findsWidgets);
      });
    });
  });
}
