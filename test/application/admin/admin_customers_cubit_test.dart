import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/admin/admin_customers_cubit.dart';
import 'package:tarwi2a/domain/entities/customer.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockCustomerRepository mockRepo;
  late AdminCustomersCubit cubit;

  setUpAll(() {
    registerFallbackValue(<Customer>[]);
  });

  setUp(() {
    mockRepo = MockCustomerRepository();
    when(() => mockRepo.watchCustomers())
        .thenAnswer((_) => const Stream.empty());
  });

  group('AdminCustomersCubit', () {
    group('initial state', () {
      test('emits initial with empty lists', () {
        cubit = AdminCustomersCubit(mockRepo);
        expect(cubit.state.status, AdminCustomersStatus.initial);
        expect(cubit.state.customers, isEmpty);
        expect(cubit.state.filteredCustomers, isEmpty);
      });
    });

    group('loadCustomers', () {
      test('emits loading then loaded with data on success', () async {
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testCustomer]));

        cubit = AdminCustomersCubit(mockRepo);
        await cubit.loadCustomers();

        expect(cubit.state.status, AdminCustomersStatus.loaded);
        expect(cubit.state.customers, [testCustomer]);
        expect(cubit.state.filteredCustomers, [testCustomer]);
      });

      test('emits loading then error on failure', () async {
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AdminCustomersCubit(mockRepo);
        await cubit.loadCustomers();

        expect(cubit.state.status, AdminCustomersStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });
    });

    group('search', () {
      test('filters customers by name', () async {
        final customer2 = testCustomer.copyWith(
          id: 'cust-2',
          name: 'أحمد',
          phone: '0100999888',
        );
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testCustomer, customer2]));

        cubit = AdminCustomersCubit(mockRepo);
        await cubit.loadCustomers();

        cubit.search('محمد');

        expect(cubit.state.filteredCustomers, [testCustomer]);
        expect(cubit.state.customers.length, 2);
      });

      test('filters customers by phone', () async {
        final customer2 = testCustomer.copyWith(
          id: 'cust-2',
          name: 'أحمد',
          phone: '0100999888',
        );
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testCustomer, customer2]));

        cubit = AdminCustomersCubit(mockRepo);
        await cubit.loadCustomers();

        cubit.search('0100999');

        expect(cubit.state.filteredCustomers, [customer2]);
      });

      test('shows all customers when search is empty', () async {
        final customer2 = testCustomer.copyWith(id: 'cust-2', name: 'أحمد');
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testCustomer, customer2]));

        cubit = AdminCustomersCubit(mockRepo);
        await cubit.loadCustomers();

        cubit.search('');

        expect(cubit.state.filteredCustomers.length, 2);
      });

      test('is case insensitive with Latin characters', () async {
        final mixedCaseCustomer = testCustomer.copyWith(name: 'Ahmed Mohamed');
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([mixedCaseCustomer]));

        cubit = AdminCustomersCubit(mockRepo);
        await cubit.loadCustomers();

        cubit.search('AHMED');

        expect(cubit.state.filteredCustomers, [mixedCaseCustomer]);
      });
    });

    group('realtime subscription', () {
      test('updates customers when stream emits', () async {
        final controller = StreamController<List<Customer>>.broadcast();
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testCustomer]));
        when(() => mockRepo.watchCustomers())
            .thenAnswer((_) => controller.stream);

        cubit = AdminCustomersCubit(mockRepo);
        await cubit.loadCustomers();

        final updatedCustomer = testCustomer.copyWith(totalOrders: 15);
        controller.add([updatedCustomer]);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.customers, [updatedCustomer]);
        expect(cubit.state.status, AdminCustomersStatus.loaded);

        await controller.close();
      });

      test('applies current search filter to streamed data', () async {
        final controller = StreamController<List<Customer>>.broadcast();
        final customer2 = testCustomer.copyWith(
          id: 'cust-2',
          name: 'أحمد',
        );
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testCustomer, customer2]));
        when(() => mockRepo.watchCustomers())
            .thenAnswer((_) => controller.stream);

        cubit = AdminCustomersCubit(mockRepo);
        await cubit.loadCustomers();

        cubit.search('محمد');

        controller.add([testCustomer, customer2]);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.customers.length, 2);
        expect(cubit.state.filteredCustomers, [testCustomer]);

        await controller.close();
      });

      test('keeps cached data on stream error', () async {
        final controller = StreamController<List<Customer>>.broadcast();
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testCustomer]));
        when(() => mockRepo.watchCustomers())
            .thenAnswer((_) => controller.stream);

        cubit = AdminCustomersCubit(mockRepo);
        await cubit.loadCustomers();

        controller.addError(Exception('stream error'));

        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.customers, [testCustomer]);
        expect(cubit.state.status, AdminCustomersStatus.loaded);

        await controller.close();
      });
    });

    group('close', () {
      test('cancels subscription', () async {
        final controller = StreamController<List<Customer>>.broadcast();
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testCustomer]));
        when(() => mockRepo.watchCustomers())
            .thenAnswer((_) => controller.stream);

        cubit = AdminCustomersCubit(mockRepo);
        await cubit.loadCustomers();
        await cubit.close();

        expect(controller.hasListener, isFalse);
        await controller.close();
      });
    });
  });
}
