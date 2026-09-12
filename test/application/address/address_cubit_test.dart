import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/address/address_cubit.dart';
import 'package:tarwi2a/domain/entities/address.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockAddressRepository mockRepo;
  late AddressCubit cubit;

  setUpAll(() {
    registerFallbackValue(<Address>[]);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockRepo = MockAddressRepository();
  });

  group('AddressCubit', () {
    group('initial state', () {
      test('emits AddressStatus.initial with empty addresses on creation', () {
        cubit = AddressCubit(mockRepo);
        expect(cubit.state.status, AddressStatus.initial);
        expect(cubit.state.addresses, isEmpty);
        expect(cubit.state.failure, isNull);
      });
    });

    group('loadAddresses', () {
      test('emits loading then loaded with addresses on success', () async {
        when(() => mockRepo.getAddresses('user-123'))
            .thenAnswer((_) async => right([testAddress]));

        cubit = AddressCubit(mockRepo);
        await cubit.loadAddresses('user-123');

        expect(cubit.state.status, AddressStatus.loaded);
        expect(cubit.state.addresses, [testAddress]);
      });

      test('emits loading then error on failure', () async {
        when(() => mockRepo.getAddresses('user-123'))
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AddressCubit(mockRepo);
        await cubit.loadAddresses('user-123');

        expect(cubit.state.status, AddressStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });
    });

    group('createAddress', () {
      test('emits saving then loaded on success and reloads', () async {
        when(() => mockRepo.createAddress(any()))
            .thenAnswer((_) async => right(testAddress));
        when(() => mockRepo.getAddresses('user-123'))
            .thenAnswer((_) async => right([testAddress]));

        cubit = AddressCubit(mockRepo);
        final result =
            await cubit.createAddress('user-123', {'label': 'العمل'});
        await Future.delayed(const Duration(milliseconds: 50));

        expect(result, right<Failure, void>(null));
        expect(cubit.state.status, AddressStatus.loaded);
        verify(() => mockRepo.createAddress(any())).called(1);
        verify(() => mockRepo.getAddresses('user-123')).called(1);
      });

      test('does not mutate input data map when adding user_id', () async {
        when(() => mockRepo.createAddress(any()))
            .thenAnswer((_) async => right(testAddress));
        when(() => mockRepo.getAddresses('user-123'))
            .thenAnswer((_) async => right([testAddress]));

        cubit = AddressCubit(mockRepo);
        final inputData = {'label': 'العمل', 'address': 'شارع 1'};
        await cubit.createAddress('user-123', inputData);

        expect(inputData.containsKey('user_id'), isFalse);
      });

      test('emits saving then error on failure and does not reload', () async {
        when(() => mockRepo.createAddress(any()))
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AddressCubit(mockRepo);
        final result =
            await cubit.createAddress('user-123', {'label': 'العمل'});

        expect(result, left<Failure, void>(testServerFailure));
        expect(cubit.state.status, AddressStatus.error);
        expect(cubit.state.failure, testServerFailure);
        verifyNever(() => mockRepo.getAddresses(any()));
      });

      test('returns write success when reload fails', () async {
        when(() => mockRepo.createAddress(any()))
            .thenAnswer((_) async => right(testAddress));
        when(() => mockRepo.getAddresses('user-123'))
            .thenAnswer((_) async => left(testNetworkFailure));

        cubit = AddressCubit(mockRepo);
        final result =
            await cubit.createAddress('user-123', {'label': 'العمل'});

        expect(result, right<Failure, void>(null));
        expect(cubit.state.status, AddressStatus.error);
        expect(cubit.state.failure, testNetworkFailure);
      });

      test('does not throw when closed while create is pending', () async {
        final completer = Completer<Either<Failure, Address>>();
        when(() => mockRepo.createAddress(any()))
            .thenAnswer((_) => completer.future);

        cubit = AddressCubit(mockRepo);
        final future = cubit.createAddress('user-123', {'label': 'العمل'});
        await cubit.close();
        completer.complete(right(testAddress));

        final result = await future;
        expect(result, right<Failure, void>(null));
      });
    });

    group('updateAddress', () {
      test('emits saving then loaded on success and reloads', () async {
        when(() => mockRepo.updateAddress(any(), any()))
            .thenAnswer((_) async => right(testAddress));
        when(() => mockRepo.getAddresses('user-123'))
            .thenAnswer((_) async => right([testAddress]));

        cubit = AddressCubit(mockRepo);
        final result = await cubit.updateAddress(
            'addr-1', {'label': 'منزل جديد'}, 'user-123');
        await Future.delayed(const Duration(milliseconds: 50));

        expect(result, right<Failure, void>(null));
        expect(cubit.state.status, AddressStatus.loaded);
        verify(() => mockRepo.updateAddress('addr-1', any())).called(1);
        verify(() => mockRepo.getAddresses('user-123')).called(1);
      });

      test('emits saving then error on failure and does not reload', () async {
        when(() => mockRepo.updateAddress(any(), any()))
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AddressCubit(mockRepo);
        final result =
            await cubit.updateAddress('addr-1', {'label': 'جديد'}, 'user-123');

        expect(result, left<Failure, void>(testServerFailure));
        expect(cubit.state.status, AddressStatus.error);
        expect(cubit.state.failure, testServerFailure);
        verifyNever(() => mockRepo.getAddresses(any()));
      });

      test('returns write success when reload fails', () async {
        when(() => mockRepo.updateAddress(any(), any()))
            .thenAnswer((_) async => right(testAddress));
        when(() => mockRepo.getAddresses('user-123'))
            .thenAnswer((_) async => left(testNetworkFailure));

        cubit = AddressCubit(mockRepo);
        final result =
            await cubit.updateAddress('addr-1', {'label': 'جديد'}, 'user-123');

        expect(result, right<Failure, void>(null));
        expect(cubit.state.status, AddressStatus.error);
        expect(cubit.state.failure, testNetworkFailure);
      });

      test('does not throw when closed while update is pending', () async {
        final completer = Completer<Either<Failure, Address>>();
        when(() => mockRepo.updateAddress(any(), any()))
            .thenAnswer((_) => completer.future);

        cubit = AddressCubit(mockRepo);
        final future =
            cubit.updateAddress('addr-1', {'label': 'جديد'}, 'user-123');
        await cubit.close();
        completer.complete(right(testAddress));

        final result = await future;
        expect(result, right<Failure, void>(null));
      });
    });

    group('deleteAddress', () {
      test('emits saving then loaded on success and reloads', () async {
        when(() => mockRepo.deleteAddress('addr-1'))
            .thenAnswer((_) async => right<Failure, void>(null));
        when(() => mockRepo.getAddresses('user-123'))
            .thenAnswer((_) async => right(<Address>[]));

        cubit = AddressCubit(mockRepo);
        await cubit.deleteAddress('addr-1', 'user-123');
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.status, AddressStatus.loaded);
        expect(cubit.state.addresses, isEmpty);
      });

      test('emits saving then error on failure', () async {
        when(() => mockRepo.deleteAddress('addr-1'))
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AddressCubit(mockRepo);
        await cubit.deleteAddress('addr-1', 'user-123');

        expect(cubit.state.status, AddressStatus.error);
      });
    });

    group('setDefault', () {
      test('reloads addresses on success', () async {
        when(() => mockRepo.setDefault('addr-1', 'user-123'))
            .thenAnswer((_) async => right<Failure, void>(null));
        when(() => mockRepo.getAddresses('user-123'))
            .thenAnswer((_) async => right([testAddress]));

        cubit = AddressCubit(mockRepo);
        await cubit.setDefault('addr-1', 'user-123');
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.addresses, [testAddress]);
      });

      test('emits error on failure', () async {
        when(() => mockRepo.setDefault('addr-1', 'user-123'))
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AddressCubit(mockRepo);
        await cubit.setDefault('addr-1', 'user-123');

        expect(cubit.state.failure, testServerFailure);
      });
    });
  });
}
