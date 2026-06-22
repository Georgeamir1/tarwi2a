import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/infrastructure/datasources/remote/device_token_remote_datasource.dart';
import 'package:tarwi2a/infrastructure/repositories/device_token_repository_impl.dart';

class MockDeviceTokenRemoteDataSource extends Mock
    implements DeviceTokenRemoteDataSource {}

void main() {
  late MockDeviceTokenRemoteDataSource mockDS;
  late DeviceTokenRepositoryImpl repo;

  setUp(() {
    mockDS = MockDeviceTokenRemoteDataSource();
    repo = DeviceTokenRepositoryImpl(mockDS);
  });

  group('DeviceTokenRepositoryImpl', () {
    test('registerToken returns right on success', () async {
      when(() => mockDS.registerToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async {});

      final result = await repo.registerToken(
        userId: 'u1',
        token: 'fcm-token-123',
        platform: 'android',
      );

      expect(result.isRight(), isTrue);
    });

    test('registerToken returns left on exception', () async {
      when(() => mockDS.registerToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
            platform: any(named: 'platform'),
          )).thenThrow(Exception('boom'));

      final result = await repo.registerToken(
        userId: 'u1',
        token: 't',
        platform: 'android',
      );

      expect(result.isLeft(), isTrue);
    });

    test('unregisterToken returns right on success', () async {
      when(() => mockDS.unregisterToken(token: any(named: 'token')))
          .thenAnswer((_) async {});

      final result = await repo.unregisterToken(token: 'fcm-token-123');

      expect(result.isRight(), isTrue);
    });

    test('unregisterToken returns left on exception', () async {
      when(() => mockDS.unregisterToken(token: any(named: 'token')))
          .thenThrow(Exception('boom'));

      final result = await repo.unregisterToken(token: 't');

      expect(result.isLeft(), isTrue);
    });

    test('getTokensForUser returns list on success', () async {
      when(() => mockDS.getTokensForUser(userId: any(named: 'userId')))
          .thenAnswer((_) async => ['t1', 't2', 't3']);

      final result = await repo.getTokensForUser(userId: 'u1');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected right'),
        (tokens) => expect(tokens, ['t1', 't2', 't3']),
      );
    });

    test('getTokensForUser returns empty list when no tokens', () async {
      when(() => mockDS.getTokensForUser(userId: any(named: 'userId')))
          .thenAnswer((_) async => []);

      final result = await repo.getTokensForUser(userId: 'u1');

      result.fold(
        (_) => fail('Expected right'),
        (tokens) => expect(tokens, isEmpty),
      );
    });
  });
}
