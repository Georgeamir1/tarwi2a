import 'dart:async';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/orders/customer_orders_cubit.dart';
import 'package:tarwi2a/domain/entities/order.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockOrderRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(testServerFailure);
    registerFallbackValue(testNetworkFailure);
    registerFallbackValue(<Order>[]);
    registerFallbackValue(<Map<String, dynamic>>[]);
  });

  setUp(() {
    mockRepo = MockOrderRepository();
  });

  group('CustomerOrdersCubit', () {
    group('initial state', () {
      test('should emit initial with empty orders', () {
        final cubit = CustomerOrdersCubit(mockRepo);
        expect(cubit.state, CustomerOrdersState.initial());
        expect(cubit.state.status, CustomerOrdersStatus.initial);
        expect(cubit.state.orders, isEmpty);
        expect(cubit.state.failure, isNull);
      });
    });

    group('loadOrders', () {
      test('should emit loading then loaded when orders fetched successfully',
          () async {
        when(() => mockRepo.getCustomerOrders('user-123'))
            .thenAnswer((_) async => right([testOrder]));

        final cubit = CustomerOrdersCubit(mockRepo);
        final states = <CustomerOrdersState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.loadOrders('user-123');
        await Future.delayed(const Duration(milliseconds: 10));
        await sub.cancel();

        expect(states.length, 2);
        expect(states[0].status, CustomerOrdersStatus.loading);
        expect(states[1].status, CustomerOrdersStatus.loaded);
        expect(states[1].orders, [testOrder]);
        verify(() => mockRepo.getCustomerOrders('user-123')).called(1);
      });

      test('should emit loaded with multiple orders', () async {
        when(() => mockRepo.getCustomerOrders('user-123'))
            .thenAnswer((_) async => right([testOrder, testDeliveredOrder]));

        final cubit = CustomerOrdersCubit(mockRepo);

        await cubit.loadOrders('user-123');

        expect(cubit.state.status, CustomerOrdersStatus.loaded);
        expect(cubit.state.orders.length, 2);
      });

      test('should emit loaded with empty list when no orders exist', () async {
        when(() => mockRepo.getCustomerOrders('user-123'))
            .thenAnswer((_) async => right(<Order>[]));

        final cubit = CustomerOrdersCubit(mockRepo);

        await cubit.loadOrders('user-123');

        expect(cubit.state.status, CustomerOrdersStatus.loaded);
        expect(cubit.state.orders, isEmpty);
      });

      test('should emit error when server failure occurs', () async {
        when(() => mockRepo.getCustomerOrders('user-123'))
            .thenAnswer((_) async => left(testServerFailure));

        final cubit = CustomerOrdersCubit(mockRepo);

        await cubit.loadOrders('user-123');

        expect(cubit.state.status, CustomerOrdersStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });

      test('should emit error when network failure occurs', () async {
        when(() => mockRepo.getCustomerOrders('user-123'))
            .thenAnswer((_) async => left(testNetworkFailure));

        final cubit = CustomerOrdersCubit(mockRepo);

        await cubit.loadOrders('user-123');

        expect(cubit.state.status, CustomerOrdersStatus.error);
        expect(cubit.state.failure, testNetworkFailure);
      });
    });

    group('placeOrder', () {
      test('should emit placing then placed when order created successfully',
          () async {
        when(() => mockRepo.createOrder(
              requestId: any(named: 'requestId'),
              customerId: any(named: 'customerId'),
              customerName: any(named: 'customerName'),
              customerPhone: any(named: 'customerPhone'),
              customerAddress: any(named: 'customerAddress'),
              notes: any(named: 'notes'),
              paymentMethod: any(named: 'paymentMethod'),
              totalAmount: any(named: 'totalAmount'),
              items: any(named: 'items'),
            )).thenAnswer((_) async => right(testOrder));

        final cubit = CustomerOrdersCubit(mockRepo);
        final states = <CustomerOrdersState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.placeOrder(
          customerId: 'user-123',
          customerName: 'أحمد',
          customerPhone: '01001234567',
          paymentMethod: 'cash',
          totalAmount: 150.0,
          items: [],
        );
        await Future.delayed(const Duration(milliseconds: 10));
        await sub.cancel();

        expect(states.length, 2);
        expect(states[0].status, CustomerOrdersStatus.placing);
        expect(states[1].status, CustomerOrdersStatus.placed);
      });

      test('should emit placing then error when creation fails', () async {
        when(() => mockRepo.createOrder(
              requestId: any(named: 'requestId'),
              customerId: any(named: 'customerId'),
              customerName: any(named: 'customerName'),
              customerPhone: any(named: 'customerPhone'),
              customerAddress: any(named: 'customerAddress'),
              notes: any(named: 'notes'),
              paymentMethod: any(named: 'paymentMethod'),
              totalAmount: any(named: 'totalAmount'),
              items: any(named: 'items'),
            )).thenAnswer((_) async => left(testServerFailure));

        final cubit = CustomerOrdersCubit(mockRepo);

        await cubit.placeOrder(
          customerId: 'user-123',
          customerName: 'محمد',
          customerPhone: '01001234567',
          paymentMethod: 'cash',
          totalAmount: 150.0,
          items: [],
        );

        expect(cubit.state.status, CustomerOrdersStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });

      test('should pass all optional parameters to repository', () async {
        when(() => mockRepo.createOrder(
              requestId: any(named: 'requestId'),
              customerId: 'user-123',
              customerName: 'أحمد',
              customerPhone: '0111222333',
              customerAddress: 'الجيزة',
              notes: 'توصيل سريع',
              paymentMethod: 'wallet',
              totalAmount: 250.0,
              items: [],
              scheduledFor: DateTime(2026, 6, 1),
              orderType: 'delivery',
              couponId: 'coupon-1',
              discountAmount: 25.0,
            )).thenAnswer((_) async => right(testOrder));

        final cubit = CustomerOrdersCubit(mockRepo);

        await cubit.placeOrder(
          customerId: 'user-123',
          customerName: 'أحمد',
          customerPhone: '0111222333',
          customerAddress: 'الجيزة',
          notes: 'توصيل سريع',
          paymentMethod: 'wallet',
          totalAmount: 250.0,
          items: [],
          scheduledFor: DateTime(2026, 6, 1),
          orderType: 'delivery',
          couponId: 'coupon-1',
          discountAmount: 25.0,
        );

        expect(cubit.state.status, CustomerOrdersStatus.placed);
        verify(() => mockRepo.createOrder(
              requestId: any(named: 'requestId'),
              customerId: 'user-123',
              customerName: 'أحمد',
              customerPhone: '0111222333',
              customerAddress: 'الجيزة',
              notes: 'توصيل سريع',
              paymentMethod: 'wallet',
              totalAmount: 250.0,
              items: [],
              scheduledFor: DateTime(2026, 6, 1),
              orderType: 'delivery',
              couponId: 'coupon-1',
              discountAmount: 25.0,
            )).called(1);
      });

      test('should return Either<Failure, Order> result on success and failure',
          () async {
        when(() => mockRepo.createOrder(
              requestId: any(named: 'requestId'),
              customerId: any(named: 'customerId'),
              customerName: any(named: 'customerName'),
              customerPhone: any(named: 'customerPhone'),
              customerAddress: any(named: 'customerAddress'),
              notes: any(named: 'notes'),
              paymentMethod: any(named: 'paymentMethod'),
              totalAmount: any(named: 'totalAmount'),
              items: any(named: 'items'),
            )).thenAnswer((_) async => right(testOrder));

        final cubit = CustomerOrdersCubit(mockRepo);

        final resultSuccess = await cubit.placeOrder(
          customerId: 'user-123',
          customerName: 'أحمد',
          customerPhone: '01001234567',
          paymentMethod: 'cash',
          totalAmount: 150.0,
          items: [],
        );

        expect(resultSuccess.isRight(), isTrue);
        expect(resultSuccess.getOrElse(() => throw 'error'), testOrder);

        when(() => mockRepo.createOrder(
              requestId: any(named: 'requestId'),
              customerId: any(named: 'customerId'),
              customerName: any(named: 'customerName'),
              customerPhone: any(named: 'customerPhone'),
              customerAddress: any(named: 'customerAddress'),
              notes: any(named: 'notes'),
              paymentMethod: any(named: 'paymentMethod'),
              totalAmount: any(named: 'totalAmount'),
              items: any(named: 'items'),
            )).thenAnswer((_) async => left(testServerFailure));

        final resultFailure = await cubit.placeOrder(
          customerId: 'user-123',
          customerName: 'أحمد',
          customerPhone: '01001234567',
          paymentMethod: 'cash',
          totalAmount: 150.0,
          items: [],
        );

        expect(resultFailure.isLeft(), isTrue);
      });

      test('should reject second submission when already placing', () async {
        final completer = Completer<Either<Failure, Order>>();
        when(() => mockRepo.createOrder(
              requestId: any(named: 'requestId'),
              customerId: any(named: 'customerId'),
              customerName: any(named: 'customerName'),
              customerPhone: any(named: 'customerPhone'),
              customerAddress: any(named: 'customerAddress'),
              notes: any(named: 'notes'),
              paymentMethod: any(named: 'paymentMethod'),
              totalAmount: any(named: 'totalAmount'),
              items: any(named: 'items'),
            )).thenAnswer((_) => completer.future);

        final cubit = CustomerOrdersCubit(mockRepo);

        final future1 = cubit.placeOrder(
          customerId: 'user-123',
          customerName: 'أحمد',
          customerPhone: '01001234567',
          paymentMethod: 'cash',
          totalAmount: 150.0,
          items: [],
        );

        expect(cubit.state.status, CustomerOrdersStatus.placing);

        // Second call while placing
        final result2 = await cubit.placeOrder(
          customerId: 'user-123',
          customerName: 'أحمد',
          customerPhone: '01001234567',
          paymentMethod: 'cash',
          totalAmount: 150.0,
          items: [],
        );

        expect(result2.isLeft(), isTrue);

        completer.complete(right(testOrder));
        final result1 = await future1;
        expect(result1.isRight(), isTrue);

        verify(() => mockRepo.createOrder(
              requestId: any(named: 'requestId'),
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

      test(
          'retains request ID after failure and clears it after confirmed success',
          () async {
        final cubit = CustomerOrdersCubit(mockRepo);
        expect(cubit.activeRequestId, isNull);

        // First attempt fails
        when(() => mockRepo.createOrder(
              requestId: any(named: 'requestId'),
              customerId: any(named: 'customerId'),
              customerName: any(named: 'customerName'),
              customerPhone: any(named: 'customerPhone'),
              customerAddress: any(named: 'customerAddress'),
              notes: any(named: 'notes'),
              paymentMethod: any(named: 'paymentMethod'),
              totalAmount: any(named: 'totalAmount'),
              items: any(named: 'items'),
            )).thenAnswer((_) async => left(testServerFailure));

        final result1 = await cubit.placeOrder(
          customerId: 'user-123',
          customerName: 'أحمد',
          customerPhone: '01001234567',
          paymentMethod: 'cash',
          totalAmount: 150.0,
          items: [],
        );

        expect(result1.isLeft(), isTrue);
        final retainedRequestId = cubit.activeRequestId;
        expect(retainedRequestId, isNotNull);

        // Retry attempt reuses the retained request ID
        when(() => mockRepo.createOrder(
              requestId: retainedRequestId,
              customerId: any(named: 'customerId'),
              customerName: any(named: 'customerName'),
              customerPhone: any(named: 'customerPhone'),
              customerAddress: any(named: 'customerAddress'),
              notes: any(named: 'notes'),
              paymentMethod: any(named: 'paymentMethod'),
              totalAmount: any(named: 'totalAmount'),
              items: any(named: 'items'),
            )).thenAnswer((_) async => right(testOrder));

        final result2 = await cubit.placeOrder(
          customerId: 'user-123',
          customerName: 'أحمد',
          customerPhone: '01001234567',
          paymentMethod: 'cash',
          totalAmount: 150.0,
          items: [],
        );

        expect(result2.isRight(), isTrue);
        expect(cubit.activeRequestId, isNull);
      });

      test('clears active request ID when clearActiveRequestId is invoked',
          () async {
        final cubit = CustomerOrdersCubit(mockRepo);
        when(() => mockRepo.createOrder(
              requestId: any(named: 'requestId'),
              customerId: any(named: 'customerId'),
              customerName: any(named: 'customerName'),
              customerPhone: any(named: 'customerPhone'),
              customerAddress: any(named: 'customerAddress'),
              notes: any(named: 'notes'),
              paymentMethod: any(named: 'paymentMethod'),
              totalAmount: any(named: 'totalAmount'),
              items: any(named: 'items'),
            )).thenAnswer((_) async => left(testServerFailure));

        await cubit.placeOrder(
          customerId: 'user-123',
          customerName: 'أحمد',
          customerPhone: '01001234567',
          paymentMethod: 'cash',
          totalAmount: 150.0,
          items: [],
        );

        expect(cubit.activeRequestId, isNotNull);
        cubit.clearActiveRequestId();
        expect(cubit.activeRequestId, isNull);
      });
    });
  });
}
