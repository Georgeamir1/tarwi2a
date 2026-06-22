import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import 'package:tarwi2a/domain/entities/user_profile.dart';
import 'package:tarwi2a/infrastructure/datasources/remote/profile_remote_data_source.dart';
import 'package:tarwi2a/infrastructure/dtos/user_profile_dto.dart';
import 'package:tarwi2a/infrastructure/repositories/profile_repository_impl.dart';
import '../../helpers/test_helpers.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

void main() {
  late MockProfileRemoteDataSource mockDS;
  late ProfileRepositoryImpl repo;

  final testDTO = UserProfileDTO(
    id: 'user-123',
    name: 'محمد',
    phone: '01001234567',
    role: 'customer',
    createdAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(testDTO);
  });

  setUp(() {
    mockDS = MockProfileRemoteDataSource();
    repo = ProfileRepositoryImpl(mockDS);
  });

  group('getProfile', () {
    test('returns Right(UserProfile) when profile exists', () async {
      when(() => mockDS.getProfile(any())).thenAnswer((_) async => testDTO);

      final result = await repo.getProfile('user-123');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (profile) {
          expect(profile, isA<UserProfile>());
          expect(profile!.id, 'user-123');
          expect(profile.name, 'محمد');
        },
      );
    });

    test('returns Right(null) when no profile found in DB', () async {
      when(() => mockDS.getProfile(any())).thenAnswer((_) async => null);

      final result = await repo.getProfile('unknown-user');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (profile) => expect(profile, isNull),
      );
    });

    test('returns Left(Failure) on exception', () async {
      when(() => mockDS.getProfile(any())).thenThrow(Exception('test error'));

      final result = await repo.getProfile('user-123');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('updateProfile', () {
    test('returns Right(void) on success', () async {
      when(() => mockDS.updateProfile(any())).thenAnswer((_) async {});

      final result = await repo.updateProfile(testUserProfile);

      expect(result.isRight(), isTrue);
      verify(() => mockDS.updateProfile(any())).called(1);
    });

    test('returns Left(Failure) on exception', () async {
      when(() => mockDS.updateProfile(any()))
          .thenThrow(Exception('test error'));

      final result = await repo.updateProfile(testUserProfile);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
