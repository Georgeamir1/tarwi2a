import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:matbakhy/presentation/screens/cart/cart_screen.dart';
import 'package:matbakhy/application/cart/cart_cubit.dart';
import 'package:matbakhy/domain/entities/cart_item.dart';
import 'package:matbakhy/app/theme/app_theme.dart';
import '../../../helpers/test_helpers.dart';

Widget _buildTestWidget({required CartCubit cartCubit}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: BlocProvider<CartCubit>.value(
      value: cartCubit,
      child: const CartScreen(),
    ),
  );
}

const testCartItem2 = CartItem(
  productId: 'prod-2',
  productNameAr: 'بيبسي',
  productPrice: 15.0,
  quantity: 3,
);

void main() {
  late MockCartCubit mockCartCubit;

  setUpAll(() {
    registerFallbackValue(testProduct);
    registerFallbackValue(testCartItem);
  });

  setUp(() {
    mockCartCubit = MockCartCubit();
    when(() => mockCartCubit.state).thenReturn(
      const CartState(items: [testCartItem, testCartItem2]),
    );
    when(() => mockCartCubit.stream)
        .thenAnswer((_) => const Stream<CartState>.empty());
    when(() => mockCartCubit.close()).thenAnswer((_) async {});
    when(() => mockCartCubit.addItem(any())).thenReturn(null);
    when(() => mockCartCubit.removeItem(any())).thenReturn(null);
    when(() => mockCartCubit.deleteItem(any())).thenReturn(null);
    when(() => mockCartCubit.clearCart()).thenReturn(null);
  });

  group('CartScreen', () {
    group('render', () {
      testWidgets('renders cart items with name, price, quantity, subtotal',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(cartCubit: mockCartCubit));
        await tester.pump();

        expect(find.text('سلة التسوق'), findsOneWidget);
        expect(find.text('مارجريتا'), findsOneWidget);
        expect(find.text('بيبسي'), findsOneWidget);
        expect(find.text('75 ج'), findsOneWidget);
        expect(find.text('15 ج'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('150 ج'), findsOneWidget);
        expect(find.text('45 ج'), findsOneWidget);
      });

      testWidgets('shows empty state when cart has no items', (tester) async {
        when(() => mockCartCubit.state).thenReturn(const CartState());

        await tester.pumpWidget(_buildTestWidget(cartCubit: mockCartCubit));
        await tester.pump();

        expect(find.text('السلة فاضية'), findsOneWidget);
        expect(find.text('أضف أصناف من المنيو'), findsOneWidget);
        expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      });

      testWidgets('checkout button at bottom', (tester) async {
        await tester.pumpWidget(_buildTestWidget(cartCubit: mockCartCubit));
        await tester.pump();

        expect(find.text('إتمام الطلب'), findsOneWidget);
      });
    });

    group('interaction', () {
      testWidgets('+ button calls CartCubit.addItem', (tester) async {
        await tester.pumpWidget(_buildTestWidget(cartCubit: mockCartCubit));
        await tester.pump();

        final addButtons = find.byIcon(Icons.add);
        await tester.tap(addButtons.first);
        await tester.pump();

        verify(() => mockCartCubit.addItem(any())).called(1);
      });

      testWidgets('- button calls CartCubit.removeItem', (tester) async {
        await tester.pumpWidget(_buildTestWidget(cartCubit: mockCartCubit));
        await tester.pump();

        final removeButtons = find.byIcon(Icons.remove);
        await tester.tap(removeButtons.first);
        await tester.pump();

        verify(() => mockCartCubit.removeItem(any())).called(1);
      });

      testWidgets('trash/delete button removes item', (tester) async {
        await tester.pumpWidget(_buildTestWidget(cartCubit: mockCartCubit));
        await tester.pump();

        final deleteButton = find.byIcon(Icons.delete_outline).first;
        await tester.tap(deleteButton);
        await tester.pump();

        verify(() => mockCartCubit.deleteItem(any())).called(1);
      });

      testWidgets('clear cart button shows confirmation dialog',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(cartCubit: mockCartCubit));
        await tester.pump();

        await tester.tap(find.text('مسح الكل'));
        await tester.pump();

        expect(find.text('مسح السلة'), findsOneWidget);
        expect(find.text('هل أنت متأكد من مسح جميع الأصناف؟'), findsOneWidget);

        await tester.tap(find.text('مسح'));
        await tester.pump();

        verify(() => mockCartCubit.clearCart()).called(1);
      });
    });
  });
}
