import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/logger/app_logger.dart';

/// Secure implementation of [LocalStorage] that persists auth sessions
/// in hardware-backed [FlutterSecureStorage] while handling safe migration
/// from legacy [SharedPreferences].
class SecureAuthLocalStorage extends LocalStorage {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;
  final String persistSessionKey;

  Future<void> _lock = Future.value();

  SecureAuthLocalStorage({
    FlutterSecureStorage? secureStorage,
    required SharedPreferences prefs,
    required this.persistSessionKey,
  })  : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            ),
        _prefs = prefs;

  /// Serializes operations to prevent race conditions between writes and removes.
  Future<T> _runExclusive<T>(Future<T> Function() action) {
    final prev = _lock;
    final completer = Completer<T>();
    _lock = () async {
      try {
        await prev;
      } catch (_) {
        // Continue queue execution even if previous operation threw an error
      }
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, s) {
        completer.completeError(e, s);
      }
    }();
    return completer.future;
  }

  @override
  Future<void> initialize() async {
    await _runExclusive(() async {
      try {
        final secureVal = await _secureStorage.read(key: persistSessionKey);
        final hasLegacy = _prefs.containsKey(persistSessionKey);

        if (secureVal != null && secureVal.isNotEmpty) {
          // Secure session exists and wins. Clean up legacy copy if still present.
          if (hasLegacy) {
            await _prefs.remove(persistSessionKey);
            appLogger.d(
                '[SecureAuthLocalStorage] Legacy session cleaned up as secure session exists');
          }
          return;
        }

        if (hasLegacy) {
          final legacyVal = _prefs.getString(persistSessionKey);
          if (legacyVal != null && legacyVal.isNotEmpty) {
            try {
              await _secureStorage.write(
                key: persistSessionKey,
                value: legacyVal,
              );
              final verified =
                  await _secureStorage.read(key: persistSessionKey);
              if (verified == legacyVal) {
                await _prefs.remove(persistSessionKey);
                appLogger.i(
                    '[SecureAuthLocalStorage] Auth session successfully migrated to secure storage');
              } else {
                appLogger.w(
                    '[SecureAuthLocalStorage] Migration verification failed; retaining legacy session');
              }
            } catch (e, s) {
              // Never delete legacy source on failure, and never log sensitive token content
              appLogger.e(
                  '[SecureAuthLocalStorage] Failed to write migrated session to secure storage',
                  error: e,
                  stackTrace: s);
            }
          }
        }
      } catch (e, s) {
        appLogger.e(
            '[SecureAuthLocalStorage] Error during storage initialization',
            error: e,
            stackTrace: s);
      }
    });
  }

  @override
  Future<bool> hasAccessToken() async {
    return _runExclusive(() async {
      try {
        final secureVal = await _secureStorage.read(key: persistSessionKey);
        if (secureVal != null && secureVal.isNotEmpty) {
          return true;
        }
      } catch (e, s) {
        appLogger.e(
            '[SecureAuthLocalStorage] Error reading secure storage in hasAccessToken',
            error: e,
            stackTrace: s);
      }
      return _prefs.containsKey(persistSessionKey);
    });
  }

  @override
  Future<String?> accessToken() async {
    return _runExclusive(() async {
      try {
        final secureVal = await _secureStorage.read(key: persistSessionKey);
        if (secureVal != null && secureVal.isNotEmpty) {
          if (_prefs.containsKey(persistSessionKey)) {
            await _prefs.remove(persistSessionKey);
          }
          return secureVal;
        }
      } catch (e, s) {
        appLogger.e(
            '[SecureAuthLocalStorage] Error reading secure storage in accessToken',
            error: e,
            stackTrace: s);
      }
      return _prefs.getString(persistSessionKey);
    });
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    return _runExclusive(() async {
      await _secureStorage.write(
        key: persistSessionKey,
        value: persistSessionString,
      );
      if (_prefs.containsKey(persistSessionKey)) {
        await _prefs.remove(persistSessionKey);
      }
    });
  }

  @override
  Future<void> removePersistedSession() async {
    return _runExclusive(() async {
      dynamic secureError;
      dynamic prefsError;

      try {
        await _secureStorage.delete(key: persistSessionKey);
      } catch (e) {
        secureError = e;
      }

      try {
        await _prefs.remove(persistSessionKey);
      } catch (e) {
        prefsError = e;
      }

      if (secureError != null || prefsError != null) {
        final msg =
            'Failed to remove persisted session (secure=$secureError, prefs=$prefsError)';
        appLogger.e('[SecureAuthLocalStorage] $msg');
        throw Exception(msg);
      }
      appLogger.d(
          '[SecureAuthLocalStorage] Persisted session removed successfully from all stores');
    });
  }
}
