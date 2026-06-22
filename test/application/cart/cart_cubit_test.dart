import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/cart/cart_cubit.dart';
import 'package:tarwi2a/domain/entities/cart_item.dart';
import 'package:tarwi2a/infrastructure/datasources/local/cart_local_data_source.dart';
import 'package:tarwi2a/infrastructure/dtos/cart_item_dto.dart';
import '../../helpers/test_helpers.dart';

class MockCartLocalDataSource extends Mock implements CartLocalDataSource {}

CartItemDTO _toDTO(CartItem item) => CartItemDTO.fromDomain(item);

void main() {
  late MockCartLocalDataSource mockDataSource;
  late CartCubit cubit;

  setUpAll(() {
    registerFallbackValue(<CartItemDTO>[]);
  });

  setUp(() {
    mockDataSource = MockCartLocalDataSource();
    when(() => mockDataSource.saveCart(any())).thenAnswer((_) async {});
  });

  group('CartCubit', () {
    group('loadCart', () {
      test('loads items from local storage', () async {
        final dto = _toDTO(testCartItem);
        when(() => mockDataSource.loadCart()).thenAnswer((_) async => [dto]);

        cubit = CartCubit(mockDataSource);
        await cubit.loadCart();

        expect(cubit.state.items.length, 1);
        expect(cubit.state.items.first.productId, testCartItem.productId);
        expect(cubit.state.items.first.quantity, testCartItem.quantity);
      });

      test('loads empty state when local storage returns empty', () async {
        when(() => mockDataSource.loadCart()).thenAnswer((_) async => []);

        cubit = CartCubit(mockDataSource);
        await cubit.loadCart();

        expect(cubit.state.items, isEmpty);
      });
    });

    group('addItem', () {
      test('adds new product to cart', () async {
        when(() => mockDataSource.loadCart()).thenAnswer((_) async => []);

        cubit = CartCubit(mockDataSource);
        await cubit.loadCart();

        cubit.addItem(testProduct);

        expect(cubit.state.items.length, 1);
        expect(cubit.state.items.first.productId, testProduct.id);
        expect(cubit.state.items.first.quantity, 1);
        await Future.delayed(const Duration(milliseconds: 10));
        verify(() => mockDataSource.saveCart(any())).called(1);
      });

      test('increments quantity of existing product', () async {
        when(() => mockDataSource.loadCart()).thenAnswer((_) async => []);

        cubit = CartCubit(mockDataSource);
        await cubit.loadCart();

        cubit.addItem(testProduct);
        cubit.addItem(testProduct);

        expect(cubit.state.items.length, 1);
        expect(cubit.state.items.first.quantity, 2);
      });
    });

    group('removeItem', () {
      test('decrements quantity when quantity > 1', () async {
        when(() => mockDataSource.loadCart()).thenAnswer((_) async => []);

        cubit = CartCubit(mockDataSource);
        await cubit.loadCart();
        cubit.addItem(testProduct);
        cubit.addItem(testProduct);

        cubit.removeItem(testProduct.id);

        expect(cubit.state.items.length, 1);
        expect(cubit.state.items.first.quantity, 1);
        await Future.delayed(const Duration(milliseconds: 10));
        verify(() => mockDataSource.saveCart(any())).called(3);
      });

      test('removes item when quantity reaches 0', () async {
        when(() => mockDataSource.loadCart()).thenAnswer((_) async => []);

        cubit = CartCubit(mockDataSource);
        await cubit.loadCart();
        cubit.addItem(testProduct);

        cubit.removeItem(testProduct.id);

        expect(cubit.state.items, isEmpty);
      });
    });

    group('deleteItem', () {
      test('removes item completely regardless of quantity', () async {
        when(() => mockDataSource.loadCart()).thenAnswer((_) async => []);

        cubit = CartCubit(mockDataSource);
        await cubit.loadCart();
        cubit.addItem(testProduct);
        cubit.addItem(testProduct);

        cubit.deleteItem(testProduct.id);

        expect(cubit.state.items, isEmpty);
      });

      test('removes only the specified item', () async {
        final otherProduct = testProduct.copyWith(id: 'prod-2');
        when(() => mockDataSource.loadCart()).thenAnswer((_) async => []);

        cubit = CartCubit(mockDataSource);
        await cubit.loadCart();
        cubit.addItem(testProduct);
        cubit.addItem(otherProduct);

        cubit.deleteItem(testProduct.id);

        expect(cubit.state.items.length, 1);
        expect(cubit.state.items.first.productId, otherProduct.id);
      });
    });

    group('clearCart', () {
      test('empties all items', () async {
        when(() => mockDataSource.loadCart()).thenAnswer((_) async => []);

        cubit = CartCubit(mockDataSource);
        await cubit.loadCart();
        cubit.addItem(testProduct);
        cubit.addItem(testProduct);

        cubit.clearCart();

        expect(cubit.state.items, isEmpty);
        await Future.delayed(const Duration(milliseconds: 10));
        verify(() => mockDataSource.saveCart(any())).called(3);
      });
    });

    group('CartState computed properties', () {
      test('total computes sum of all item subtotals', () {
        const state = CartState(items: [
          CartItem(
            productId: 'p1',
            productNameAr: 'a',
            productPrice: 10.0,
            quantity: 2,
          ),
          CartItem(
            productId: 'p2',
            productNameAr: 'b',
            productPrice: 5.0,
            quantity: 3,
          ),
        ]);

        expect(state.total, 35.0);
      });

      test('totalItems computes sum of all quantities', () {
        const state = CartState(items: [
          CartItem(
            productId: 'p1',
            productNameAr: 'a',
            productPrice: 10.0,
            quantity: 2,
          ),
          CartItem(
            productId: 'p2',
            productNameAr: 'b',
            productPrice: 5.0,
            quantity: 3,
          ),
        ]);

        expect(state.totalItems, 5);
      });

      test('subtotal per item is productPrice * quantity', () {
        const item = CartItem(
          productId: 'p1',
          productNameAr: 'a',
          productPrice: 10.0,
          quantity: 2,
        );

        expect(item.subtotal, 20.0);
      });
    });
  });
}
