import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:matbakhy/presentation/screens/orders/order_tracking_screen.dart';
import 'package:matbakhy/app/theme/app_theme.dart';

Widget _buildTestWidget({String status = 'confirmed'}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: OrderTrackingScreen(
      orderId: 'order-001-abc-def',
      status: status,
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
        expect(find.textContaining('order-'), findsOneWidget);
      });

      testWidgets('should show estimated delivery time', (tester) async {
        await tester.pumpWidget(_buildTestWidget());
        await tester.pump();

        expect(find.textContaining('الوقت المتوقع'), findsOneWidget);
        expect(find.textContaining('دقيقة'), findsOneWidget);
      });

      testWidgets('should show all four timeline items', (tester) async {
        await tester.pumpWidget(_buildTestWidget());
        await tester.pump();

        expect(find.text('تم استلام الطلب'), findsOneWidget);
        expect(find.text('قيد التجهيز'), findsOneWidget);
        expect(find.text('في الطريق'), findsOneWidget);
        expect(find.text('تم التوصيل'), findsOneWidget);
      });

      testWidgets('should show timeline subtitles', (tester) async {
        await tester.pumpWidget(_buildTestWidget());
        await tester.pump();

        expect(find.text('طلبك وصل للمطعم'), findsOneWidget);
        expect(find.text('الشيف بيحضر طلبك'), findsOneWidget);
        expect(find.text('عامل التوصيل في الطريق ليك'), findsOneWidget);
        expect(find.text('استلمت طلبك — بالهنا والشفا'), findsOneWidget);
      });

      testWidgets('should show driver info card', (tester) async {
        await tester.pumpWidget(_buildTestWidget());
        await tester.pump();

        expect(find.text('محمد علي'), findsOneWidget);
        expect(find.textContaining('+20'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('should show active timeline items with primary color',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.receipt_long), findsOneWidget);
        expect(find.byIcon(Icons.restaurant), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('should handle short order ID gracefully', (tester) async {
        await tester.pumpWidget(
          _buildTestWidget(status: 'pending'),
        );
        await tester.pump();

        expect(find.textContaining('رقم الطلب'), findsOneWidget);
      });

      testWidgets('should render status section header', (tester) async {
        await tester.pumpWidget(_buildTestWidget());
        await tester.pump();

        expect(find.text('حالة الطلب'), findsOneWidget);
      });
    });
  });
}
