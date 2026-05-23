import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:matbakhy/application/orders/customer_orders_cubit.dart';
import 'package:matbakhy/domain/entities/order.dart';
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

      test('should emit loaded with empty list when no orders exist',
          () async {
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
    });
  });
}
