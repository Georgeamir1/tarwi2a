import 'dart:async';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:matbakhy/application/admin/admin_orders_cubit.dart';
import 'package:matbakhy/domain/entities/order.dart';
import 'package:matbakhy/domain/failures/failure.dart';
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
    when(() => mockRepo.watchOrders()).thenAnswer((_) => const Stream.empty());
  });

  group('AdminOrdersCubit', () {
    group('initial state', () {
      test('should emit initial with empty orders', () {
        final cubit = AdminOrdersCubit(mockRepo);
        expect(cubit.state, AdminOrdersState.initial());
        expect(cubit.state.status, AdminOrdersStatus.initial);
        expect(cubit.state.orders, isEmpty);
        expect(cubit.state.failure, isNull);
      });
    });

    group('loadOrders', () {
      test('should emit loading then loaded on success', () async {
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => right([testOrder]));

        final cubit = AdminOrdersCubit(mockRepo);
        final states = <AdminOrdersState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.loadOrders();
        await Future.delayed(const Duration(milliseconds: 10));
        await sub.cancel();

        expect(states.length, 2);
        expect(states[0].status, AdminOrdersStatus.loading);
        expect(states[1].status, AdminOrdersStatus.loaded);
        expect(states[1].orders, contains(testOrder));
        verify(() => mockRepo.getAllAdmin()).called(1);
      });

      test('should emit error on failure', () async {
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => left(testServerFailure));

        final cubit = AdminOrdersCubit(mockRepo);
        await cubit.loadOrders();

        expect(cubit.state.status, AdminOrdersStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });

      test('should load multiple orders with different statuses', () async {
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => right([testOrder, testDeliveredOrder]));

        final cubit = AdminOrdersCubit(mockRepo);
        await cubit.loadOrders();

        expect(cubit.state.status, AdminOrdersStatus.loaded);
        expect(cubit.state.orders.length, 2);
      });
    });

    group('updateStatus', () {
      test('should call updateStatus then reload orders', () async {
        when(() => mockRepo.updateStatus(any(), any()))
            .thenAnswer((_) async => right<Failure, void>(null));
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => right([testOrder]));

        final cubit = AdminOrdersCubit(mockRepo);
        await cubit.updateStatus('order-1', 'preparing');
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockRepo.updateStatus('order-1', 'preparing')).called(1);
        verify(() => mockRepo.getAllAdmin()).called(1);
        expect(cubit.state.status, AdminOrdersStatus.loaded);
      });
    });

    group('realtime', () {
      test('should subscribe to watchOrders stream on load', () async {
        final controller =
            StreamController<List<Map<String, dynamic>>>.broadcast();
        when(() => mockRepo.watchOrders()).thenAnswer((_) => controller.stream);
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => right([testOrder]));

        final cubit = AdminOrdersCubit(mockRepo);
        await cubit.loadOrders();

        expect(controller.hasListener, isTrue);

        await cubit.close();
        expect(controller.hasListener, isFalse);
        await controller.close();
      });
    });

    group('close', () {
      test('should not throw when closed without listeners', () async {
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => right([testOrder]));

        final cubit = AdminOrdersCubit(mockRepo);
        await cubit.loadOrders();
        await cubit.close();
      });
    });
  });
}
