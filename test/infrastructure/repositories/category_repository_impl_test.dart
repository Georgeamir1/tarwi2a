import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import 'package:tarwi2a/infrastructure/dtos/category_dto.dart';
import 'package:tarwi2a/infrastructure/repositories/category_repository_impl.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockCategoryRemoteDataSource mockDS;
  late CategoryRepositoryImpl repo;

  const testDTO = CategoryDTO(
    id: 'cat-1',
    name: 'Pizza',
    nameAr: 'بيتزا',
    imageUrl: 'https://example.com/pizza.png',
    sortOrder: 1,
    isActive: true,
  );

  setUp(() {
    mockDS = MockCategoryRemoteDataSource();
    repo = CategoryRepositoryImpl(mockDS);
  });

  group('getCategories', () {
    test('returns Right with Categories on success', () async {
      when(() => mockDS.getCategories()).thenAnswer((_) async => [testDTO]);

      final result = await repo.getCategories();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (categories) {
          expect(categories.length, 1);
          expect(categories.first.id, 'cat-1');
        },
      );
    });

    test('returns Left(Failure) on exception', () async {
      when(() => mockDS.getCategories()).thenThrow(Exception('test error'));

      final result = await repo.getCategories();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getAllAdmin', () {
    test('returns Right with Categories on success', () async {
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

  group('upsertCategory', () {
    test('calls upsert without id when creating', () async {
      when(() => mockDS.upsert(any(), id: any(named: 'id')))
          .thenAnswer((_) async {});

      final result = await repo.upsertCategory({'name': 'Test'});

      expect(result.isRight(), isTrue);
      verify(() => mockDS.upsert(any(), id: null)).called(1);
    });

    test('calls upsert with id when updating', () async {
      when(() => mockDS.upsert(any(), id: any(named: 'id')))
          .thenAnswer((_) async {});

      final result = await repo.upsertCategory({'name': 'Test'}, id: 'cat-1');

      expect(result.isRight(), isTrue);
      verify(() => mockDS.upsert(any(), id: 'cat-1')).called(1);
    });
  });

  group('toggleActive', () {
    test('returns Right(void) and delegates to DS on success', () async {
      when(() => mockDS.toggleActive(any(), any())).thenAnswer((_) async {});

      final result = await repo.toggleActive('cat-1', false);

      expect(result.isRight(), isTrue);
      verify(() => mockDS.toggleActive('cat-1', false)).called(1);
    });

    test('returns Left(Failure) on exception', () async {
      when(() => mockDS.toggleActive(any(), any()))
          .thenThrow(Exception('test error'));

      final result = await repo.toggleActive('cat-1', false);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
