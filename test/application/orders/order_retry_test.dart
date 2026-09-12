import 'dart:async';

import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/orders/customer_orders_cubit.dart';
import 'package:tarwi2a/domain/entities/order.dart';
import 'package:tarwi2a/domain/failures/failure.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockOrderRepository repo;
  late CustomerOrdersCubit cubit;

  setUp(() {
    repo = MockOrderRepository();
    cubit = CustomerOrdersCubit(repo);
  });
  tearDown(() => cubit.close());

  When<Future<Either<Failure, Order>>> createOrder() =>
      when(() => repo.createOrder(
            requestId: any(named: 'requestId'),
            customerId: any(named: 'customerId'),
            customerName: any(named: 'customerName'),
            customerPhone: any(named: 'customerPhone'),
            paymentMethod: any(named: 'paymentMethod'),
            totalAmount: any(named: 'totalAmount'),
            items: any(named: 'items'),
            notes: any(named: 'notes'),
          ));

  Future<Either<Failure, Order>> place({String? notes}) => cubit.placeOrder(
        customerId: 'customer-a',
        customerName: 'Customer',
        customerPhone: '01000000000',
        paymentMethod: 'cash',
        totalAmount: 100,
        items: const [
          {'product_id': 'meal', 'quantity': 1}
        ],
        notes: notes,
      );

  test('unchanged retry retains the key; edited checkout creates a new key',
      () async {
    final keys = <Object?>[];
    createOrder().thenAnswer((invocation) async {
      keys.add(invocation.namedArguments[#requestId]);
      return left(testNetworkFailure);
    });
    await place();
    await place();
    await place(notes: 'Different instructions');
    expect(keys[0], keys[1]);
    expect(keys[2], isNot(keys[0]));
  });

  test('an orders refresh cannot unlock a pending submission', () async {
    final pending = Completer<Either<Failure, Order>>();
    var calls = 0;
    createOrder().thenAnswer((_) {
      calls++;
      return pending.future;
    });
    when(() => repo.getCustomerOrders(any()))
        .thenAnswer((_) async => right([]));
    final first = place();
    await cubit.loadOrders('customer-a');
    final second = await place();
    expect(second.isLeft(), isTrue);
    expect(calls, 1);
    pending.complete(right(testOrder));
    expect((await first).isRight(), isTrue);
  });
}
