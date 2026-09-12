import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tarwi2a/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Customer Order Flow', () {
    testWidgets('full journey: browse → add to cart → checkout',
        (tester) async {
      const email = String.fromEnvironment('INTEGRATION_TEST_CUSTOMER_EMAIL');
      const password =
          String.fromEnvironment('INTEGRATION_TEST_CUSTOMER_PASSWORD');
      if (email.isEmpty || password.isEmpty) {
        fail(
            'Provide INTEGRATION_TEST_CUSTOMER_EMAIL and INTEGRATION_TEST_CUSTOMER_PASSWORD before launching the test app.');
      }
      // Start the app only after checking explicit test configuration.
      app.main();
      await tester.pumpAndSettle();

      // ── Login Screen ───────────────────────────────────────────
      // If not already logged in, fill credentials
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, email);
        await tester.enterText(passwordField, password);
        await tester.tap(find.text('تسجيل الدخول'));
        await tester.pumpAndSettle();
      }

      // ── Home Screen ──────────────────────────────────────────
      // Wait for home to load with categories and products
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on home (look for categories or popular section)
      expect(find.byType(ListView), findsWidgets);

      // ── Browse Menu ───────────────────────────────────────────
      // Navigate to menu tab
      await tester.tap(find.byIcon(Icons.menu_book_rounded));
      await tester.pumpAndSettle();

      // ── Product Detail ───────────────────────────────────────
      // Tap first product
      final firstProduct = find.byType(GestureDetector).first;
      await tester.tap(firstProduct);
      await tester.pumpAndSettle();

      // Tap "Add to Cart"
      await tester.tap(find.text('أضف للسلة'));
      await tester.pumpAndSettle();

      // ── Cart Screen ──────────────────────────────────────────
      // Navigate to cart
      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await tester.pumpAndSettle();

      // Verify item is in cart
      expect(find.text('إتمام الطلب'), findsOneWidget);

      // ── Checkout ──────────────────────────────────────────────
      await tester.tap(find.text('إتمام الطلب'));
      await tester.pumpAndSettle();

      // Fill checkout form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'الاسم'),
        'محمد أحمد',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'رقم الهاتف'),
        '01001234567',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'العنوان'),
        'القاهرة، مصر',
      );

      // Select cash payment
      await tester.tap(find.text('كاش عند الاستلام'));
      await tester.pumpAndSettle();

      // Place order
      await tester.tap(find.text('تأكيد الطلب'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify success dialog
      expect(find.text('تم الطلب بنجاح!'), findsOneWidget);
    });
  });
}
