import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:matbakhy/presentation/screens/home/home_screen.dart';
import 'package:matbakhy/application/auth/auth_cubit.dart';
import 'package:matbakhy/application/menu/categories_cubit.dart';
import 'package:matbakhy/application/menu/products_cubit.dart';
import 'package:matbakhy/application/cart/cart_cubit.dart';
import 'package:matbakhy/domain/entities/category.dart';
import 'package:matbakhy/domain/entities/product.dart';
import 'package:matbakhy/app/theme/app_theme.dart';
import '../../../helpers/test_helpers.dart';

const testCategory2 = Category(
  id: 'cat-2',
  name: 'Drinks',
  nameAr: 'مشروبات',
  imageUrl: null,
  sortOrder: 2,
  isActive: true,
);

const testProduct2 = Product(
  id: 'prod-2',
  categoryId: 'cat-1',
  name: 'Pepsi',
  nameAr: 'بيبسي',
  price: 15.0,
  isAvailable: true,
  sortOrder: 2,
);

Widget _buildTestWidget({
  required AuthCubit authCubit,
  required CartCubit cartCubit,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<CartCubit>.value(value: cartCubit),
      ],
      child: const HomeScreen(),
    ),
  );
}

void registerMockCubits({
  required MockCategoriesCubit categoriesCubit,
  required MockProductsCubit productsCubit,
  required MockCartCubit cartCubit,
}) {
  final sl = GetIt.instance;
  sl.allowReassignment = true;
  sl.registerFactory<CategoriesCubit>(() => categoriesCubit);
  sl.registerFactory<ProductsCubit>(() => productsCubit);
  sl.registerFactory<CartCubit>(() => cartCubit);
}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockCategoriesCubit mockCategoriesCubit;
  late MockProductsCubit mockProductsCubit;
  late MockCartCubit mockCartCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockCategoriesCubit = MockCategoriesCubit();
    mockProductsCubit = MockProductsCubit();
    mockCartCubit = MockCartCubit();

    when(() => mockAuthCubit.state)
        .thenReturn(AuthState.authenticated(testUserProfile));
    when(() => mockAuthCubit.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());

    when(() => mockCategoriesCubit.state).thenReturn(
      CategoriesState.initial().copyWith(
        status: CategoriesStatus.loaded,
        categories: [testCategory, testCategory2],
      ),
    );
    when(() => mockCategoriesCubit.stream)
        .thenAnswer((_) => const Stream<CategoriesState>.empty());
    when(() => mockCategoriesCubit.loadCategories()).thenAnswer((_) async {});

    when(() => mockProductsCubit.state).thenReturn(
      ProductsState.initial().copyWith(
        status: ProductsStatus.loaded,
        products: [testProduct, testProduct2],
      ),
    );
    when(() => mockProductsCubit.stream)
        .thenAnswer((_) => const Stream<ProductsState>.empty());
    when(() => mockProductsCubit.loadProducts(
        categoryId: any(named: 'categoryId'))).thenAnswer((_) async {});

    when(() => mockCartCubit.state).thenReturn(const CartState());
    when(() => mockCartCubit.stream)
        .thenAnswer((_) => const Stream<CartState>.empty());
    when(() => mockCartCubit.loadCart()).thenAnswer((_) async {});
    when(() => mockCartCubit.close()).thenAnswer((_) async {});
    when(() => mockCategoriesCubit.close()).thenAnswer((_) async {});
    when(() => mockProductsCubit.close()).thenAnswer((_) async {});

    registerMockCubits(
      categoriesCubit: mockCategoriesCubit,
      productsCubit: mockProductsCubit,
      cartCubit: mockCartCubit,
    );
  });

  group('HomeScreen', () {
    group('render', () {
      testWidgets('shows greeting with user name from AuthCubit',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(
            authCubit: mockAuthCubit, cartCubit: mockCartCubit));
        await tester.pump();

        expect(find.text('أهلاً محمد 👋'), findsOneWidget);
        expect(find.text('ماذا تشتهي اليوم؟'), findsOneWidget);
      });

      testWidgets('renders category chips with mocked categories',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(
            authCubit: mockAuthCubit, cartCubit: mockCartCubit));
        await tester.pump();

        expect(find.text('الكل'), findsOneWidget);
        expect(find.text('بيتزا'), findsOneWidget);
        expect(find.text('مشروبات'), findsOneWidget);
      });

      testWidgets('renders product grid cards with mocked products',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(
            authCubit: mockAuthCubit, cartCubit: mockCartCubit));
        await tester.pump();

        expect(find.text('مارجريتا'), findsOneWidget);
        expect(find.text('بيبسي'), findsOneWidget);
        expect(find.text('75 رس'), findsOneWidget);
        expect(find.text('15 رس'), findsOneWidget);
      });

      testWidgets('shows empty state when no products', (tester) async {
        when(() => mockProductsCubit.state).thenReturn(
          ProductsState.initial().copyWith(
            status: ProductsStatus.loaded,
            products: [],
          ),
        );

        await tester.pumpWidget(_buildTestWidget(
            authCubit: mockAuthCubit, cartCubit: mockCartCubit));
        await tester.pump();

        expect(find.text('مفيش أصناف في هذه الفئة'), findsOneWidget);
      });

      testWidgets('shows cart icon in greeting area', (tester) async {
        await tester.pumpWidget(_buildTestWidget(
            authCubit: mockAuthCubit, cartCubit: mockCartCubit));
        await tester.pump();

        expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      });
    });

    group('interaction', () {
      testWidgets(
          'tapping a category chip calls selectCategory on ProductsCubit',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(
            authCubit: mockAuthCubit, cartCubit: mockCartCubit));
        await tester.pump();

        await tester.tap(find.text('بيتزا'));
        await tester.pump();

        verify(() => mockProductsCubit.selectCategory(testCategory.id))
            .called(1);
      });
    });
  });
}
