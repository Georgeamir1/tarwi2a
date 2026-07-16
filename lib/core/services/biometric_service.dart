import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logger/app_logger.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final SharedPreferences _prefs;

  static const String _biometricsEnabledKey = 'biometrics_enabled';
  static const String _emailKey = 'bio_email';
  static const String _passwordKey = 'bio_password';

  BiometricService(this._prefs);

  /// Checks if biometrics is supported by the device hardware
  Future<bool> get isHardwareSupported async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      appLogger.e('[BiometricService] Error checking hardware support', error: e);
      return false;
    }
  }

  /// Checks if the user has enrolled any biometrics (fingerprint/face)
  Future<bool> get hasEnrolledBiometrics async {
    try {
      final List<BiometricType> available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (e) {
      appLogger.e('[BiometricService] Error checking enrolled biometrics', error: e);
      return false;
    }
  }

  /// Checks if biometric login is enabled by the user in settings
  bool get isEnabled {
    return _prefs.getBool(_biometricsEnabledKey) ?? false;
  }

  /// Sets whether biometric login is enabled
  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_biometricsEnabledKey, enabled);
    if (!enabled) {
      await clearCredentials();
    }
  }

  /// Authenticates using biometrics (fingerprint/FaceID)
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'يرجى تأكيد الهوية باستخدام البصمة لتسجيل الدخول',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      appLogger.e('[BiometricService] Authentication error', error: e);
      return false;
    }
  }

  /// Saves the user's login credentials securely
  Future<void> saveCredentials(String email, String password) async {
    try {
      await _secureStorage.write(key: _emailKey, value: email);
      await _secureStorage.write(key: _passwordKey, value: password);
      appLogger.d('[BiometricService] Credentials saved securely');
    } catch (e) {
      appLogger.e('[BiometricService] Error saving credentials', error: e);
    }
  }

  /// Retrieves the stored credentials. Returns a Map with email and password or null
  Future<Map<String, String>?> getCredentials() async {
    try {
      final email = await _secureStorage.read(key: _emailKey);
      final password = await _secureStorage.read(key: _passwordKey);
      if (email != null && password != null) {
        return {
          'email': email,
          'password': password,
        };
      }
    } catch (e) {
      appLogger.e('[BiometricService] Error reading credentials', error: e);
    }
    return null;
  }

  /// Clears stored credentials
  Future<void> clearCredentials() async {
    try {
      await _secureStorage.delete(key: _emailKey);
      await _secureStorage.delete(key: _passwordKey);
      appLogger.d('[BiometricService] Secure credentials cleared');
    } catch (e) {
      appLogger.e('[BiometricService] Error clearing credentials', error: e);
    }
  }
}
