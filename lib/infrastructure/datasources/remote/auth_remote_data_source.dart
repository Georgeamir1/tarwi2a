import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/logger/app_logger.dart';

class AuthRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'customer',
  }) async {
    appLogger
        .d('[AuthDS] signUp called — email: $email, name: $name, role: $role');
    try {
      final result = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role},
      );
      appLogger.d(
          '[AuthDS] signUp ✅ — user: ${result.user?.id}, session: ${result.session != null}');
      return result;
    } catch (e, s) {
      appLogger.e('[AuthDS] signUp ❌ failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    appLogger.d('[AuthDS] signIn called — email: $email');
    try {
      final result = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      appLogger.d(
          '[AuthDS] signIn ✅ — user: ${result.user?.id}, session: ${result.session != null}');
      return result;
    } catch (e, s) {
      appLogger.e('[AuthDS] signIn ❌ failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> signOut() async {
    appLogger.d('[AuthDS] signOut called');
    try {
      await _client.auth.signOut();
      appLogger.d('[AuthDS] signOut ✅');
    } catch (e, s) {
      appLogger.e('[AuthDS] signOut ❌ failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    appLogger.d('[AuthDS] resendVerificationEmail called — email: $email');
    try {
      await _client.auth.resend(type: OtpType.signup, email: email);
      appLogger.d('[AuthDS] resendVerificationEmail ✅');
    } catch (e, s) {
      appLogger.e('[AuthDS] resendVerificationEmail ❌ failed',
          error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> resetPassword(String email, {String? redirectTo}) async {
    appLogger.d('[AuthDS] resetPassword called — email: $email');
    try {
      await _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
      appLogger.d('[AuthDS] resetPassword ✅');
    } catch (e, s) {
      appLogger.e('[AuthDS] resetPassword ❌ failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    appLogger.d('[AuthDS] updatePassword called');
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      appLogger.d('[AuthDS] updatePassword ✅');
    } catch (e, s) {
      appLogger.e('[AuthDS] updatePassword ❌ failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    appLogger.d('[AuthDS] deleteAccount called');
    try {
      final response = await _client.functions.invoke('delete-account');
      final status = response.status;
      if (status >= 400) {
        String? err;
        if (response.data is Map) {
          err = response.data['error'] as String?;
        }
        throw Exception(err ?? 'فشل حذف الحساب (رمز $status)');
      }
      appLogger.d('[AuthDS] deleteAccount ✅');
    } catch (e, s) {
      appLogger.e('[AuthDS] deleteAccount ❌ failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  User? get currentUser {
    final user = _client.auth.currentUser;
    appLogger.d(
        '[AuthDS] currentUser — ${user != null ? "user: ${user.id}" : "null (not logged in)"}');
    return user;
  }

  Stream<AuthState> get authStateChanges {
    appLogger.d('[AuthDS] authStateChanges stream subscribed');
    return _client.auth.onAuthStateChange.map((event) {
      appLogger.d('[AuthDS] authStateChanges event — ${event.event.name}');
      return event;
    });
  }
}
