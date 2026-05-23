import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:matbakhy/presentation/screens/admin/admin_product_form_screen.dart';
import 'package:matbakhy/application/admin/admin_products_cubit.dart';
import 'package:matbakhy/application/admin/admin_categories_cubit.dart';
import 'package:matbakhy/domain/entities/product.dart';
import '../../../helpers/test_helpers.dart';

const _editTestProduct = Product(
  id: 'prod-edit',
  categoryId: 'cat-1',
  name: 'Test English',
  nameAr: 'تجربة',
  descriptionAr: 'وصف تجريبي',
  price: 99.0,
  imageUrl: 'https://example.com/edit.png',
  isAvailable: true,
  sortOrder: 1,
);

Widget _buildCreateForm({
  required AdminProductsCubit productsCubit,
  required AdminCategoriesCubit categoriesCubit,
}) {
  return MaterialApp.router(
    routerConfig: GoRouter(
      initialLocation: '/new',
      routes: [
        GoRoute(
          path: '/new',
          builder: (_, __) => const AdminProductFormScreen(),
        ),
      ],
    ),
    builder: (context, child) => MultiBlocProvider(
      providers: [
        BlocProvider<AdminProductsCubit>.value(value: productsCubit),
        BlocProvider<AdminCategoriesCubit>.value(value: categoriesCubit),
      ],
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

Widget _buildEditForm({
  required AdminProductsCubit productsCubit,
  required AdminCategoriesCubit categoriesCubit,
}) {
  return MaterialApp.router(
    routerConfig: GoRouter(
      initialLocation: '/edit',
      routes: [
        GoRoute(
          path: '/edit',
          builder: (_, __) => const AdminProductFormScreen(product: _editTestProduct),
        ),
      ],
    ),
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
  });

  setUp(() {
    mockProductsCubit = MockAdminProductsCubit();
    mockCategoriesCubit = MockAdminCategoriesCubit();

    when(() => mockProductsCubit.stream)
        .thenAnswer((_) => const Stream<AdminProductsState>.empty());
    when(() => mockCategoriesCubit.stream)
        .thenAnswer((_) => const Stream<AdminCategoriesState>.empty());

    when(() => mockProductsCubit.state).thenReturn(const AdminProductsState());
    when(() => mockCategoriesCubit.state).thenReturn(
      const AdminCategoriesState(
        status: AdminCategoriesStatus.loaded,
        categories: [testCategory],
      ),
    );
  });

  Future<void> pumpForm(
    WidgetTester tester, {
    required Widget form,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(form);
    await tester.pump();
    await tester.pump();
  }

  group('AdminProductFormScreen create mode', () {
    testWidgets('empty form, title says صنف جديد', (tester) async {
      await pumpForm(
        tester,
        form: _buildCreateForm(
          productsCubit: mockProductsCubit,
          categoriesCubit: mockCategoriesCubit,
        ),
      );

      expect(find.text('صنف جديد'), findsOneWidget);
    });

    testWidgets('all fields render', (tester) async {
      await pumpForm(
        tester,
        form: _buildCreateForm(
          productsCubit: mockProductsCubit,
          categoriesCubit: mockCategoriesCubit,
        ),
      );

      expect(find.text('رابط الصورة'), findsOneWidget);
      expect(find.text('اسم الصنف'), findsOneWidget);
      expect(find.text('الفئة والسعر'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('form validation on empty required fields', (tester) async {
      await pumpForm(
        tester,
        form: _buildCreateForm(
          productsCubit: mockProductsCubit,
          categoriesCubit: mockCategoriesCubit,
        ),
      );

      await tester.tap(find.text('إضافة الصنف'));
      await tester.pump();
      await tester.pump();

      expect(find.text('مطلوب'), findsOneWidget);
      expect(find.text('أدخل السعر'), findsOneWidget);
    });

    testWidgets('available toggle switch works', (tester) async {
      await pumpForm(
        tester,
        form: _buildCreateForm(
          productsCubit: mockProductsCubit,
          categoriesCubit: mockCategoriesCubit,
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('متاح للطلب'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump();

      expect(find.text('غير متاح'), findsOneWidget);
    });
  });

  group('AdminProductFormScreen edit mode', () {
    testWidgets('pre-filled form when product extra provided', (tester) async {
      when(() => mockProductsCubit.state).thenReturn(
        const AdminProductsState(
          status: AdminProductsStatus.loaded,
          products: [_editTestProduct],
        ),
      );

      await pumpForm(
        tester,
        form: _buildEditForm(
          productsCubit: mockProductsCubit,
          categoriesCubit: mockCategoriesCubit,
        ),
      );

      expect(find.text('تعديل الصنف'), findsOneWidget);
    });

    testWidgets('save button calls AdminProductsCubit.upsert', (tester) async {
      when(() => mockProductsCubit.upsert(any(), id: any(named: 'id')))
          .thenAnswer((_) async {});

      await pumpForm(
        tester,
        form: _buildEditForm(
          productsCubit: mockProductsCubit,
          categoriesCubit: mockCategoriesCubit,
        ),
      );

      await tester.tap(find.text('حفظ التعديلات'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      verify(() => mockProductsCubit.upsert(any(), id: 'prod-edit')).called(1);
    });

    testWidgets('image URL shows preview when entered', (tester) async {
      await pumpForm(
        tester,
        form: _buildEditForm(
          productsCubit: mockProductsCubit,
          categoriesCubit: mockCategoriesCubit,
        ),
      );

      expect(find.text('صورة الصنف'), findsNothing);
      expect(find.byType(Image), findsWidgets);
    });
  });
}
