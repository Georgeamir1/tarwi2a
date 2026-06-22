import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:tarwi2a/presentation/screens/product/product_detail_screen.dart';
import 'package:tarwi2a/application/cart/cart_cubit.dart';
import 'package:tarwi2a/application/admin/admin_product_options_cubit.dart';
import 'package:tarwi2a/domain/entities/product.dart';
import 'package:tarwi2a/domain/entities/selected_option.dart';
import 'package:tarwi2a/app/theme/app_theme.dart';
import '../../../helpers/test_helpers.dart';

class MockAdminProductOptionsCubit extends Mock implements AdminProductOptionsCubit {}

Widget _buildTestWidget({
  required Product product,
  required CartCubit cartCubit,
  required AdminProductOptionsCubit optionsCubit,
}) {
  final router = GoRouter(
    initialLocation: '/home/detail',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, __) => const Placeholder(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (_, __) => MultiBlocProvider(
              providers: [
                BlocProvider<CartCubit>.value(value: cartCubit),
                BlocProvider<AdminProductOptionsCubit>.value(value: optionsCubit),
              ],
              child: ProductDetailScreen(product: product),
            ),
          ),
        ],
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.light,
  );
}

void main() {
  late MockCartCubit mockCartCubit;
  late MockAdminProductOptionsCubit mockOptionsCubit;

  setUpAll(() {
    registerFallbackValue(testProduct);
    registerFallbackValue(<SelectedOption>[]);
  });

  setUp(() {
    mockCartCubit = MockCartCubit();
    mockOptionsCubit = MockAdminProductOptionsCubit();

    when(() => mockCartCubit.state).thenReturn(const CartState());
    when(() => mockCartCubit.stream)
        .thenAnswer((_) => const Stream<CartState>.empty());
    when(() => mockCartCubit.close()).thenAnswer((_) async {});

    when(() => mockOptionsCubit.state).thenReturn(const AdminProductOptionsState());
    when(() => mockOptionsCubit.stream)
        .thenAnswer((_) => const Stream<AdminProductOptionsState>.empty());
    when(() => mockOptionsCubit.loadByProductId(any())).thenAnswer((_) async {});
    when(() => mockOptionsCubit.close()).thenAnswer((_) async {});
  });

  group('ProductDetailScreen', () {
    group('render', () {
      testWidgets('renders product name, price, and description',
          (tester) async {
        await tester.pumpWidget(
          _buildTestWidget(
            product: testProduct,
            cartCubit: mockCartCubit,
            optionsCubit: mockOptionsCubit,
          ),
        );
        await tester.pump();

        expect(find.text('مارجريتا'), findsOneWidget);
        expect(find.text('جبنة و طماطم'), findsOneWidget);
        expect(find.textContaining('75'), findsWidgets);
      });

      testWidgets('computed total = price × quantity is displayed',
          (tester) async {
        await tester.pumpWidget(
          _buildTestWidget(
            product: testProduct,
            cartCubit: mockCartCubit,
            optionsCubit: mockOptionsCubit,
          ),
        );
        await tester.pump();

        expect(find.text('الإجمالي'), findsOneWidget);
        expect(find.textContaining('75'), findsWidgets);
      });
    });

    group('interaction', () {
      testWidgets('quantity +/− buttons update quantity and total',
          (tester) async {
        await tester.pumpWidget(
          _buildTestWidget(
            product: testProduct,
            cartCubit: mockCartCubit,
            optionsCubit: mockOptionsCubit,
          ),
        );
        await tester.pump();

        expect(find.text('1'), findsOneWidget);

        final addButton = find.byIcon(Icons.add_rounded);
        await tester.tap(addButton);
        await tester.pump();

        expect(find.text('2'), findsOneWidget);
        expect(find.textContaining('150'), findsOneWidget);

        await tester.tap(addButton);
        await tester.pump();

        expect(find.text('3'), findsOneWidget);
        expect(find.textContaining('225'), findsOneWidget);

        final removeButton = find.byIcon(Icons.remove_rounded);
        await tester.tap(removeButton);
        await tester.pump();

        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('add to cart button calls CartCubit.addItem', (tester) async {
        when(() => mockCartCubit.addItem(any(), selectedOptions: any(named: 'selectedOptions'))).thenReturn(null);

        await tester.pumpWidget(
          _buildTestWidget(
            product: testProduct,
            cartCubit: mockCartCubit,
            optionsCubit: mockOptionsCubit,
          ),
        );
        await tester.pump();

        await tester.tap(find.text('أضف للسلة'));
        await tester.pump();

        verify(() => mockCartCubit.addItem(testProduct, selectedOptions: any(named: 'selectedOptions'))).called(1);
      });
    });
  });
}
