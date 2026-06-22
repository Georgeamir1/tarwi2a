import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/profile_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  AuthCubit({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  })  : _authRepository = authRepository,
        _profileRepository = profileRepository,
        super(const AuthState.initial()) {
    appLogger.d('[AuthCubit] created — state: AuthInitial');
  }

  void checkAuthStatus() {
    appLogger.d('[AuthCubit] checkAuthStatus() called');
    final user = _authRepository.currentUser;
    if (user != null) {
      appLogger
          .d('[AuthCubit] user found — id: ${user.id}, email: ${user.email}');
      _fetchProfile(user.id);
    } else {
      appLogger.d('[AuthCubit] no current user — ➜ Unauthenticated');
      emit(const AuthState.unauthenticated());
    }
    _authSubscription?.cancel();
    appLogger.d('[AuthCubit] subscribing to authStateChanges stream');
    _authSubscription = _authRepository.authStateChanges.listen((event) {
      appLogger.d(
          '[AuthCubit] authStateChanges event — ${event.event.name}, session: ${event.session != null}');
      if (event.event == supabase.AuthChangeEvent.signedIn &&
          event.session != null) {
        appLogger.d(
            '[AuthCubit] signedIn detected — fetching profile for user: ${event.session!.user.id}');
        _fetchProfile(event.session!.user.id);
      } else if (event.event == supabase.AuthChangeEvent.signedOut) {
        appLogger.d('[AuthCubit] signedOut detected — ➜ Unauthenticated');
        emit(const AuthState.unauthenticated());
      } else {
        appLogger.d(
            '[AuthCubit] authStateChanges — unhandled event: ${event.event.name}');
      }
    });
  }

  Future<void> _fetchProfile(String userId) async {
    appLogger.d('[AuthCubit] _fetchProfile — userId: $userId');
    appLogger.d('[AuthCubit] ➜ Loading');
    emit(const AuthState.loading());
    final result = await _profileRepository.getProfile(userId);
    result.fold(
      (failure) {
        appLogger.e(
            '[AuthCubit] _fetchProfile ❌ — ${failure.map(server: (f) => f.message, network: (f) => f.message, validation: (f) => f.message, unexpected: (f) => f.message)}');
        appLogger.d('[AuthCubit] ➜ AuthError');
        emit(AuthState.error(failure));
      },
      (profile) {
        if (profile != null) {
          appLogger.d(
              '[AuthCubit] _fetchProfile ✅ — name: ${profile.name}, role: ${profile.role.value}');
          appLogger.d('[AuthCubit] ➜ Authenticated');
          emit(AuthState.authenticated(profile));
        } else {
          appLogger
              .d('[AuthCubit] _fetchProfile ⚠ — profile is null (not in DB)');
          appLogger.d('[AuthCubit] ➜ Unauthenticated');
          emit(const AuthState.unauthenticated());
        }
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'customer',
  }) async {
    appLogger.d(
        '[AuthCubit] signUp called — email: $email, name: $name, role: $role');
    appLogger.d('[AuthCubit] ➜ Loading');
    emit(const AuthState.loading());
    final result = await _authRepository.signUp(
      email: email,
      password: password,
      name: name,
      role: role,
    );
    result.fold(
      (failure) {
        appLogger.e(
            '[AuthCubit] signUp ❌ — ${failure.map(server: (f) => f.message, network: (f) => f.message, validation: (f) => f.message, unexpected: (f) => f.message)}');
        appLogger.d('[AuthCubit] ➜ AuthError');
        emit(AuthState.error(failure));
      },
      (_) {
        appLogger.d(
            '[AuthCubit] signUp ✅ — waiting for authStateChanges stream to fire');
      },
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    appLogger.d('[AuthCubit] signIn called — email: $email');
    appLogger.d('[AuthCubit] ➜ Loading');
    emit(const AuthState.loading());
    final result = await _authRepository.signIn(
      email: email,
      password: password,
    );
    result.fold(
      (failure) {
        appLogger.e(
            '[AuthCubit] signIn ❌ — ${failure.map(server: (f) => f.message, network: (f) => f.message, validation: (f) => f.message, unexpected: (f) => f.message)}');
        appLogger.d('[AuthCubit] ➜ AuthError');
        emit(AuthState.error(failure));
      },
      (_) {
        appLogger.d(
            '[AuthCubit] signIn ✅ — waiting for authStateChanges stream to fire');
      },
    );
  }

  Future<Either<Failure, void>> signOut() async {
    appLogger.d('[AuthCubit] signOut called');
    final result = await _authRepository.signOut();
    result.fold(
      (failure) {
        appLogger.e(
            '[AuthCubit] signOut ❌ — ${failure.map(server: (f) => f.message, network: (f) => f.message, validation: (f) => f.message, unexpected: (f) => f.message)}');
      },
      (_) {
        appLogger.d(
            '[AuthCubit] signOut ✅ — authStateChanges stream should emit signedOut');
      },
    );
    return result;
  }

  @override
  Future<void> close() {
    appLogger.d('[AuthCubit] close — cancelling subscription');
    _authSubscription?.cancel();
    return super.close();
  }
}
