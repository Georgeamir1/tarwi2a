import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/cart/cart_cubit.dart';
import 'package:tarwi2a/domain/entities/cart_item.dart';
import 'package:tarwi2a/domain/entities/selected_option.dart';
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

      test('keeps an immutable snapshot of selected options', () async {
        final selectedOptions = [
          const SelectedOption(
            optionId: 'cheese',
            name: 'Cheese',
            priceAdjustment: 10,
          ),
        ];
        cubit = CartCubit(mockDataSource);
        addTearDown(cubit.close);

        cubit.addItem(testProduct, selectedOptions: selectedOptions);
        selectedOptions[0] = const SelectedOption(
          optionId: 'cheese',
          name: 'Premium cheese',
          priceAdjustment: 20,
        );

        expect(cubit.state.items.single.selectedOptions.single.priceAdjustment,
            10);
        expect(cubit.state.items.single.subtotal, testProduct.price + 10);
      });
    });

    group('addItems', () {
      test('keeps an immutable snapshot of selected options', () async {
        final selectedOptions = [
          const SelectedOption(
            optionId: 'cheese',
            name: 'Cheese',
            priceAdjustment: 10,
          ),
        ];
        final item = testCartItem.copyWith(
          quantity: 1,
          selectedOptions: selectedOptions,
        );
        cubit = CartCubit(mockDataSource);
        addTearDown(cubit.close);

        cubit.addItems([item]);
        selectedOptions[0] = const SelectedOption(
          optionId: 'cheese',
          name: 'Premium cheese',
          priceAdjustment: 20,
        );

        expect(cubit.state.items.single.selectedOptions.single.priceAdjustment,
            10);
      });

      test('merges equivalent option ids regardless of order', () async {
        const cheese = SelectedOption(
          optionId: 'cheese',
          name: 'Cheese',
          priceAdjustment: 10,
        );
        const tomato = SelectedOption(
          optionId: 'tomato',
          name: 'Tomato',
          priceAdjustment: 5,
        );
        const mushroom = SelectedOption(
          optionId: 'mushroom',
          name: 'Mushroom',
          priceAdjustment: 7,
        );
        cubit = CartCubit(mockDataSource);
        addTearDown(cubit.close);

        cubit.addItems([
          testCartItem.copyWith(selectedOptions: [cheese, tomato]),
          testCartItem.copyWith(selectedOptions: [mushroom]),
          testCartItem.copyWith(selectedOptions: [tomato, cheese]),
        ]);

        expect(cubit.state.items, hasLength(2));
        expect(cubit.state.items.first.quantity, 4);
        expect(cubit.state.items.last.quantity, 2);
      });
    });

    group('coupon and delivery zone state', () {
      test('removes coupon without changing items or delivery zone', () async {
        cubit = CartCubit(mockDataSource);
        addTearDown(cubit.close);
        cubit.addItems([testCartItem]);
        cubit.setDeliveryZone(
          deliveryZoneId: 'zone-a',
          deliveryZoneName: 'المنطقة أ',
          deliveryFee: 20,
        );
        cubit.applyCoupon('coupon-a', 15);

        cubit.removeCoupon();

        expect(cubit.state.appliedCouponId, isNull);
        expect(cubit.state.discountAmount, 0);
        expect(cubit.state.items, [testCartItem]);
        expect(cubit.state.deliveryZoneId, 'zone-a');
        expect(cubit.state.deliveryZoneName, 'المنطقة أ');
        expect(cubit.state.deliveryFee, 20);
      });

      test('clears delivery zone without changing items or coupon', () async {
        cubit = CartCubit(mockDataSource);
        addTearDown(cubit.close);
        cubit.addItems([testCartItem]);
        cubit.applyCoupon('coupon-a', 15);
        cubit.setDeliveryZone(
          deliveryZoneId: 'zone-a',
          deliveryZoneName: 'المنطقة أ',
          deliveryFee: 20,
        );

        cubit.clearDeliveryZone();

        expect(cubit.state.deliveryZoneId, isNull);
        expect(cubit.state.deliveryZoneName, isNull);
        expect(cubit.state.deliveryFee, 0);
        expect(cubit.state.appliedCouponId, 'coupon-a');
        expect(cubit.state.discountAmount, 15);
        expect(cubit.state.items, [testCartItem]);
      });
    });

    group('CartState.copyWith', () {
      test('preserves or explicitly clears nullable fields', () async {
        const state = CartState(
          appliedCouponId: 'coupon-a',
          deliveryZoneId: 'zone-a',
          deliveryZoneName: 'المنطقة أ',
        );

        final unchanged = state.copyWith(discountAmount: 5);
        final couponCleared = state.copyWith(appliedCouponId: null);
        final zoneCleared = state.copyWith(
          deliveryZoneId: null,
          deliveryZoneName: null,
        );
        final replaced = state.copyWith(
          appliedCouponId: 'coupon-b',
          deliveryZoneId: 'zone-b',
          deliveryZoneName: 'المنطقة ب',
        );

        expect(unchanged.appliedCouponId, 'coupon-a');
        expect(unchanged.deliveryZoneId, 'zone-a');
        expect(unchanged.deliveryZoneName, 'المنطقة أ');
        expect(couponCleared.appliedCouponId, isNull);
        expect(couponCleared.deliveryZoneId, 'zone-a');
        expect(couponCleared.deliveryZoneName, 'المنطقة أ');
        expect(zoneCleared.deliveryZoneId, isNull);
        expect(zoneCleared.deliveryZoneName, isNull);
        expect(zoneCleared.appliedCouponId, 'coupon-a');
        expect(replaced.appliedCouponId, 'coupon-b');
        expect(replaced.deliveryZoneId, 'zone-b');
        expect(replaced.deliveryZoneName, 'المنطقة ب');
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
