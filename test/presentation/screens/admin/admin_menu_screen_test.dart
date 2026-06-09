import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:matbakhy/presentation/screens/admin/admin_menu_screen.dart';
import 'package:matbakhy/application/admin/admin_products_cubit.dart';
import 'package:matbakhy/application/admin/admin_categories_cubit.dart';
import 'package:matbakhy/domain/entities/product.dart';
import '../../../helpers/test_helpers.dart';

const _testProduct2 = Product(
  id: 'prod-2',
  categoryId: 'cat-1',
  name: 'Pepperoni',
  nameAr: 'ببروني',
  price: 85.0,
  isAvailable: true,
  sortOrder: 2,
);

GoRouter _createRouter(NavigatorObserver observer) {
  return GoRouter(
    initialLocation: '/admin/menu',
    observers: [observer],
    routes: [
      GoRoute(
        path: '/admin/menu',
        builder: (_, __) => const AdminMenuScreen(),
      ),
      GoRoute(
        path: '/admin/product/new',
        builder: (_, __) => const Placeholder(),
      ),
      GoRoute(
        path: '/admin/product/edit',
        builder: (_, __) => const Placeholder(),
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (_, __) => const Placeholder(),
      ),
    ],
  );
}

Widget _buildTestWidget({
  required AdminProductsCubit productsCubit,
  required AdminCategoriesCubit categoriesCubit,
  required NavigatorObserver observer,
}) {
  return MaterialApp.router(
    routerConfig: _createRouter(observer),
    builder: (context, child) => MultiBlocProvider(
      providers: [
        BlocProvider<AdminProductsCubit>.value(value: productsCubit),
        BlocProvider<AdminCategoriesCubit>.value(value: categoriesCubit),
      ],
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

void main() {
  late MockAdminProductsCubit mockProductsCubit;
  late MockAdminCategoriesCubit mockCategoriesCubit;

  setUpAll(() {
    registerFallbackValue(const AdminProductsState());
    registerFallbackValue(const AdminCategoriesState());
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockProductsCubit = MockAdminProductsCubit();
    mockCategoriesCubit = MockAdminCategoriesCubit();

    when(() => mockProductsCubit.stream)
        .thenAnswer((_) => const Stream<AdminProductsState>.empty());
    when(() => mockCategoriesCubit.stream)
        .thenAnswer((_) => const Stream<AdminCategoriesState>.empty());

    when(() => mockProductsCubit.state).thenReturn(
      const AdminProductsState(
        status: AdminProductsStatus.loaded,
        products: [testProduct, _testProduct2],
      ),
    );
    when(() => mockCategoriesCubit.state).thenReturn(
      const AdminCategoriesState(
        status: AdminCategoriesStatus.loaded,
        categories: [testCategory],
      ),
    );

    // Stub auto-load called from initState
    when(() => mockProductsCubit.loadProducts()).thenAnswer((_) async {});
    when(() => mockCategoriesCubit.loadCategories()).thenAnswer((_) async {});
  });

  group('AdminMenuScreen', () {
    testWidgets('shows header title and products', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        productsCubit: mockProductsCubit,
        categoriesCubit: mockCategoriesCubit,
        observer: MockNavObserver(),
      ));
      await tester.pump();

      expect(find.text('إدارة المنيو'), findsOneWidget);
      expect(find.text(testProduct.nameAr), findsOneWidget);
      expect(find.text(_testProduct2.nameAr), findsOneWidget);
    });

    testWidgets('each product shows toggle switch', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        productsCubit: mockProductsCubit,
        categoriesCubit: mockCategoriesCubit,
        observer: MockNavObserver(),
      ));
      await tester.pump();

      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('tapping toggle calls toggleAvailable', (tester) async {
      when(() => mockProductsCubit.toggleAvailable(any(), any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(_buildTestWidget(
        productsCubit: mockProductsCubit,
        categoriesCubit: mockCategoriesCubit,
        observer: MockNavObserver(),
      ));
      await tester.pump();

      await tester.tap(find.byType(Switch).first);
      await tester.pump();

      verify(() => mockProductsCubit.toggleAvailable(
            testProduct.id,
            false,
          )).called(1);
    });

    testWidgets('FAB navigates to new product form', (tester) async {
      final observer = MockNavObserver();

      await tester.pumpWidget(_buildTestWidget(
        productsCubit: mockProductsCubit,
        categoriesCubit: mockCategoriesCubit,
        observer: observer,
      ));
      await tester.pump();

      await tester.tap(find.text('صنف جديد'));
      await tester.pumpAndSettle();

      verify(() => observer.didPush(any(), any())).called(2);
    });

    testWidgets('tapping product card navigates to edit form', (tester) async {
      final observer = MockNavObserver();

      await tester.pumpWidget(_buildTestWidget(
        productsCubit: mockProductsCubit,
        categoriesCubit: mockCategoriesCubit,
        observer: observer,
      ));
      await tester.pump();

      await tester.tap(find.text(testProduct.nameAr));
      await tester.pumpAndSettle();

      verify(() => observer.didPush(any(), any())).called(2);
    });
  });
}

class MockNavObserver extends Mock implements NavigatorObserver {}
