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
