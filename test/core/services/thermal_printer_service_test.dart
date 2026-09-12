import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:tarwi2a/core/services/thermal_printer_service.dart';
import 'package:tarwi2a/domain/entities/order.dart';
import 'package:tarwi2a/domain/entities/order_item.dart';
import 'package:tarwi2a/domain/enums/order_status.dart';
import 'package:tarwi2a/domain/enums/payment_method.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testOrder = Order(
    id: 'ord-12345678',
    customerId: 'cust-1',
    customerName: 'محمد أحمد',
    customerPhone: '01001234567',
    customerAddress: 'الدقي، الجيزة',
    notes: 'بدون شطة',
    paymentMethod: PaymentMethod.cash,
    status: OrderStatus.confirmed,
    totalAmount: 250.0,
    createdAt: DateTime(2026, 5, 1, 14, 30),
    updatedAt: DateTime(2026, 5, 1, 14, 30),
    items: const [
      OrderItem(
        id: 'item-1',
        orderId: 'ord-12345678',
        productId: 'prod-1',
        productName: 'فطيرة مشلتت',
        productPrice: 120.0,
        quantity: 2,
        subtotal: 240.0,
      ),
    ],
  );

  group('ThermalPrinterService', () {
    test('printOrder returns true when layoutPdf succeeds', () async {
      final service = ThermalPrinterService(
        layoutPdf: (onLayout, {PdfPageFormat? format, String? name}) async {
          expect(name, 'Order_ord-12345678');
          final bytes = onLayout(format ?? PdfPageFormat.roll80);
          expect(bytes, isNotEmpty);
          return true;
        },
      );

      final result = await service.printOrder(testOrder);
      expect(result, isTrue);
    });

    test('printOrder returns false when user cancels print layout dialog',
        () async {
      final service = ThermalPrinterService(
        layoutPdf: (onLayout, {PdfPageFormat? format, String? name}) async {
          return false;
        },
      );

      final result = await service.printOrder(testOrder);
      expect(result, isFalse);
    });

    test('printOrder catches cancellation exception and returns false',
        () async {
      final service = ThermalPrinterService(
        layoutPdf: (onLayout, {PdfPageFormat? format, String? name}) async {
          throw Exception('User cancelled printing');
        },
      );

      final result = await service.printOrder(testOrder);
      expect(result, isFalse);
    });

    test('printOrder rethrows non-cancellation exception', () async {
      final service = ThermalPrinterService(
        layoutPdf: (onLayout, {PdfPageFormat? format, String? name}) async {
          throw PlatformException(
              code: 'PRINT_ERROR', message: 'Printer disconnected');
        },
      );

      expect(() => service.printOrder(testOrder),
          throwsA(isA<PlatformException>()));
    });
  });
}
