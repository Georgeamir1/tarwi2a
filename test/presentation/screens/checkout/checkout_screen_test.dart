import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:matbakhy/presentation/screens/checkout/checkout_screen.dart';
import 'package:matbakhy/application/auth/auth_cubit.dart';
import 'package:matbakhy/application/cart/cart_cubit.dart';
import 'package:matbakhy/application/orders/customer_orders_cubit.dart';
import 'package:matbakhy/app/theme/app_theme.dart';
import '../../../helpers/test_helpers.dart';

Widget _buildTestWidget({
  required AuthCubit authCubit,
  required CartCubit cartCubit,
  required CustomerOrdersCubit ordersCubit,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<CartCubit>.value(value: cartCubit),
        BlocProvider<CustomerOrdersCubit>.value(value: ordersCubit),
      ],
      child: const CheckoutScreen(),
    ),
  );
}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockCartCubit mockCartCubit;
  late MockCustomerOrdersCubit mockOrdersCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state)
        .thenReturn(AuthState.authenticated(testUserProfile));
    when(() => mockAuthCubit.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());

    mockCartCubit = MockCartCubit();
    when(() => mockCartCubit.state).thenReturn(
      const CartState(items: [testCartItem]),
    );
    when(() => mockCartCubit.stream)
        .thenAnswer((_) => const Stream<CartState>.empty());
    when(() => mockCartCubit.clearCart()).thenReturn(null);

    mockOrdersCubit = MockCustomerOrdersCubit();
    when(() => mockOrdersCubit.state).thenReturn(CustomerOrdersState.initial());
    when(() => mockOrdersCubit.stream)
        .thenAnswer((_) => const Stream<CustomerOrdersState>.empty());
    when(() => mockOrdersCubit.placeOrder(
          customerId: any(named: 'customerId'),
          customerName: any(named: 'customerName'),
          customerPhone: any(named: 'customerPhone'),
          customerAddress: any(named: 'customerAddress'),
          notes: any(named: 'notes'),
          paymentMethod: any(named: 'paymentMethod'),
          totalAmount: any(named: 'totalAmount'),
          items: any(named: 'items'),
        )).thenAnswer((_) async {});

    when(() => mockCartCubit.close()).thenAnswer((_) async {});
    when(() => mockAuthCubit.close()).thenAnswer((_) async {});
    when(() => mockOrdersCubit.close()).thenAnswer((_) async {});
  });

  group('CheckoutScreen', () {
    group('render', () {
      testWidgets('form pre-filled with user name and phone from AuthCubit',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          ordersCubit: mockOrdersCubit,
        ));
        await tester.pumpAndSettle();

        final nameField = tester.widget<TextFormField>(
          find.widgetWithText(TextFormField, 'الاسم'),
        );
        expect(nameField.controller?.text, 'محمد');

        final phoneField = tester.widget<TextFormField>(
          find.widgetWithText(TextFormField, 'رقم الهاتف'),
        );
        expect(phoneField.controller?.text, '01001234567');
      });

      testWidgets('all 3 payment methods visible', (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          ordersCubit: mockOrdersCubit,
        ));
        await tester.pumpAndSettle();

        expect(find.text('كاش عند الاستلام'), findsOneWidget);
        expect(find.text('محفظة إلكترونية'), findsOneWidget);
        expect(find.text('InstaPay'), findsOneWidget);
      });

      testWidgets('shows checkout form sections', (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          ordersCubit: mockOrdersCubit,
        ));
        await tester.pumpAndSettle();

        expect(find.text('📍 بيانات الطلب'), findsOneWidget);
        expect(find.byType(TextFormField), findsWidgets);
      });
    });

    group('form validation', () {
      testWidgets('shows validation errors on empty required fields',
          (tester) async {
        when(() => mockAuthCubit.state).thenReturn(const AuthState.initial());

        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          ordersCubit: mockOrdersCubit,
        ));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.tap(find.text('تأكيد الطلب'));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(0, 500));
        await tester.pumpAndSettle();

        expect(find.text('أدخل اسمك'), findsOneWidget);
        expect(find.text('أدخل رقم الهاتف'), findsOneWidget);
      });
    });

    group('payment method selection', () {
      testWidgets('tapping payment method selects it', (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          ordersCubit: mockOrdersCubit,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('محفظة إلكترونية'));
        await tester.pumpAndSettle();

        final checkIcons = find.byIcon(Icons.check_circle_rounded);
        expect(checkIcons, findsOneWidget);
      });
    });

    group('place order', () {
      testWidgets('place order button calls CustomerOrdersCubit.placeOrder',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          ordersCubit: mockOrdersCubit,
        ));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('تأكيد الطلب'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('تأكيد الطلب'));
        await tester.pumpAndSettle();

        verify(() => mockOrdersCubit.placeOrder(
              customerId: any(named: 'customerId'),
              customerName: any(named: 'customerName'),
              customerPhone: any(named: 'customerPhone'),
              customerAddress: any(named: 'customerAddress'),
              notes: any(named: 'notes'),
              paymentMethod: any(named: 'paymentMethod'),
              totalAmount: any(named: 'totalAmount'),
              items: any(named: 'items'),
            )).called(1);
      });

      testWidgets('success dialog appears after placing order', (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          ordersCubit: mockOrdersCubit,
        ));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('تأكيد الطلب'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('تأكيد الطلب'));
        await tester.pumpAndSettle();

        expect(find.text('تم الطلب بنجاح! 🎉'), findsOneWidget);
        expect(find.text('هنتواصل معاك في أقرب وقت'), findsOneWidget);
        expect(find.text('شوف طلباتي'), findsOneWidget);
      });
    });
  });
}
