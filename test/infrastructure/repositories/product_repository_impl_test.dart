import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import 'package:tarwi2a/infrastructure/dtos/product_dto.dart';
import 'package:tarwi2a/infrastructure/repositories/product_repository_impl.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockProductRemoteDataSource mockDS;
  late ProductRepositoryImpl repo;

  const testDTO = ProductDTO(
    id: 'prod-1',
    categoryId: 'cat-1',
    name: 'Margherita',
    nameAr: 'مارجريتا',
    description: 'Cheese and tomato',
    descriptionAr: 'جبنة و طماطم',
    price: 75.0,
    imageUrl: 'https://example.com/margherita.png',
    isAvailable: true,
    sortOrder: 1,
  );

  setUp(() {
    mockDS = MockProductRemoteDataSource();
    repo = ProductRepositoryImpl(mockDS);
  });

  group('getProducts', () {
    test('returns Right with Products on success', () async {
      when(() => mockDS.getProducts(categoryId: any(named: 'categoryId')))
          .thenAnswer((_) async => [testDTO]);

      final result = await repo.getProducts();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (products) {
          expect(products.length, 1);
          expect(products.first.id, 'prod-1');
        },
      );
    });

    test('passes categoryId filter to data source', () async {
      when(() => mockDS.getProducts(categoryId: any(named: 'categoryId')))
          .thenAnswer((_) async => [testDTO]);

      final result = await repo.getProducts(categoryId: 'cat-1');

      expect(result.isRight(), isTrue);
      verify(() => mockDS.getProducts(categoryId: 'cat-1')).called(1);
    });

    test('returns Left(Failure) on exception', () async {
      when(() => mockDS.getProducts(categoryId: any(named: 'categoryId')))
          .thenThrow(Exception('test error'));

      final result = await repo.getProducts();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getAllAdmin', () {
    test('returns Right with Products on success', () async {
      when(() => mockDS.getAllAdmin()).thenAnswer((_) async => [testDTO]);

      final result = await repo.getAllAdmin();

      expect(result.isRight(), isTrue);
    });

    test('returns Left(Failure) on failure', () async {
      when(() => mockDS.getAllAdmin()).thenThrow(Exception('test error'));

      final result = await repo.getAllAdmin();

      expect(result.isLeft(), isTrue);
    });
  });

  group('upsertProduct', () {
    test('calls upsert without id when creating', () async {
      when(() => mockDS.upsert(any(), id: any(named: 'id')))
          .thenAnswer((_) async {});

      final result = await repo.upsertProduct({'name': 'Test'});

      expect(result.isRight(), isTrue);
      verify(() => mockDS.upsert(any(), id: null)).called(1);
    });

    test('calls upsert with id when updating', () async {
      when(() => mockDS.upsert(any(), id: any(named: 'id')))
          .thenAnswer((_) async {});

      final result = await repo.upsertProduct({'name': 'Test'}, id: 'prod-1');

      expect(result.isRight(), isTrue);
      verify(() => mockDS.upsert(any(), id: 'prod-1')).called(1);
    });
  });

  group('toggleAvailable', () {
    test('returns Right(void) and delegates to DS on success', () async {
      when(() => mockDS.toggleAvailable(any(), any())).thenAnswer((_) async {});

      final result = await repo.toggleAvailable('prod-1', false);

      expect(result.isRight(), isTrue);
      verify(() => mockDS.toggleAvailable('prod-1', false)).called(1);
    });

    test('returns Left(Failure) on exception', () async {
      when(() => mockDS.toggleAvailable(any(), any()))
          .thenThrow(Exception('test error'));

      final result = await repo.toggleAvailable('prod-1', false);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
