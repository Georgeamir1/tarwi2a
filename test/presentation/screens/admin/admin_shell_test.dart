import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:matbakhy/presentation/screens/admin/admin_shell.dart';
import 'package:matbakhy/application/admin/admin_orders_cubit.dart';
import '../../../helpers/test_helpers.dart';

Widget _buildTestWidget({
  required AdminOrdersCubit ordersCubit,
}) {
  final router = GoRouter(
    initialLocation: '/admin',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            BlocProvider<AdminOrdersCubit>.value(
          value: ordersCubit,
          child: AdminShell(navigationShell: navigationShell),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (_, __) => const Placeholder(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/orders',
                builder: (_, __) => const Placeholder(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/menu',
                builder: (_, __) => const Placeholder(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  late MockAdminOrdersCubit mockOrdersCubit;

  setUpAll(() {
    registerFallbackValue(const AdminOrdersState());
  });

  setUp(() {
    mockOrdersCubit = MockAdminOrdersCubit();
    when(() => mockOrdersCubit.stream)
        .thenAnswer((_) => const Stream<AdminOrdersState>.empty());
    when(() => mockOrdersCubit.state).thenReturn(const AdminOrdersState(
      status: AdminOrdersStatus.loaded,
      orders: [],
    ));
  });

  group('AdminShell', () {
    testWidgets('3 bottom navigation items render', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الطلبات'), findsOneWidget);
      expect(find.text('المنيو'), findsOneWidget);
    });

    testWidgets('pending badge shows on Orders tab when pending orders exist',
        (tester) async {
      when(() => mockOrdersCubit.state).thenReturn(
        AdminOrdersState(
          status: AdminOrdersStatus.loaded,
          orders: [testOrder],
        ),
      );

      await tester.pumpWidget(_buildTestWidget(
        ordersCubit: mockOrdersCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Badge), findsOneWidget);
    });
  });
}
