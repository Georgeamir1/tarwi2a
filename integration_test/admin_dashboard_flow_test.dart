import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tarwi2a/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Dashboard Flow', () {
    testWidgets('admin login → view dashboard → manage orders', (tester) async {
      const email = String.fromEnvironment('INTEGRATION_TEST_ADMIN_EMAIL');
      const password =
          String.fromEnvironment('INTEGRATION_TEST_ADMIN_PASSWORD');
      if (email.isEmpty || password.isEmpty) {
        fail(
            'Provide INTEGRATION_TEST_ADMIN_EMAIL and INTEGRATION_TEST_ADMIN_PASSWORD before launching the test app.');
      }
      // Start the app only after checking explicit test configuration.
      app.main();
      await tester.pumpAndSettle();

      // ── Login as Admin ───────────────────────────────────────
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, email);
        await tester.enterText(passwordField, password);
        await tester.tap(find.text('تسجيل الدخول'));
        await tester.pumpAndSettle();
      }

      // ── Admin Dashboard ────────────────────────────────────
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify dashboard loads with KPI cards
      expect(find.text('لوحة التحكم'), findsOneWidget);
      expect(find.text('إجمالي المبيعات'), findsOneWidget);

      // ── Navigate to Orders ──────────────────────────────────
      await tester.tap(find.text('إدارة الطلبات'));
      await tester.pumpAndSettle();

      // Verify orders list
      expect(find.text('إدارة الطلبات'), findsOneWidget);

      // ── Tap first order ───────────────────────────────────
      final firstOrder = find.byType(ListTile).first;
      if (firstOrder.evaluate().isNotEmpty) {
        await tester.tap(firstOrder);
        await tester.pumpAndSettle();

        // Order detail screen
        expect(find.text('بيانات العميل'), findsOneWidget);

        // Update status if button exists
        final confirmButton = find.text('تأكيد الطلب');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
