import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:matbakhy/application/admin/admin_products_cubit.dart';
import 'package:matbakhy/domain/entities/product.dart';
import 'package:matbakhy/domain/failures/failure.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockProductRepository mockRepo;
  late AdminProductsCubit cubit;

  setUpAll(() {
    registerFallbackValue(testServerFailure);
    registerFallbackValue(<Product>[]);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockRepo = MockProductRepository();
    when(() => mockRepo.watchProducts(categoryId: any(named: 'categoryId')))
        .thenAnswer((_) => const Stream.empty());
  });

  group('AdminProductsCubit', () {
    group('initial state', () {
      test('emits AdminProductsStatus.initial with empty products on creation',
          () {
        cubit = AdminProductsCubit(mockRepo);
        expect(cubit.state, AdminProductsState.initial());
        expect(cubit.state.status, AdminProductsStatus.initial);
        expect(cubit.state.products, isEmpty);
      });
    });

    group('loadProducts', () {
      test('emits loading then loaded with products on success', () async {
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => right([testProduct]));

        cubit = AdminProductsCubit(mockRepo);

        await cubit.loadProducts();

        expect(cubit.state.status, AdminProductsStatus.loaded);
        expect(cubit.state.products, [testProduct]);
        verify(() => mockRepo.getAllAdmin()).called(1);
      });

      test('emits loading then error on failure', () async {
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AdminProductsCubit(mockRepo);

        await cubit.loadProducts();

        expect(cubit.state.status, AdminProductsStatus.error);
        expect(cubit.state.failure, testServerFailure);
        verify(() => mockRepo.getAllAdmin()).called(1);
      });
    });

    group('upsert', () {
      test('calls repo.upsertProduct then reloads', () async {
        when(() => mockRepo.upsertProduct(any(), id: any(named: 'id')))
            .thenAnswer((_) async => right<Failure, void>(null));
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => right([testProduct]));

        cubit = AdminProductsCubit(mockRepo);

        final data = {'name': 'New', 'name_ar': 'جديد', 'price': 50.0};
        await cubit.upsert(data);
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockRepo.upsertProduct(data)).called(1);
        verify(() => mockRepo.getAllAdmin()).called(1);
        expect(cubit.state.status, AdminProductsStatus.loaded);
        expect(cubit.state.products, [testProduct]);
      });

      test('emits error when upsert fails and reload also fails', () async {
        when(() => mockRepo.upsertProduct(any(), id: any(named: 'id')))
            .thenAnswer((_) async => left(testServerFailure));
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AdminProductsCubit(mockRepo);

        final data = {'name': 'New', 'name_ar': 'جديد', 'price': 50.0};
        await cubit.upsert(data);
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockRepo.upsertProduct(data)).called(1);
        expect(cubit.state.status, AdminProductsStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });
    });

    group('toggleAvailable', () {
      test('calls repo.toggleAvailable then reloads', () async {
        when(() => mockRepo.toggleAvailable(any(), any()))
            .thenAnswer((_) async => right<Failure, void>(null));
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => right([testProduct]));

        cubit = AdminProductsCubit(mockRepo);

        await cubit.toggleAvailable('prod-1', false);
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockRepo.toggleAvailable('prod-1', false)).called(1);
        verify(() => mockRepo.getAllAdmin()).called(1);
        expect(cubit.state.status, AdminProductsStatus.loaded);
        expect(cubit.state.products, [testProduct]);
      });

      test('emits error when toggleAvailable fails and reload also fails', () async {
        when(() => mockRepo.toggleAvailable(any(), any()))
            .thenAnswer((_) async => left(testServerFailure));
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AdminProductsCubit(mockRepo);

        await cubit.toggleAvailable('prod-1', false);
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockRepo.toggleAvailable('prod-1', false)).called(1);
        expect(cubit.state.status, AdminProductsStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });
    });
  });
}
