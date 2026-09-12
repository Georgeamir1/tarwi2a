import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../failures/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> signUp({
    required String email,
    required String password,
    required String name,
    String role,
  });

  Future<Either<Failure, AuthResponse>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> resendVerificationEmail(String email);

  Future<Either<Failure, void>> resetPassword(String email);

  Future<Either<Failure, void>> updatePassword(String newPassword);

  Future<Either<Failure, void>> deleteAccount();

  User? get currentUser;

  Stream<AuthState> get authStateChanges;
}
