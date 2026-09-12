import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarwi2a/infrastructure/datasources/local/secure_auth_local_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterSecureStorage mockSecureStorage;
  late SharedPreferences prefs;
  const testKey = 'sb-test-auth-token';

  setUp(() async {
    mockSecureStorage = MockFlutterSecureStorage();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('SecureAuthLocalStorage', () {
    test(
        'initializes and migrates legacy session to secure storage and verifies',
        () async {
      SharedPreferences.setMockInitialValues({
        testKey: 'legacy_jwt_session_data',
      });
      prefs = await SharedPreferences.getInstance();

      when(() => mockSecureStorage.read(key: testKey))
          .thenAnswer((_) async => null);

      var writeCalled = false;
      when(() => mockSecureStorage.write(
            key: testKey,
            value: any(named: 'value'),
          )).thenAnswer((_) async {
        writeCalled = true;
      });
      when(() => mockSecureStorage.read(key: testKey)).thenAnswer((_) async {
        return writeCalled ? 'legacy_jwt_session_data' : null;
      });

      final storage = SecureAuthLocalStorage(
        secureStorage: mockSecureStorage,
        prefs: prefs,
        persistSessionKey: testKey,
      );

      await storage.initialize();

      verify(() => mockSecureStorage.write(
            key: testKey,
            value: 'legacy_jwt_session_data',
          )).called(1);
      // Legacy data is removed from SharedPreferences only after successful verification
      expect(prefs.containsKey(testKey), isFalse);
    });

    test('does not delete legacy session if secure write fails', () async {
      SharedPreferences.setMockInitialValues({
        testKey: 'legacy_jwt_session_data',
      });
      prefs = await SharedPreferences.getInstance();

      when(() => mockSecureStorage.read(key: testKey))
          .thenAnswer((_) async => null);
      when(() => mockSecureStorage.write(
            key: testKey,
            value: any(named: 'value'),
          )).thenThrow(Exception('Secure storage hardware failure'));

      final storage = SecureAuthLocalStorage(
        secureStorage: mockSecureStorage,
        prefs: prefs,
        persistSessionKey: testKey,
      );

      await storage.initialize();

      // Legacy key MUST be preserved if secure write failed
      expect(prefs.containsKey(testKey), isTrue);
      expect(prefs.getString(testKey), equals('legacy_jwt_session_data'));
    });

    test('secure storage wins over legacy session if both exist', () async {
      SharedPreferences.setMockInitialValues({
        testKey: 'old_legacy_session',
      });
      prefs = await SharedPreferences.getInstance();

      when(() => mockSecureStorage.read(key: testKey))
          .thenAnswer((_) async => 'fresh_secure_session');

      final storage = SecureAuthLocalStorage(
        secureStorage: mockSecureStorage,
        prefs: prefs,
        persistSessionKey: testKey,
      );

      await storage.initialize();

      // Legacy is wiped because secure exists and wins
      expect(prefs.containsKey(testKey), isFalse);
      final token = await storage.accessToken();
      expect(token, equals('fresh_secure_session'));
    });

    test('hasAccessToken returns true if secure storage contains session',
        () async {
      when(() => mockSecureStorage.read(key: testKey))
          .thenAnswer((_) async => 'valid_token');

      final storage = SecureAuthLocalStorage(
        secureStorage: mockSecureStorage,
        prefs: prefs,
        persistSessionKey: testKey,
      );

      final hasToken = await storage.hasAccessToken();
      expect(hasToken, isTrue);
    });

    test('hasAccessToken falls back to legacy if secure storage is empty',
        () async {
      SharedPreferences.setMockInitialValues({
        testKey: 'legacy_token',
      });
      prefs = await SharedPreferences.getInstance();

      when(() => mockSecureStorage.read(key: testKey))
          .thenAnswer((_) async => null);

      final storage = SecureAuthLocalStorage(
        secureStorage: mockSecureStorage,
        prefs: prefs,
        persistSessionKey: testKey,
      );

      final hasToken = await storage.hasAccessToken();
      expect(hasToken, isTrue);
    });

    test(
        'persistSession writes to secure storage and removes from legacy prefs',
        () async {
      SharedPreferences.setMockInitialValues({
        testKey: 'stale_pref',
      });
      prefs = await SharedPreferences.getInstance();

      when(() => mockSecureStorage.write(
            key: testKey,
            value: 'new_session',
          )).thenAnswer((_) async {});

      final storage = SecureAuthLocalStorage(
        secureStorage: mockSecureStorage,
        prefs: prefs,
        persistSessionKey: testKey,
      );

      await storage.persistSession('new_session');

      verify(() => mockSecureStorage.write(
            key: testKey,
            value: 'new_session',
          )).called(1);
      expect(prefs.containsKey(testKey), isFalse);
    });

    test('removePersistedSession deletes from both secure and legacy storage',
        () async {
      SharedPreferences.setMockInitialValues({
        testKey: 'legacy_leftover',
      });
      prefs = await SharedPreferences.getInstance();

      when(() => mockSecureStorage.delete(key: testKey))
          .thenAnswer((_) async {});

      final storage = SecureAuthLocalStorage(
        secureStorage: mockSecureStorage,
        prefs: prefs,
        persistSessionKey: testKey,
      );

      await storage.removePersistedSession();

      verify(() => mockSecureStorage.delete(key: testKey)).called(1);
      expect(prefs.containsKey(testKey), isFalse);
    });

    test(
        'removePersistedSession throws exception if secure storage delete fails',
        () async {
      when(() => mockSecureStorage.delete(key: testKey))
          .thenThrow(Exception('Secure delete failure'));

      final storage = SecureAuthLocalStorage(
        secureStorage: mockSecureStorage,
        prefs: prefs,
        persistSessionKey: testKey,
      );

      expect(() => storage.removePersistedSession(), throwsA(isA<Exception>()));
    });

    test('serializes operations to prevent stale persist after remove',
        () async {
      final writeCompleter = Completer<void>();

      when(() => mockSecureStorage.write(
            key: testKey,
            value: 'slow_token',
          )).thenAnswer((_) => writeCompleter.future);

      var deleteCalled = false;
      when(() => mockSecureStorage.delete(key: testKey)).thenAnswer((_) async {
        deleteCalled = true;
      });

      final storage = SecureAuthLocalStorage(
        secureStorage: mockSecureStorage,
        prefs: prefs,
        persistSessionKey: testKey,
      );

      // Launch slow persistSession
      final persistFuture = storage.persistSession('slow_token');

      // Immediate removePersistedSession while persist is waiting
      final removeFuture = storage.removePersistedSession();

      // At this point delete should not have been called yet
      expect(deleteCalled, isFalse);

      // Now complete the slow write
      writeCompleter.complete();

      await persistFuture;
      await removeFuture;

      // Both must complete sequentially with delete called last
      expect(deleteCalled, isTrue);
    });
  });
}
