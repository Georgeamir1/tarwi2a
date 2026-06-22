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
        await cubit.createAddress('user-123', {'label': 'العمل'});
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.status, AddressStatus.loaded);
        verify(() => mockRepo.createAddress(any())).called(1);
        verify(() => mockRepo.getAddresses('user-123')).called(1);
      });

      test('emits saving then error on failure', () async {
        when(() => mockRepo.createAddress(any()))
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AddressCubit(mockRepo);
        await cubit.createAddress('user-123', {'label': 'العمل'});

        expect(cubit.state.status, AddressStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });
    });

    group('updateAddress', () {
      test('emits saving then loaded on success and reloads', () async {
        when(() => mockRepo.updateAddress(any(), any()))
            .thenAnswer((_) async => right(testAddress));
        when(() => mockRepo.getAddresses('user-123'))
            .thenAnswer((_) async => right([testAddress]));

        cubit = AddressCubit(mockRepo);
        await cubit.updateAddress('addr-1', {'label': 'منزل جديد'}, 'user-123');
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.status, AddressStatus.loaded);
      });

      test('emits saving then error on failure', () async {
        when(() => mockRepo.updateAddress(any(), any()))
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AddressCubit(mockRepo);
        await cubit.updateAddress('addr-1', {'label': 'جديد'}, 'user-123');

        expect(cubit.state.status, AddressStatus.error);
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
