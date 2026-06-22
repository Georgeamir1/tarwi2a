import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/admin/admin_product_options_cubit.dart';
import 'package:tarwi2a/domain/entities/product_option.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockProductOptionRepository mockRepo;
  late AdminProductOptionsCubit cubit;

  setUpAll(() {
    registerFallbackValue(<ProductOption>[]);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockRepo = MockProductOptionRepository();
  });

  group('AdminProductOptionsCubit', () {
    group('initial state', () {
      test('emits initial with empty options', () {
        cubit = AdminProductOptionsCubit(mockRepo);
        expect(cubit.state.status, AdminProductOptionsStatus.initial);
        expect(cubit.state.options, isEmpty);
      });
    });

    group('loadByProductId', () {
      test('emits loading then loaded with options on success', () async {
        when(() => mockRepo.getByProductId('prod-1'))
            .thenAnswer((_) async => right([testProductOption]));

        cubit = AdminProductOptionsCubit(mockRepo);
        await cubit.loadByProductId('prod-1');

        expect(cubit.state.status, AdminProductOptionsStatus.loaded);
        expect(cubit.state.options, [testProductOption]);
        verify(() => mockRepo.getByProductId('prod-1')).called(1);
      });

      test('emits loading then error on failure', () async {
        when(() => mockRepo.getByProductId('prod-1'))
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AdminProductOptionsCubit(mockRepo);
        await cubit.loadByProductId('prod-1');

        expect(cubit.state.status, AdminProductOptionsStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });

      test('emits loaded with empty list when no options', () async {
        when(() => mockRepo.getByProductId('prod-1'))
            .thenAnswer((_) async => right(<ProductOption>[]));

        cubit = AdminProductOptionsCubit(mockRepo);
        await cubit.loadByProductId('prod-1');

        expect(cubit.state.status, AdminProductOptionsStatus.loaded);
        expect(cubit.state.options, isEmpty);
      });
    });

    group('upsert', () {
      test('delegates to repository', () async {
        when(() => mockRepo.upsert(any(), id: any(named: 'id')))
            .thenAnswer((_) async => right<Failure, void>(null));

        cubit = AdminProductOptionsCubit(mockRepo);
        await cubit.upsert({
          'product_id': 'prod-1',
          'name': 'Extra Sauce',
          'price_delta': 5.0,
        });

        verify(() => mockRepo.upsert(any(), id: any(named: 'id'))).called(1);
      });
    });

    group('delete', () {
      test('delegates to repository', () async {
        when(() => mockRepo.delete('opt-1'))
            .thenAnswer((_) async => right<Failure, void>(null));

        cubit = AdminProductOptionsCubit(mockRepo);
        await cubit.delete('opt-1');

        verify(() => mockRepo.delete('opt-1')).called(1);
      });
    });
  });
}
