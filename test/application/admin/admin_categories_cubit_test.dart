import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/admin/admin_categories_cubit.dart';
import 'package:tarwi2a/domain/entities/category.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockCategoryRepository mockRepo;
  late AdminCategoriesCubit cubit;

  setUpAll(() {
    registerFallbackValue(testServerFailure);
    registerFallbackValue(<Category>[]);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockRepo = MockCategoryRepository();
    when(() => mockRepo.watchCategories())
        .thenAnswer((_) => const Stream.empty());
  });

  group('AdminCategoriesCubit', () {
    group('initial state', () {
      test(
          'emits AdminCategoriesStatus.initial with empty categories on creation',
          () {
        cubit = AdminCategoriesCubit(mockRepo);
        expect(cubit.state, AdminCategoriesState.initial());
        expect(cubit.state.status, AdminCategoriesStatus.initial);
        expect(cubit.state.categories, isEmpty);
      });
    });

    group('loadCategories', () {
      test('emits loading then loaded with categories on success', () async {
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => right([testCategory]));

        cubit = AdminCategoriesCubit(mockRepo);

        await cubit.loadCategories();

        expect(cubit.state.status, AdminCategoriesStatus.loaded);
        expect(cubit.state.categories, [testCategory]);
        verify(() => mockRepo.getAllAdmin()).called(1);
      });

      test('emits loading then error on failure', () async {
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AdminCategoriesCubit(mockRepo);

        await cubit.loadCategories();

        expect(cubit.state.status, AdminCategoriesStatus.error);
        expect(cubit.state.failure, testServerFailure);
        verify(() => mockRepo.getAllAdmin()).called(1);
      });
    });

    group('upsert', () {
      test('calls repo.upsertCategory then reloads', () async {
        when(() => mockRepo.upsertCategory(any(), id: any(named: 'id')))
            .thenAnswer((_) async => right<Failure, void>(null));
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => right([testCategory]));

        cubit = AdminCategoriesCubit(mockRepo);

        final data = {'name': 'New', 'name_ar': 'جديد'};
        await cubit.upsert(data);
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockRepo.upsertCategory(data)).called(1);
        verify(() => mockRepo.getAllAdmin()).called(1);
        expect(cubit.state.status, AdminCategoriesStatus.loaded);
        expect(cubit.state.categories, [testCategory]);
      });

      test('emits error when upsert fails and reload also fails', () async {
        when(() => mockRepo.upsertCategory(any(), id: any(named: 'id')))
            .thenAnswer((_) async => left(testServerFailure));
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AdminCategoriesCubit(mockRepo);

        final data = {'name': 'New', 'name_ar': 'جديد'};
        await cubit.upsert(data);
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockRepo.upsertCategory(data)).called(1);
        expect(cubit.state.status, AdminCategoriesStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });
    });

    group('toggleActive', () {
      test('calls repo.toggleActive then reloads', () async {
        when(() => mockRepo.toggleActive(any(), any()))
            .thenAnswer((_) async => right<Failure, void>(null));
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => right([testCategory]));

        cubit = AdminCategoriesCubit(mockRepo);

        await cubit.toggleActive('cat-1', false);
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockRepo.toggleActive('cat-1', false)).called(1);
        verify(() => mockRepo.getAllAdmin()).called(1);
        expect(cubit.state.status, AdminCategoriesStatus.loaded);
        expect(cubit.state.categories, [testCategory]);
      });

      test('emits error when toggleActive fails and reload also fails', () async {
        when(() => mockRepo.toggleActive(any(), any()))
            .thenAnswer((_) async => left(testServerFailure));
        when(() => mockRepo.getAllAdmin())
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AdminCategoriesCubit(mockRepo);

        await cubit.toggleActive('cat-1', false);
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockRepo.toggleActive('cat-1', false)).called(1);
        expect(cubit.state.status, AdminCategoriesStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });
    });
  });
}
