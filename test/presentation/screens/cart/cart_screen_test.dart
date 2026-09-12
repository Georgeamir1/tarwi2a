import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tarwi2a/presentation/screens/cart/cart_screen.dart';
import 'package:tarwi2a/application/cart/cart_cubit.dart';
import 'package:tarwi2a/domain/entities/cart_item.dart';
import 'package:tarwi2a/domain/entities/selected_option.dart';
import 'package:tarwi2a/app/theme/app_theme.dart';
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
    registerFallbackValue(<SelectedOption>[]);
  });

  setUp(() {
    mockCartCubit = MockCartCubit();
    when(() => mockCartCubit.state).thenReturn(
      const CartState(items: [testCartItem, testCartItem2]),
    );
    when(() => mockCartCubit.stream)
        .thenAnswer((_) => const Stream<CartState>.empty());
    when(() => mockCartCubit.close()).thenAnswer((_) async {});
    when(() => mockCartCubit.addItem(any(),
        selectedOptions: any(named: 'selectedOptions'))).thenReturn(null);
    when(() => mockCartCubit.removeItem(any(),
        selectedOptions: any(named: 'selectedOptions'))).thenReturn(null);
    when(() => mockCartCubit.deleteItem(any(),
        selectedOptions: any(named: 'selectedOptions'))).thenReturn(null);
    when(() => mockCartCubit.clearCart()).thenReturn(null);
  });

  group('CartScreen', () {
    group('render', () {
      testWidgets('renders cart items with name, price, quantity, subtotal',
          (tester) async {
        await tester.pumpWidget(_buildTestWidget(cartCubit: mockCartCubit));
        await tester.pumpAndSettle();

        // Title shows total item count: testCartItem qty=2 + testCartItem2 qty=3 = 5
        expect(find.text('السلة (5)'), findsOneWidget);
        expect(find.text('مارجريتا'), findsOneWidget);
        expect(find.text('بيبسي'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        // Subtotals are in the format "X ج.م"
        expect(find.textContaining('150'), findsWidgets);
        expect(find.textContaining('45'), findsWidgets);
      });

      testWidgets('shows empty state when cart has no items', (tester) async {
        when(() => mockCartCubit.state).thenReturn(const CartState());

        await tester.pumpWidget(_buildTestWidget(cartCubit: mockCartCubit));
        await tester.pumpAndSettle();

        expect(find.text('السلة فارغة'), findsOneWidget);
        expect(find.text('تصفح القائمة الشهية وأضف أكلاتك المفضلة إليها الآن'),
            findsOneWidget);
        expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
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

        final addButtons = find.byIcon(Icons.add_rounded);
        await tester.tap(addButtons.first);
        await tester.pump();

        verify(() => mockCartCubit.addItem(any(),
            selectedOptions: any(named: 'selectedOptions'))).called(1);
      });

      testWidgets('- button calls CartCubit.removeItem', (tester) async {
        await tester.pumpWidget(_buildTestWidget(cartCubit: mockCartCubit));
        await tester.pump();

        final removeButtons = find.byIcon(Icons.remove_rounded);
        await tester.tap(removeButtons.first);
        await tester.pump();

        verify(() => mockCartCubit.removeItem(any(),
            selectedOptions: any(named: 'selectedOptions'))).called(1);
      });

      testWidgets('swipe to delete removes item', (tester) async {
        await tester.pumpWidget(_buildTestWidget(cartCubit: mockCartCubit));
        await tester.pumpAndSettle();

        // Dismissible uses end-to-start swipe; drag the item card itself
        final itemCard = find.ancestor(
          of: find.text('مارجريتا').first,
          matching: find.byType(Dismissible),
        );
        await tester.fling(itemCard, const Offset(-300, 0), 1000);
        await tester.pumpAndSettle();

        // Confirm delete in the dialog
        await tester.tap(find.text('حذف'));
        await tester.pumpAndSettle();

        verify(() => mockCartCubit.deleteItem(any(),
            selectedOptions: any(named: 'selectedOptions'))).called(1);
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
