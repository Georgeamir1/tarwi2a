import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:matbakhy/presentation/screens/product/product_detail_screen.dart';
import 'package:matbakhy/application/cart/cart_cubit.dart';
import 'package:matbakhy/domain/entities/product.dart';
import 'package:matbakhy/app/theme/app_theme.dart';
import '../../../helpers/test_helpers.dart';

Widget _buildTestWidget({
  required Product product,
  required CartCubit cartCubit,
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
            builder: (_, __) => BlocProvider<CartCubit>.value(
              value: cartCubit,
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

  setUpAll(() {
    registerFallbackValue(testProduct);
  });

  setUp(() {
    mockCartCubit = MockCartCubit();
    when(() => mockCartCubit.state).thenReturn(const CartState());
    when(() => mockCartCubit.stream)
        .thenAnswer((_) => const Stream<CartState>.empty());
    when(() => mockCartCubit.close()).thenAnswer((_) async {});
  });

  group('ProductDetailScreen', () {
    group('render', () {
      testWidgets('renders product name, price, and description',
          (tester) async {
        await tester.pumpWidget(
          _buildTestWidget(product: testProduct, cartCubit: mockCartCubit),
        );
        await tester.pump();

        expect(find.text('مارجريتا'), findsOneWidget);
        expect(find.text('جبنة و طماطم'), findsOneWidget);
        expect(find.text('75 جنيه'), findsWidgets);
      });

      testWidgets('computed total = price × quantity is displayed',
          (tester) async {
        await tester.pumpWidget(
          _buildTestWidget(product: testProduct, cartCubit: mockCartCubit),
        );
        await tester.pump();

        expect(find.text('الإجمالي'), findsOneWidget);
        expect(find.text('75 جنيه'), findsWidgets);
      });
    });

    group('interaction', () {
      testWidgets('quantity +/− buttons update quantity and total',
          (tester) async {
        await tester.pumpWidget(
          _buildTestWidget(product: testProduct, cartCubit: mockCartCubit),
        );
        await tester.pump();

        expect(find.text('1'), findsOneWidget);

        final addButton = find.byIcon(Icons.add);
        await tester.tap(addButton);
        await tester.pump();

        expect(find.text('2'), findsOneWidget);
        expect(find.text('150 جنيه'), findsOneWidget);

        await tester.tap(addButton);
        await tester.pump();

        expect(find.text('3'), findsOneWidget);
        expect(find.text('225 جنيه'), findsOneWidget);

        final removeButton = find.byIcon(Icons.remove);
        await tester.tap(removeButton);
        await tester.pump();

        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('add to cart button calls CartCubit.addItem', (tester) async {
        when(() => mockCartCubit.addItem(any())).thenReturn(null);

        await tester.pumpWidget(
          _buildTestWidget(product: testProduct, cartCubit: mockCartCubit),
        );
        await tester.pump();

        await tester.tap(find.text('أضف للسلة'));
        await tester.pump();

        verify(() => mockCartCubit.addItem(testProduct)).called(1);
      });
    });
  });
}
