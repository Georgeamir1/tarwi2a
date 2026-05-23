import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

@freezed
sealed class AuthFailure with _$AuthFailure {
  const factory AuthFailure.invalidEmail({required String message}) =
      _InvalidEmail;
  const factory AuthFailure.weakPassword({required String message}) =
      _WeakPassword;
  const factory AuthFailure.emailAlreadyInUse({required String message}) =
      _EmailAlreadyInUse;
  const factory AuthFailure.invalidCredentials({required String message}) =
      _InvalidCredentials;
  const factory AuthFailure.userNotFound({required String message}) =
      _UserNotFound;
  const factory AuthFailure.sessionExpired({required String message}) =
      _SessionExpired;
}
