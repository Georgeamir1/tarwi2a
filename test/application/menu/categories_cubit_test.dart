import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:matbakhy/application/menu/categories_cubit.dart';
import 'package:matbakhy/domain/entities/category.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockCategoryRepository mockRepo;
  late CategoriesCubit cubit;

  setUpAll(() {
    registerFallbackValue(testServerFailure);
    registerFallbackValue(<Category>[]);
  });

  setUp(() {
    mockRepo = MockCategoryRepository();
  });

  group('CategoriesCubit', () {
    group('initial state', () {
      test('emits CategoriesStatus.initial with empty categories on creation',
          () {
        cubit = CategoriesCubit(mockRepo);
        expect(cubit.state, CategoriesState.initial());
        expect(cubit.state.status, CategoriesStatus.initial);
        expect(cubit.state.categories, isEmpty);
      });
    });

    group('loadCategories', () {
      test('emits loading then loaded with categories on success', () async {
        when(() => mockRepo.getCategories())
            .thenAnswer((_) async => right([testCategory]));

        cubit = CategoriesCubit(mockRepo);

        await cubit.loadCategories();

        expect(cubit.state.status, CategoriesStatus.loaded);
        expect(cubit.state.categories, [testCategory]);
      });

      test('emits loading then error with failure on failure', () async {
        when(() => mockRepo.getCategories())
            .thenAnswer((_) async => left(testServerFailure));

        cubit = CategoriesCubit(mockRepo);

        await cubit.loadCategories();

        expect(cubit.state.status, CategoriesStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });

      test('emits loading → loaded sequence with correct categories', () async {
        when(() => mockRepo.getCategories())
            .thenAnswer((_) async => right([testCategory]));

        cubit = CategoriesCubit(mockRepo);

        await cubit.loadCategories();

        expect(cubit.state.status, CategoriesStatus.loaded);
        expect(cubit.state.categories, [testCategory]);
      });
    });
  });
}
