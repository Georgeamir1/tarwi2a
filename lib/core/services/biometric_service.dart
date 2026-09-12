import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logger/app_logger.dart';

class BiometricService {
  final LocalAuthentication _auth;
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  static const String _legacyBiometricsEnabledKey = 'biometrics_enabled';
  static const String _legacyEmailKey = 'bio_email';
  static const String _legacyPasswordKey = 'bio_password';

  static const String _activeBiometricUserKey = 'bio_active_user_id';
  static String _userConsentKey(String userId) => 'biometrics_enabled_$userId';
  static String _userEmailKey(String userId) => 'bio_email_$userId';
  static String _userPasswordKey(String userId) => 'bio_password_$userId';

  BiometricService(
    this._prefs, {
    LocalAuthentication? auth,
    FlutterSecureStorage? secureStorage,
  })  : _auth = auth ?? LocalAuthentication(),
        _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            ) {
    _migrateLegacyConsent();
  }

  void _migrateLegacyConsent() {
    if (_prefs.containsKey(_legacyBiometricsEnabledKey)) {
      _prefs.remove(_legacyBiometricsEnabledKey);
      _secureStorage.delete(key: _legacyEmailKey);
      _secureStorage.delete(key: _legacyPasswordKey);
      appLogger.i(
          '[BiometricService] Legacy global biometric consent and credentials wiped.');
    }
  }

  /// Checks if biometrics is supported by the device hardware
  Future<bool> get isHardwareSupported async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      appLogger.e('[BiometricService] Error checking hardware support',
          error: e);
      return false;
    }
  }

  /// Checks if the user has enrolled any biometrics (fingerprint/face)
  Future<bool> get hasEnrolledBiometrics async {
    try {
      final List<BiometricType> available =
          await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (e) {
      appLogger.e('[BiometricService] Error checking enrolled biometrics',
          error: e);
      return false;
    }
  }

  /// Checks if biometric login is enabled for a specific user
  bool isEnabledForUser(String userId) {
    return _prefs.getBool(_userConsentKey(userId)) ?? false;
  }

  /// Active user ID configured for biometric login on device
  String? get activeBiometricUserId =>
      _prefs.getString(_activeBiometricUserKey);

  /// Checks if biometric login is available for login from the login screen
  bool get isBiometricsAvailableForLogin {
    final activeId = activeBiometricUserId;
    if (activeId == null) return false;
    return isEnabledForUser(activeId);
  }

  /// Sets whether biometric login is enabled for a specific user
  Future<void> setEnabled(
      {required String userId, required bool enabled}) async {
    await _prefs.setBool(_userConsentKey(userId), enabled);
    if (enabled) {
      await _prefs.setString(_activeBiometricUserKey, userId);
    } else {
      if (_prefs.getString(_activeBiometricUserKey) == userId) {
        await _prefs.remove(_activeBiometricUserKey);
      }
      await clearCredentials(userId);
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

  /// Saves the user's login credentials securely, scoped to the authenticated user ID
  Future<bool> saveCredentials({
    required String userId,
    required String email,
    required String password,
  }) async {
    if (!isEnabledForUser(userId)) {
      appLogger.w(
          '[BiometricService] Refusing to save credentials for user $userId: consent not granted');
      return false;
    }
    try {
      await _secureStorage.write(key: _userEmailKey(userId), value: email);
      await _secureStorage.write(
          key: _userPasswordKey(userId), value: password);
      await _prefs.setString(_activeBiometricUserKey, userId);
      appLogger
          .d('[BiometricService] Credentials saved securely for user $userId');
      return true;
    } catch (e) {
      appLogger.e(
          '[BiometricService] Error saving credentials for user $userId',
          error: e);
      return false;
    }
  }

  /// Retrieves stored credentials for specified user or active biometric user
  Future<Map<String, String>?> getCredentials([String? userId]) async {
    final targetUserId = userId ?? activeBiometricUserId;
    if (targetUserId == null || !isEnabledForUser(targetUserId)) {
      return null;
    }
    try {
      final email = await _secureStorage.read(key: _userEmailKey(targetUserId));
      final password =
          await _secureStorage.read(key: _userPasswordKey(targetUserId));
      if (email != null && password != null) {
        return {
          'userId': targetUserId,
          'email': email,
          'password': password,
        };
      }
    } catch (e) {
      appLogger.e('[BiometricService] Error reading credentials', error: e);
    }
    return null;
  }

  /// Clears stored credentials for specified user or active biometric user
  Future<void> clearCredentials([String? userId]) async {
    final targetUserId = userId ?? activeBiometricUserId;
    if (targetUserId == null) return;
    try {
      await _secureStorage.delete(key: _userEmailKey(targetUserId));
      await _secureStorage.delete(key: _userPasswordKey(targetUserId));
      if (_prefs.getString(_activeBiometricUserKey) == targetUserId) {
        await _prefs.remove(_activeBiometricUserKey);
      }
      appLogger.d(
          '[BiometricService] Secure credentials cleared for user $targetUserId');
    } catch (e) {
      appLogger.e(
          '[BiometricService] Error clearing credentials for user $targetUserId',
          error: e);
    }
  }
}
