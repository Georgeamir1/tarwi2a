import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import 'package:tarwi2a/infrastructure/dtos/order_dto.dart';
import 'package:tarwi2a/infrastructure/repositories/order_repository_impl.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockOrderRemoteDataSource mockDS;
  late OrderRepositoryImpl repo;

  final testOrderDTO = OrderDTO(
    id: 'order-1',
    customerId: 'user-123',
    customerName: 'محمد',
    customerPhone: '01001234567',
    customerAddress: 'القاهرة',
    notes: 'بدون بصل',
    paymentMethod: 'cash',
    status: 'pending',
    totalAmount: 150.0,
    createdAt: DateTime(2026, 5, 1, 10, 0),
    updatedAt: DateTime(2026, 5, 1, 10, 0),
    items: [],
  );

  setUp(() {
    mockDS = MockOrderRemoteDataSource();
    repo = OrderRepositoryImpl(mockDS);
  });

  group('createOrder', () {
    test('returns Right(Order) on success', () async {
      when(() => mockDS.createOrder(
            orderData: any(named: 'orderData'),
            itemsData: any(named: 'itemsData'),
          )).thenAnswer((_) async => testOrderDTO);

      final result = await repo.createOrder(
        customerId: 'user-123',
        customerName: 'محمد',
        customerPhone: '01001234567',
        customerAddress: 'القاهرة',
        notes: 'بدون بصل',
        paymentMethod: 'cash',
        totalAmount: 150.0,
        items: [],
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (order) {
          expect(order.id, 'order-1');
          expect(order.customerName, 'محمد');
        },
      );
    });

    test('returns Left(Failure) on exception', () async {
      when(() => mockDS.createOrder(
            orderData: any(named: 'orderData'),
            itemsData: any(named: 'itemsData'),
          )).thenThrow(Exception('test error'));

      final result = await repo.createOrder(
        customerId: 'user-123',
        customerName: 'محمد',
        customerPhone: '01001234567',
        paymentMethod: 'cash',
        totalAmount: 100.0,
        items: [],
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getCustomerOrders', () {
    test('returns Right with Orders on success', () async {
      when(() => mockDS.getCustomerOrders(any()))
          .thenAnswer((_) async => [testOrderDTO]);

      final result = await repo.getCustomerOrders('user-123');

      expect(result.isRight(), isTrue);
      verify(() => mockDS.getCustomerOrders('user-123')).called(1);
    });

    test('returns Left(Failure) on failure', () async {
      when(() => mockDS.getCustomerOrders(any()))
          .thenThrow(Exception('test error'));

      final result = await repo.getCustomerOrders('user-123');

      expect(result.isLeft(), isTrue);
    });
  });

  group('getAllAdmin', () {
    test('returns Right with Orders on success', () async {
      when(() => mockDS.getAllAdmin()).thenAnswer((_) async => [testOrderDTO]);

      final result = await repo.getAllAdmin();

      expect(result.isRight(), isTrue);
    });

    test('returns Left(Failure) on failure', () async {
      when(() => mockDS.getAllAdmin()).thenThrow(Exception('test error'));

      final result = await repo.getAllAdmin();

      expect(result.isLeft(), isTrue);
    });
  });

  group('updateStatus', () {
    test('returns Right(void) and delegates to DS on success', () async {
      when(() => mockDS.updateStatus(any(), any())).thenAnswer((_) async {});

      final result = await repo.updateStatus('order-1', 'confirmed');

      expect(result.isRight(), isTrue);
      verify(() => mockDS.updateStatus('order-1', 'confirmed')).called(1);
    });

    test('returns Left(Failure) on failure', () async {
      when(() => mockDS.updateStatus(any(), any()))
          .thenThrow(Exception('test error'));

      final result = await repo.updateStatus('order-1', 'confirmed');

      expect(result.isLeft(), isTrue);
    });
  });

  group('watchOrders', () {
    test('delegates to data source stream', () {
      final testStream = Stream.value(<Map<String, dynamic>>[]);
      when(() => mockDS.watchOrders()).thenAnswer((_) => testStream);

      final result = repo.watchOrders();

      expect(result, same(testStream));
    });
  });
}
