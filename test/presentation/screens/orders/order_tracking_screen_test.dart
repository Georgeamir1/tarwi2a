import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:matbakhy/presentation/screens/orders/order_tracking_screen.dart';
import 'package:matbakhy/domain/entities/order.dart';
import 'package:matbakhy/domain/entities/order_item.dart';
import 'package:matbakhy/domain/enums/order_status.dart';
import 'package:matbakhy/domain/enums/payment_method.dart';
import 'package:matbakhy/domain/entities/user_profile.dart';
import 'package:matbakhy/domain/enums/user_role.dart';
import 'package:matbakhy/app/theme/app_theme.dart';
import 'package:matbakhy/application/auth/auth_cubit.dart';
import 'package:matbakhy/application/orders/customer_orders_cubit.dart';
import '../../../helpers/test_helpers.dart';

final _testOrder = Order(
  id: 'order-001-abc-def',
  customerId: 'user-123',
  customerName: 'محمد',
  customerPhone: '01001234567',
  customerAddress: 'القاهرة',
  notes: 'بدون بصل',
  paymentMethod: PaymentMethod.cash,
  status: OrderStatus.confirmed,
  totalAmount: 150.0,
  createdAt: DateTime(2026, 5, 1, 10, 0),
  updatedAt: DateTime(2026, 5, 1, 10, 0),
  items: [
    const OrderItem(
      id: 'oi-001',
      orderId: 'order-001-abc-def',
      productId: 'prod-1',
      productName: 'مارجريتا',
      productPrice: 75.0,
      quantity: 2,
      subtotal: 150.0,
    ),
  ],
);

Widget _buildTestWidget({OrderStatus status = OrderStatus.confirmed}) {
  final mockAuthCubit = MockAuthCubit();
  final mockCustomerOrdersCubit = MockCustomerOrdersCubit();

  final order = _testOrder.copyWith(status: status);

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
        child: OrderTrackingScreen(
          orderId: order.id,
          initialOrder: order,
        ),
      ),
    ),
  );
}

void main() {
  group('OrderTrackingScreen', () {
    group('render', () {
      testWidgets('should show AppBar with tracking title', (tester) async {
        await tester.pumpWidget(_buildTestWidget());
        await tester.pump();

        expect(find.text('تتبع الطلب'), findsOneWidget);
      });

      testWidgets('should show order ID in card', (tester) async {
        await tester.pumpWidget(_buildTestWidget());
        await tester.pump();

        expect(find.textContaining('رقم الطلب'), findsOneWidget);
        expect(find.textContaining('ORDER-'), findsOneWidget);
      });

      testWidgets('should show estimated delivery time', (tester) async {
        await tester.pumpWidget(_buildTestWidget());
        await tester.pump();

        expect(find.textContaining('الوقت المتوقع'), findsOneWidget);
        expect(find.textContaining('دقيقة'), findsOneWidget);
      });

      testWidgets('should show all five timeline items', (tester) async {
        await tester.pumpWidget(_buildTestWidget());
        await tester.pump();

        expect(find.text('تم إرسال الطلب'), findsOneWidget);
        expect(find.text('تم تأكيد الطلب'), findsOneWidget);
        expect(find.text('قيد التجهيز بالمطبخ'), findsOneWidget);
        expect(find.text('خارج للتوصيل'), findsOneWidget);
        expect(find.text('تم التوصيل بنجاح'), findsOneWidget);
      });

      testWidgets('should show timeline subtitles', (tester) async {
        await tester.pumpWidget(_buildTestWidget());
        await tester.pump();

        expect(find.text('طلبك وصل للمطعم وبانتظار التأكيد'), findsOneWidget);
        expect(find.text('تمت مراجعة الطلب والموافقة عليه'), findsOneWidget);
        expect(find.text('طهاة ترويقة يحضرون وجبتك اللذيذة الآن'), findsOneWidget);
        expect(find.text('عامل التوصيل استلم طلبك وهو في الطريق إليك'), findsOneWidget);
        expect(find.text('استلمت طلبك — بالهنا والشفا!'), findsOneWidget);
      });

      testWidgets('should show driver info card', (tester) async {
        await tester.pumpWidget(_buildTestWidget(status: OrderStatus.preparing));
        await tester.pump();

        expect(find.text('محمد علي (مندوب التوصيل)'), findsOneWidget);
        expect(find.textContaining('+20'), findsOneWidget);
        expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      });

      testWidgets('should show active timeline items with primary color',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(status: OrderStatus.preparing));
        await tester.pump();

        expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
        expect(find.byIcon(Icons.thumb_up_alt_outlined), findsOneWidget);
        expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('should handle short order ID gracefully', (tester) async {
        await tester.pumpWidget(
          _buildTestWidget(status: OrderStatus.pending),
        );
        await tester.pump();

        expect(find.textContaining('رقم الطلب'), findsOneWidget);
      });

      testWidgets('should render status section header', (tester) async {
        await tester.pumpWidget(_buildTestWidget());
        await tester.pump();

        expect(find.text('حالة خط سير الطلب'), findsOneWidget);
      });
    });
  });
}
