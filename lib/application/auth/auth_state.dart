part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(UserProfile profile) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.awaitingEmailVerification(String email) =
      AuthAwaitingEmailVerification;
  const factory AuthState.recoveryRequired() = AuthRecoveryRequired;
  const factory AuthState.error(Failure failure) = AuthError;

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserProfile profile;

  const Authenticated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthAwaitingEmailVerification extends AuthState {
  final String email;

  const AuthAwaitingEmailVerification(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthRecoveryRequired extends AuthState {
  const AuthRecoveryRequired();
}

class AuthError extends AuthState {
  final Failure failure;

  const AuthError(this.failure);

  @override
  List<Object?> get props => [failure];
}
