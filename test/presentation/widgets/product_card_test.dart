import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tarwi2a/presentation/widgets/product_card.dart';
import 'package:tarwi2a/domain/entities/product.dart';
import 'package:tarwi2a/app/theme/app_theme.dart';
import 'package:tarwi2a/application/cart/cart_cubit.dart';
import 'package:tarwi2a/infrastructure/datasources/local/cart_local_data_source.dart';
import '../../helpers/test_helpers.dart';

class MockCartLocalDataSource extends Mock implements CartLocalDataSource {}

class _MockVoidCallback extends Mock {
  void call();
}

Widget _buildTestWidget({
  required Product product,
  required VoidCallback onTap,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: BlocProvider<CartCubit>(
      create: (_) => CartCubit(MockCartLocalDataSource()),
      child: Scaffold(
        body: SizedBox(
          height: 260,
          width: 180,
          child: ProductCard(
            product: product,
            onTap: onTap,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('ProductCard', () {
    testWidgets('renders product name and price', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        product: testProduct,
        onTap: () {},
      ));
      await tester.pump();

      expect(find.text(testProduct.nameAr), findsOneWidget);
      expect(find.text('75 ج'), findsOneWidget);
    });

    testWidgets('renders placeholder icon when no image', (tester) async {
      const noImageProduct = Product(
        id: 'prod-noimg',
        categoryId: 'cat-1',
        name: 'No Image',
        nameAr: 'بدون صورة',
        price: 50.0,
        imageUrl: null,
        isAvailable: true,
        sortOrder: 1,
      );

      await tester.pumpWidget(_buildTestWidget(
        product: noImageProduct,
        onTap: () {},
      ));
      await tester.pump();

      expect(find.byIcon(Icons.fastfood), findsOneWidget);
    });

    testWidgets('card tap fires onTap callback', (tester) async {
      final onTap = _MockVoidCallback();
      when(() => onTap.call()).thenReturn(null);

      await tester.pumpWidget(_buildTestWidget(
        product: testProduct,
        onTap: () => onTap(),
      ));
      await tester.pump();

      await tester.tap(find.text(testProduct.nameAr));
      await tester.pump();

      verify(() => onTap.call()).called(1);
    });

    testWidgets('shows less prominent name when unavailable', (tester) async {
      const unavailableProduct = Product(
        id: 'prod-unavail',
        categoryId: 'cat-1',
        name: 'Unavailable',
        nameAr: 'غير متوفر',
        price: 30.0,
        isAvailable: false,
        sortOrder: 1,
      );

      await tester.pumpWidget(_buildTestWidget(
        product: unavailableProduct,
        onTap: () {},
      ));
      await tester.pump();

      expect(find.text('غير متوفر'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
