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
        expect(cubit.state.allProducts, [testProduct]);
        expect(cubit.state.products, [testProduct]);
      });

      test('stores all products regardless of categoryId param', () async {
        when(() => mockRepo.getProducts())
            .thenAnswer((_) async => right([testProduct]));

        cubit = ProductsCubit(mockRepo);

        await cubit.loadProducts(categoryId: 'cat-1');

        verify(() => mockRepo.getProducts()).called(1);
        expect(cubit.state.status, ProductsStatus.loaded);
        expect(cubit.state.allProducts, [testProduct]);
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
      test('filters products locally without reloading from repository',
          () async {
        when(() => mockRepo.getProducts())
            .thenAnswer((_) async => right([testProduct]));

        cubit = ProductsCubit(mockRepo);
        await cubit.loadProducts();

        cubit.selectCategory('cat-1');

        verify(() => mockRepo.getProducts()).called(1);
        expect(cubit.state.selectedCategoryId, 'cat-1');
        expect(cubit.state.products, [testProduct]);
        expect(cubit.state.allProducts, [testProduct]);
      });
    });
  });
}
