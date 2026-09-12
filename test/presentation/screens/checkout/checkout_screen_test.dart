import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:tarwi2a/presentation/screens/checkout/checkout_screen.dart';
import 'package:tarwi2a/application/auth/auth_cubit.dart';
import 'package:tarwi2a/application/cart/cart_cubit.dart';
import 'package:tarwi2a/application/orders/customer_orders_cubit.dart';
import 'package:tarwi2a/application/coupon/coupon_cubit.dart';
import 'package:tarwi2a/domain/repositories/business_profile_repository.dart';
import 'package:tarwi2a/domain/repositories/coupon_repository.dart';
import 'package:tarwi2a/core/di/injection_container.dart';
import 'package:tarwi2a/app/theme/app_theme.dart';
import '../../../helpers/test_helpers.dart';

Widget _buildTestWidget({
  required AuthCubit authCubit,
  required CartCubit cartCubit,
  required CustomerOrdersCubit ordersCubit,
  DateTime Function()? nowProvider,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<CartCubit>.value(value: cartCubit),
        BlocProvider<CustomerOrdersCubit>.value(value: ordersCubit),
      ],
      child: CheckoutScreen(nowProvider: nowProvider),
    ),
  );
}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockCartCubit mockCartCubit;
  late MockCustomerOrdersCubit mockOrdersCubit;
  late MockCouponCubit mockCouponCubit;
  late MockBusinessProfileRepository mockBusinessProfileRepo;
  late MockCouponRepository mockCouponRepo;

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
    when(() => mockCartCubit.clearDeliveryZone()).thenReturn(null);

    mockOrdersCubit = MockCustomerOrdersCubit();
    when(() => mockOrdersCubit.state).thenReturn(CustomerOrdersState.initial());
    when(() => mockOrdersCubit.stream)
        .thenAnswer((_) => const Stream<CustomerOrdersState>.empty());
    when(() => mockOrdersCubit.clearActiveRequestId()).thenReturn(null);
    when(() => mockOrdersCubit.placeOrder(
          requestId: any(named: 'requestId'),
          customerId: any(named: 'customerId'),
          customerName: any(named: 'customerName'),
          customerPhone: any(named: 'customerPhone'),
          customerAddress: any(named: 'customerAddress'),
          addressId: any(named: 'addressId'),
          notes: any(named: 'notes'),
          paymentMethod: any(named: 'paymentMethod'),
          totalAmount: any(named: 'totalAmount'),
          items: any(named: 'items'),
          scheduledFor: any(named: 'scheduledFor'),
          orderType: any(named: 'orderType'),
          couponId: any(named: 'couponId'),
          couponCode: any(named: 'couponCode'),
          discountAmount: any(named: 'discountAmount'),
          deliveryFee: any(named: 'deliveryFee'),
          deliveryZoneId: any(named: 'deliveryZoneId'),
          deliveryZoneName: any(named: 'deliveryZoneName'),
        )).thenAnswer((_) async => right(testOrder));
    when(() => mockOrdersCubit.loadOrders(any())).thenAnswer((_) async {});

    if (sl.isRegistered<CustomerOrdersCubit>()) {
      sl.unregister<CustomerOrdersCubit>();
    }
    sl.registerSingleton<CustomerOrdersCubit>(mockOrdersCubit);

    mockCouponCubit = MockCouponCubit();
    when(() => mockCouponCubit.state).thenReturn(const CouponState());
    when(() => mockCouponCubit.stream)
        .thenAnswer((_) => const Stream<CouponState>.empty());
    when(() => mockCouponCubit.close()).thenAnswer((_) async {});
    if (sl.isRegistered<CouponCubit>()) {
      sl.unregister<CouponCubit>();
    }
    sl.registerFactory<CouponCubit>(() => mockCouponCubit);

    mockBusinessProfileRepo = MockBusinessProfileRepository();
    when(() => mockBusinessProfileRepo.get())
        .thenAnswer((_) async => right(testBusinessProfile));
    if (sl.isRegistered<BusinessProfileRepository>()) {
      sl.unregister<BusinessProfileRepository>();
    }
    sl.registerLazySingleton<BusinessProfileRepository>(
        () => mockBusinessProfileRepo);

    mockCouponRepo = MockCouponRepository();
    when(() => mockCouponRepo.getByCode(any()))
        .thenAnswer((_) async => right(testCoupon));
    when(() => mockCouponRepo.incrementUsage(any()))
        .thenAnswer((_) async => right(null));
    if (sl.isRegistered<CouponRepository>()) {
      sl.unregister<CouponRepository>();
    }
    sl.registerLazySingleton<CouponRepository>(() => mockCouponRepo);

    when(() => mockCartCubit.close()).thenAnswer((_) async {});
    when(() => mockAuthCubit.close()).thenAnswer((_) async {});
    when(() => mockOrdersCubit.close()).thenAnswer((_) async {});

    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    if (binding.platformDispatcher.views.isNotEmpty) {
      final view = binding.platformDispatcher.views.first;
      if (view is TestFlutterView) {
        view.physicalSize = const Size(800, 2000);
        view.devicePixelRatio = 1.0;
      }
    }
  });

  tearDown(() {
    if (sl.isRegistered<CustomerOrdersCubit>()) {
      sl.unregister<CustomerOrdersCubit>();
    }
    if (sl.isRegistered<CouponCubit>()) {
      sl.unregister<CouponCubit>();
    }
    if (sl.isRegistered<BusinessProfileRepository>()) {
      sl.unregister<BusinessProfileRepository>();
    }
    if (sl.isRegistered<CouponRepository>()) {
      sl.unregister<CouponRepository>();
    }

    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    if (binding.platformDispatcher.views.isNotEmpty) {
      final view = binding.platformDispatcher.views.first;
      if (view is TestFlutterView) {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      }
    }
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

        expect(find.text('بيانات التوصيل والتواصل'), findsOneWidget);
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

        await tester.tap(find.text('استلام من الفرع'));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('تأكيد الطلب'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('تأكيد الطلب'));
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

        await tester.tap(find.text('استلام من الفرع'));
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
              addressId: any(named: 'addressId'),
              notes: any(named: 'notes'),
              paymentMethod: any(named: 'paymentMethod'),
              totalAmount: any(named: 'totalAmount'),
              items: any(named: 'items'),
              scheduledFor: any(named: 'scheduledFor'),
              orderType: any(named: 'orderType'),
              couponId: any(named: 'couponId'),
              discountAmount: any(named: 'discountAmount'),
              deliveryFee: any(named: 'deliveryFee'),
              deliveryZoneId: any(named: 'deliveryZoneId'),
              deliveryZoneName: any(named: 'deliveryZoneName'),
            )).called(1);
      });

      testWidgets('success dialog appears after placing order', (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          ordersCubit: mockOrdersCubit,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('استلام من الفرع'));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('تأكيد الطلب'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('تأكيد الطلب'));
        await tester.pumpAndSettle();

        expect(find.text('تم الطلب بنجاح!'), findsOneWidget);
        expect(find.textContaining('هنتواصل معاك في أقرب وقت'), findsOneWidget);
        expect(find.text('شوف طلباتي'), findsOneWidget);
      });

      testWidgets(
          'switching order type to pickup or dineIn clears delivery zone',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          ordersCubit: mockOrdersCubit,
        ));
        await tester.pumpAndSettle();

        // Switch to pickup
        await tester.tap(find.text('استلام من الفرع'));
        await tester.pumpAndSettle();

        verify(() => mockCartCubit.clearDeliveryZone()).called(1);

        // Switch to dineIn
        await tester.tap(find.text('تناول في المطعم'));
        await tester.pumpAndSettle();

        verify(() => mockCartCubit.clearDeliveryZone()).called(1);
      });

      testWidgets(
          'delivery requires selecting address and blocks submission if null',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          ordersCubit: mockOrdersCubit,
        ));
        await tester.pumpAndSettle();

        // Initially delivery, no address selected
        await tester.scrollUntilVisible(
          find.text('تأكيد الطلب'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('تأكيد الطلب'));
        await tester.pumpAndSettle();

        expect(find.text('من فضلك اختر أو أضف عنواناً للتوصيل أولاً'),
            findsOneWidget);
        verifyNever(() => mockOrdersCubit.placeOrder(
              customerId: any(named: 'customerId'),
              customerName: any(named: 'customerName'),
              customerPhone: any(named: 'customerPhone'),
              paymentMethod: any(named: 'paymentMethod'),
              totalAmount: any(named: 'totalAmount'),
              items: any(named: 'items'),
            ));
      });

      testWidgets(
          'order placement failure displays error SnackBar, does not clear cart, and does not show dialog',
          (tester) async {
        when(() => mockOrdersCubit.placeOrder(
              customerId: any(named: 'customerId'),
              customerName: any(named: 'customerName'),
              customerPhone: any(named: 'customerPhone'),
              customerAddress: any(named: 'customerAddress'),
              addressId: any(named: 'addressId'),
              notes: any(named: 'notes'),
              paymentMethod: any(named: 'paymentMethod'),
              totalAmount: any(named: 'totalAmount'),
              items: any(named: 'items'),
              scheduledFor: any(named: 'scheduledFor'),
              orderType: any(named: 'orderType'),
              couponId: any(named: 'couponId'),
              discountAmount: any(named: 'discountAmount'),
              deliveryFee: any(named: 'deliveryFee'),
              deliveryZoneId: any(named: 'deliveryZoneId'),
              deliveryZoneName: any(named: 'deliveryZoneName'),
            )).thenAnswer(
          (_) async => left(testServerFailure),
        );

        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          ordersCubit: mockOrdersCubit,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('استلام من الفرع'));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('تأكيد الطلب'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('تأكيد الطلب'));
        await tester.pumpAndSettle();

        expect(find.textContaining('فشل إنشاء الطلب'), findsOneWidget);
        verifyNever(() => mockCartCubit.clearCart());
        expect(find.text('تم الطلب بنجاح!'), findsNothing);
      });

      testWidgets(
          'order placement does not call CouponRepository.incrementUsage',
          (tester) async {
        when(() => mockCartCubit.state).thenReturn(
          const CartState(
            items: [testCartItem],
            appliedCouponId: 'coupon-xyz',
            discountAmount: 10,
          ),
        );

        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          ordersCubit: mockOrdersCubit,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('استلام من الفرع'));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('تأكيد الطلب'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('تأكيد الطلب'));
        await tester.pumpAndSettle();

        // UI must NEVER call incrementUsage directly (Clean Architecture enforcement)
        verifyNever(() => mockCouponRepo.incrementUsage(any()));
      });
    });
  });
}
