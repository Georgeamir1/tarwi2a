import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:matbakhy/application/menu/products_cubit.dart';
import 'package:matbakhy/domain/entities/product.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockProductRepository mockRepo;
  late ProductsCubit cubit;

  setUpAll(() {
    registerFallbackValue(testServerFailure);
    registerFallbackValue(<Product>[]);
  });

  setUp(() {
    mockRepo = MockProductRepository();
  });

  group('ProductsCubit', () {
    group('initial state', () {
      test('emits ProductsStatus.initial with empty products on creation', () {
        cubit = ProductsCubit(mockRepo);
        expect(cubit.state, ProductsState.initial());
        expect(cubit.state.status, ProductsStatus.initial);
        expect(cubit.state.products, isEmpty);
        expect(cubit.state.selectedCategoryId, isNull);
      });
    });

    group('loadProducts', () {
      test('loads all products when no categoryId provided', () async {
        when(() => mockRepo.getProducts())
            .thenAnswer((_) async => right([testProduct]));

        cubit = ProductsCubit(mockRepo);

        await cubit.loadProducts();

        verify(() => mockRepo.getProducts()).called(1);
        expect(cubit.state.status, ProductsStatus.loaded);
        expect(cubit.state.products, [testProduct]);
      });

      test('loads products filtered by categoryId', () async {
        when(() => mockRepo.getProducts(categoryId: any(named: 'categoryId')))
            .thenAnswer((_) async => right([testProduct]));

        cubit = ProductsCubit(mockRepo);

        await cubit.loadProducts(categoryId: 'cat-1');

        verify(() => mockRepo.getProducts(categoryId: 'cat-1')).called(1);
        expect(cubit.state.status, ProductsStatus.loaded);
        expect(cubit.state.products, [testProduct]);
      });

      test('emits error on failure', () async {
        when(() => mockRepo.getProducts())
            .thenAnswer((_) async => left(testServerFailure));

        cubit = ProductsCubit(mockRepo);

        await cubit.loadProducts();

        expect(cubit.state.status, ProductsStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });
    });

    group('selectCategory', () {
      test('updates selectedCategoryId and reloads products', () async {
        when(() => mockRepo.getProducts(categoryId: any(named: 'categoryId')))
            .thenAnswer((_) async => right([testProduct]));

        cubit = ProductsCubit(mockRepo);

        cubit.selectCategory('cat-1');
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockRepo.getProducts(categoryId: 'cat-1')).called(1);
        expect(cubit.state.selectedCategoryId, 'cat-1');
        expect(cubit.state.status, ProductsStatus.loaded);
      });
    });
  });
}
