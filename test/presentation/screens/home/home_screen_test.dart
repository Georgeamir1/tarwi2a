import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:tarwi2a/presentation/screens/home/home_screen.dart';
import 'package:tarwi2a/application/auth/auth_cubit.dart';
import 'package:tarwi2a/application/menu/categories_cubit.dart';
import 'package:tarwi2a/application/menu/products_cubit.dart';
import 'package:tarwi2a/application/cart/cart_cubit.dart';
import 'package:tarwi2a/application/notifications/notifications_cubit.dart';
import 'package:tarwi2a/domain/entities/category.dart';
import 'package:tarwi2a/domain/entities/product.dart';
import 'package:tarwi2a/app/theme/app_theme.dart';
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
  categoryId: 'cat-2',
  name: 'Pepsi',
  nameAr: 'بيبسي',
  price: 15.0,
  isAvailable: true,
  sortOrder: 2,
);

Widget _buildTestWidget({
  required AuthCubit authCubit,
  required CartCubit cartCubit,
  required NotificationsCubit notificationsCubit,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/menu',
        builder: (context, state) => Scaffold(
          body: Text('Menu category: ${state.uri.queryParameters['category']}'),
        ),
      ),
    ],
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>.value(value: authCubit),
      BlocProvider<CartCubit>.value(value: cartCubit),
      BlocProvider<NotificationsCubit>.value(value: notificationsCubit),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

void registerMockCubits({
  required MockCategoriesCubit categoriesCubit,
  required MockProductsCubit productsCubit,
  required MockCartCubit cartCubit,
  required MockNotificationsCubit notificationsCubit,
}) {
  final sl = GetIt.instance;
  sl.allowReassignment = true;
  sl.registerFactory<CategoriesCubit>(() => categoriesCubit);
  sl.registerFactory<ProductsCubit>(() => productsCubit);
  sl.registerFactory<CartCubit>(() => cartCubit);
  sl.registerFactory<NotificationsCubit>(() => notificationsCubit);
}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockCategoriesCubit mockCategoriesCubit;
  late MockProductsCubit mockProductsCubit;
  late MockCartCubit mockCartCubit;
  late MockNotificationsCubit mockNotificationsCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockCategoriesCubit = MockCategoriesCubit();
    mockProductsCubit = MockProductsCubit();
    mockCartCubit = MockCartCubit();
    mockNotificationsCubit = MockNotificationsCubit();

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
        allProducts: [testProduct, testProduct2],
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

    when(() => mockNotificationsCubit.state)
        .thenReturn(const NotificationsState());
    when(() => mockNotificationsCubit.stream)
        .thenAnswer((_) => const Stream<NotificationsState>.empty());
    when(() => mockNotificationsCubit.close()).thenAnswer((_) async {});
    when(() => mockNotificationsCubit.loadNotifications(any()))
        .thenAnswer((_) async {});

    registerMockCubits(
      categoriesCubit: mockCategoriesCubit,
      productsCubit: mockProductsCubit,
      cartCubit: mockCartCubit,
      notificationsCubit: mockNotificationsCubit,
    );
  });

  tearDown(() {
    final sl = GetIt.instance;
    if (sl.isRegistered<CategoriesCubit>()) sl.unregister<CategoriesCubit>();
    if (sl.isRegistered<ProductsCubit>()) sl.unregister<ProductsCubit>();
    if (sl.isRegistered<CartCubit>()) sl.unregister<CartCubit>();
    if (sl.isRegistered<NotificationsCubit>()) {
      sl.unregister<NotificationsCubit>();
    }
  });

  group('HomeScreen', () {
    group('render', () {
      testWidgets('shows greeting with user name from AuthCubit',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          notificationsCubit: mockNotificationsCubit,
        ));
        await tester.pump();

        expect(find.text('أهلاً محمد'), findsOneWidget);
        expect(find.text('ماذا تشتهي اليوم؟'), findsOneWidget);
      });

      testWidgets('renders category chips with mocked categories',
          (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          notificationsCubit: mockNotificationsCubit,
        ));
        await tester.pump();

        expect(find.text('عرض الكل'), findsWidgets);
        expect(find.text('بيتزا'), findsOneWidget);
        expect(find.text('مشروبات'), findsOneWidget);
      });

      testWidgets('renders product grid cards with mocked products',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          notificationsCubit: mockNotificationsCubit,
        ));
        await tester.pump();

        expect(find.text('مارجريتا'), findsOneWidget);
        expect(find.text('بيبسي'), findsOneWidget);
        expect(find.textContaining('75'), findsWidgets);
        expect(find.textContaining('15'), findsWidgets);
      });

      testWidgets('hides product previews when no products', (tester) async {
        when(() => mockProductsCubit.state).thenReturn(
          ProductsState.initial().copyWith(
            status: ProductsStatus.loaded,
            products: [],
            allProducts: [],
          ),
        );

        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          notificationsCubit: mockNotificationsCubit,
        ));
        await tester.pump();

        expect(find.text('مارجريتا'), findsNothing);
        expect(find.text('بيبسي'), findsNothing);
      });

      testWidgets('shows cart icon in greeting area', (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          notificationsCubit: mockNotificationsCubit,
        ));
        await tester.pump();

        expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      });
    });

    group('interaction', () {
      testWidgets('view all opens menu filtered by the selected category',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(
          authCubit: mockAuthCubit,
          cartCubit: mockCartCubit,
          notificationsCubit: mockNotificationsCubit,
        ));
        await tester.pump();

        await tester
            .tap(find.widgetWithText(GestureDetector, 'عرض الكل').first);
        await tester.pumpAndSettle();

        expect(find.text('Menu category: ${testCategory.id}'), findsOneWidget);
      });
    });
  });
}
