import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/core/services/thermal_printer_service.dart';
import 'package:tarwi2a/domain/entities/order.dart';
import 'package:tarwi2a/domain/enums/order_status.dart';
import 'package:tarwi2a/domain/enums/payment_method.dart';
import 'package:tarwi2a/infrastructure/repositories/print_repository_impl.dart';

class MockThermalPrinterService extends Mock implements ThermalPrinterService {}

void main() {
  late MockThermalPrinterService mockService;
  late PrintRepositoryImpl repo;

  final testOrder = Order(
    id: 'ord-12345678',
    customerId: 'cust-1',
    customerName: 'محمد أحمد',
    customerPhone: '01001234567',
    customerAddress: 'الدقي، الجيزة',
    paymentMethod: PaymentMethod.cash,
    status: OrderStatus.confirmed,
    totalAmount: 150.0,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
    items: const [],
  );

  setUp(() {
    mockService = MockThermalPrinterService();
    repo = PrintRepositoryImpl(mockService);
  });

  group('PrintRepositoryImpl', () {
    test('returns Right(true) when printer service succeeds', () async {
      when(() => mockService.printOrder(testOrder))
          .thenAnswer((_) async => true);

      final result = await repo.printOrder(testOrder);

      expect(result, const Right(true));
      verify(() => mockService.printOrder(testOrder)).called(1);
    });

    test('returns Right(false) when print is cancelled', () async {
      when(() => mockService.printOrder(testOrder))
          .thenAnswer((_) async => false);

      final result = await repo.printOrder(testOrder);

      expect(result, const Right(false));
      verify(() => mockService.printOrder(testOrder)).called(1);
    });

    test('returns Left(Failure.unexpected) when printer service throws',
        () async {
      when(() => mockService.printOrder(testOrder))
          .thenThrow(Exception('Paper jam'));

      final result = await repo.printOrder(testOrder);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('فشل في الطباعة')),
        (_) => fail('should be Left'),
      );
    });
  });
}
