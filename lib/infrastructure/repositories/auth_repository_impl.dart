import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, AuthResponse>> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'customer',
  }) async {
    try {
      final result = await _remoteDataSource.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      appLogger.d('[AuthRepo] signUp ✅ — returning Right(AuthResponse)');
      return right(result);
    } on AuthException catch (e, s) {
      appLogger.e('[AuthRepo] signUp ❌ AuthException — ${e.message}',
          error: e, stackTrace: s);
      return left(const Failure.server(message: 'فشل في إنشاء الحساب'));
    } catch (e, s) {
      appLogger.e('[AuthRepo] signUp ❌ unexpected', error: e, stackTrace: s);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      appLogger.d('[AuthRepo] signIn ✅ — returning Right(AuthResponse)');
      return right(result);
    } on AuthException catch (e, s) {
      appLogger.e('[AuthRepo] signIn ❌ AuthException — ${e.message}',
          error: e, stackTrace: s);
      return left(const Failure.server(
          message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة'));
    } catch (e, s) {
      appLogger.e('[AuthRepo] signIn ❌ unexpected', error: e, stackTrace: s);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      appLogger.d('[AuthRepo] signOut ✅ — returning Right(void)');
      return right<Failure, void>(null);
    } catch (e, s) {
      appLogger.e('[AuthRepo] signOut ❌ unexpected', error: e, stackTrace: s);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  User? get currentUser {
    final user = _remoteDataSource.currentUser;
    appLogger.d(
        '[AuthRepo] currentUser — ${user != null ? "user: ${user.id}" : "null"}');
    return user;
  }

  @override
  Stream<AuthState> get authStateChanges {
    appLogger.d('[AuthRepo] authStateChanges stream requested');
    return _remoteDataSource.authStateChanges;
  }
}
