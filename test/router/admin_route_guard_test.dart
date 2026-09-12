import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tarwi2a/domain/enums/user_role.dart';
import 'package:tarwi2a/router/admin_route_guard.dart';

void main() {
  group('adminRouteRedirect table tests', () {
    final testCases = <({String path, UserRole? role, String? expected})>[
      // Exact /admin route
      (path: '/admin', role: null, expected: '/login'),
      (path: '/admin', role: UserRole.customer, expected: '/home'),
      (path: '/admin', role: UserRole.admin, expected: null),

      // Sub-route /admin/...
      (path: '/admin/orders/order-a', role: null, expected: '/login'),
      (
        path: '/admin/orders/order-a',
        role: UserRole.customer,
        expected: '/home'
      ),
      (path: '/admin/orders/order-a', role: UserRole.admin, expected: null),

      // Edge cases: similar prefixes that are NOT admin routes
      (path: '/administrator', role: null, expected: null),
      (path: '/administrator', role: UserRole.customer, expected: null),
      (path: '/administrator', role: UserRole.admin, expected: null),

      // Non-admin app routes
      (path: '/home', role: null, expected: null),
      (path: '/home', role: UserRole.customer, expected: null),
      (path: '/home', role: UserRole.admin, expected: null),

      (path: '/login', role: null, expected: null),
      (path: '/splash', role: null, expected: null),
    ];

    for (final tc in testCases) {
      test(
          'path: "${tc.path}" with role: ${tc.role} redirects to "${tc.expected}"',
          () {
        final result = adminRouteRedirect(path: tc.path, role: tc.role);
        expect(result, tc.expected);
      });
    }
  });

  group('adminRouteRedirect widget navigation tests', () {
    late ValueNotifier<UserRole?> roleNotifier;
    late GoRouter testRouter;

    setUp(() {
      roleNotifier = ValueNotifier<UserRole?>(UserRole.admin);
      testRouter = GoRouter(
        initialLocation: '/admin/sub',
        refreshListenable: roleNotifier,
        redirect: (context, state) {
          return adminRouteRedirect(
            path: state.matchedLocation,
            role: roleNotifier.value,
          );
        },
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(
              body: Text('Login Screen'),
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Text('Home Screen'),
            ),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const Scaffold(
              body: Text('Admin Dashboard'),
            ),
            routes: [
              GoRoute(
                path: 'sub',
                builder: (context, state) => const Scaffold(
                  body: Text('Admin Subpage'),
                ),
              ),
            ],
          ),
        ],
      );
    });

    tearDown(() {
      testRouter.dispose();
      roleNotifier.dispose();
    });

    testWidgets(
        'allows admin to access /admin/sub, then redirects to /home when role changes to customer',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Admin has access initially
      expect(find.text('Admin Subpage'), findsOneWidget);

      // Change role to customer
      roleNotifier.value = UserRole.customer;
      await tester.pumpAndSettle();

      // Automatically redirected to /home
      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.text('Admin Subpage'), findsNothing);
    });

    testWidgets(
        'redirects unauthenticated user to /login when attempting to access /admin',
        (tester) async {
      roleNotifier.value = null;

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
      expect(find.text('Admin Subpage'), findsNothing);
    });

    testWidgets(
        'redirects customer directly to /home when navigating to /admin',
        (tester) async {
      roleNotifier.value = UserRole.customer;

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.text('Admin Subpage'), findsNothing);
    });
  });
}
