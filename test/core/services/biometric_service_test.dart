import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarwi2a/core/services/biometric_service.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalAuthentication mockAuth;
  late MockFlutterSecureStorage mockSecureStorage;
  late SharedPreferences prefs;

  setUp(() async {
    mockAuth = MockLocalAuthentication();
    mockSecureStorage = MockFlutterSecureStorage();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    when(() => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});
    when(() => mockSecureStorage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});
    when(() => mockSecureStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
  });

  group('BiometricService', () {
    test('legacy global consent and credentials are wiped upon initialization',
        () async {
      SharedPreferences.setMockInitialValues({
        'biometrics_enabled': true,
      });
      prefs = await SharedPreferences.getInstance();

      BiometricService(
        prefs,
        auth: mockAuth,
        secureStorage: mockSecureStorage,
      );

      expect(prefs.containsKey('biometrics_enabled'), isFalse);
      verify(() => mockSecureStorage.delete(key: 'bio_email')).called(1);
      verify(() => mockSecureStorage.delete(key: 'bio_password')).called(1);
    });

    test('consent is scoped per user and does not leak between accounts',
        () async {
      final service = BiometricService(
        prefs,
        auth: mockAuth,
        secureStorage: mockSecureStorage,
      );

      expect(service.isEnabledForUser('user_A'), isFalse);
      expect(service.isEnabledForUser('user_B'), isFalse);

      await service.setEnabled(userId: 'user_A', enabled: true);

      expect(service.isEnabledForUser('user_A'), isTrue);
      expect(service.isEnabledForUser('user_B'), isFalse);
      expect(service.activeBiometricUserId, equals('user_A'));
      expect(service.isBiometricsAvailableForLogin, isTrue);
    });

    test('refuses to save credentials without user consent', () async {
      final service = BiometricService(
        prefs,
        auth: mockAuth,
        secureStorage: mockSecureStorage,
      );

      final success = await service.saveCredentials(
        userId: 'user_without_consent',
        email: 'test@example.com',
        password: 'password123',
      );

      expect(success, isFalse);
      verifyNever(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ));
    });

    test('saves and retrieves credentials for authorized user', () async {
      final service = BiometricService(
        prefs,
        auth: mockAuth,
        secureStorage: mockSecureStorage,
      );

      await service.setEnabled(userId: 'user_A', enabled: true);

      when(() => mockSecureStorage.read(key: 'bio_email_user_A'))
          .thenAnswer((_) async => 'user_a@example.com');
      when(() => mockSecureStorage.read(key: 'bio_password_user_A'))
          .thenAnswer((_) async => 'secret_a');

      final saved = await service.saveCredentials(
        userId: 'user_A',
        email: 'user_a@example.com',
        password: 'secret_a',
      );
      expect(saved, isTrue);

      final creds = await service.getCredentials('user_A');
      expect(creds, isNotNull);
      expect(creds!['email'], equals('user_a@example.com'));
      expect(creds['password'], equals('secret_a'));
    });

    test(
        'Scenario: Account A -> logout -> Account B -> restart prevents saving B password under A consent',
        () async {
      // 1. Account A logs in and enables biometrics
      final service1 = BiometricService(
        prefs,
        auth: mockAuth,
        secureStorage: mockSecureStorage,
      );
      await service1.setEnabled(userId: 'user_A', enabled: true);
      await service1.saveCredentials(
        userId: 'user_A',
        email: 'a@example.com',
        password: 'password_A',
      );

      expect(service1.isEnabledForUser('user_A'), isTrue);
      expect(service1.activeBiometricUserId, equals('user_A'));

      // 2. User logs out of Account A and Account B logs in
      // Account B has NEVER given consent!
      expect(service1.isEnabledForUser('user_B'), isFalse);

      // 3. Attempting to save credentials for Account B must be rejected
      final saveBResult = await service1.saveCredentials(
        userId: 'user_B',
        email: 'b@example.com',
        password: 'password_B',
      );
      expect(saveBResult, isFalse);

      // 4. Simulate app restart (new BiometricService with same persisted storage)
      final service2 = BiometricService(
        prefs,
        auth: mockAuth,
        secureStorage: mockSecureStorage,
      );

      // Consent is still strictly false for User B and true for User A
      expect(service2.isEnabledForUser('user_B'), isFalse);
      expect(service2.isEnabledForUser('user_A'), isTrue);

      // At login screen, getCredentials for user_B returns null
      final credsB = await service2.getCredentials('user_B');
      expect(credsB, isNull);
    });

    test('disabling biometrics clears user credentials and unsets active user',
        () async {
      final service = BiometricService(
        prefs,
        auth: mockAuth,
        secureStorage: mockSecureStorage,
      );

      await service.setEnabled(userId: 'user_A', enabled: true);
      expect(service.activeBiometricUserId, equals('user_A'));

      await service.setEnabled(userId: 'user_A', enabled: false);

      expect(service.isEnabledForUser('user_A'), isFalse);
      expect(service.activeBiometricUserId, isNull);
      verify(() => mockSecureStorage.delete(key: 'bio_email_user_A')).called(1);
      verify(() => mockSecureStorage.delete(key: 'bio_password_user_A'))
          .called(1);
    });
  });
}
