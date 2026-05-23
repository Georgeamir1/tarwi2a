// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthFailure {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) invalidEmail,
    required TResult Function(String message) weakPassword,
    required TResult Function(String message) emailAlreadyInUse,
    required TResult Function(String message) invalidCredentials,
    required TResult Function(String message) userNotFound,
    required TResult Function(String message) sessionExpired,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? invalidEmail,
    TResult? Function(String message)? weakPassword,
    TResult? Function(String message)? emailAlreadyInUse,
    TResult? Function(String message)? invalidCredentials,
    TResult? Function(String message)? userNotFound,
    TResult? Function(String message)? sessionExpired,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? invalidEmail,
    TResult Function(String message)? weakPassword,
    TResult Function(String message)? emailAlreadyInUse,
    TResult Function(String message)? invalidCredentials,
    TResult Function(String message)? userNotFound,
    TResult Function(String message)? sessionExpired,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InvalidEmail value) invalidEmail,
    required TResult Function(_WeakPassword value) weakPassword,
    required TResult Function(_EmailAlreadyInUse value) emailAlreadyInUse,
    required TResult Function(_InvalidCredentials value) invalidCredentials,
    required TResult Function(_UserNotFound value) userNotFound,
    required TResult Function(_SessionExpired value) sessionExpired,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InvalidEmail value)? invalidEmail,
    TResult? Function(_WeakPassword value)? weakPassword,
    TResult? Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult? Function(_InvalidCredentials value)? invalidCredentials,
    TResult? Function(_UserNotFound value)? userNotFound,
    TResult? Function(_SessionExpired value)? sessionExpired,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InvalidEmail value)? invalidEmail,
    TResult Function(_WeakPassword value)? weakPassword,
    TResult Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult Function(_InvalidCredentials value)? invalidCredentials,
    TResult Function(_UserNotFound value)? userNotFound,
    TResult Function(_SessionExpired value)? sessionExpired,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthFailureCopyWith<AuthFailure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthFailureCopyWith<$Res> {
  factory $AuthFailureCopyWith(
          AuthFailure value, $Res Function(AuthFailure) then) =
      _$AuthFailureCopyWithImpl<$Res, AuthFailure>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AuthFailureCopyWithImpl<$Res, $Val extends AuthFailure>
    implements $AuthFailureCopyWith<$Res> {
  _$AuthFailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvalidEmailImplCopyWith<$Res>
    implements $AuthFailureCopyWith<$Res> {
  factory _$$InvalidEmailImplCopyWith(
          _$InvalidEmailImpl value, $Res Function(_$InvalidEmailImpl) then) =
      __$$InvalidEmailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$InvalidEmailImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$InvalidEmailImpl>
    implements _$$InvalidEmailImplCopyWith<$Res> {
  __$$InvalidEmailImplCopyWithImpl(
      _$InvalidEmailImpl _value, $Res Function(_$InvalidEmailImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$InvalidEmailImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$InvalidEmailImpl implements _InvalidEmail {
  const _$InvalidEmailImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'AuthFailure.invalidEmail(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvalidEmailImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvalidEmailImplCopyWith<_$InvalidEmailImpl> get copyWith =>
      __$$InvalidEmailImplCopyWithImpl<_$InvalidEmailImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) invalidEmail,
    required TResult Function(String message) weakPassword,
    required TResult Function(String message) emailAlreadyInUse,
    required TResult Function(String message) invalidCredentials,
    required TResult Function(String message) userNotFound,
    required TResult Function(String message) sessionExpired,
  }) {
    return invalidEmail(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? invalidEmail,
    TResult? Function(String message)? weakPassword,
    TResult? Function(String message)? emailAlreadyInUse,
    TResult? Function(String message)? invalidCredentials,
    TResult? Function(String message)? userNotFound,
    TResult? Function(String message)? sessionExpired,
  }) {
    return invalidEmail?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? invalidEmail,
    TResult Function(String message)? weakPassword,
    TResult Function(String message)? emailAlreadyInUse,
    TResult Function(String message)? invalidCredentials,
    TResult Function(String message)? userNotFound,
    TResult Function(String message)? sessionExpired,
    required TResult orElse(),
  }) {
    if (invalidEmail != null) {
      return invalidEmail(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InvalidEmail value) invalidEmail,
    required TResult Function(_WeakPassword value) weakPassword,
    required TResult Function(_EmailAlreadyInUse value) emailAlreadyInUse,
    required TResult Function(_InvalidCredentials value) invalidCredentials,
    required TResult Function(_UserNotFound value) userNotFound,
    required TResult Function(_SessionExpired value) sessionExpired,
  }) {
    return invalidEmail(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InvalidEmail value)? invalidEmail,
    TResult? Function(_WeakPassword value)? weakPassword,
    TResult? Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult? Function(_InvalidCredentials value)? invalidCredentials,
    TResult? Function(_UserNotFound value)? userNotFound,
    TResult? Function(_SessionExpired value)? sessionExpired,
  }) {
    return invalidEmail?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InvalidEmail value)? invalidEmail,
    TResult Function(_WeakPassword value)? weakPassword,
    TResult Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult Function(_InvalidCredentials value)? invalidCredentials,
    TResult Function(_UserNotFound value)? userNotFound,
    TResult Function(_SessionExpired value)? sessionExpired,
    required TResult orElse(),
  }) {
    if (invalidEmail != null) {
      return invalidEmail(this);
    }
    return orElse();
  }
}

abstract class _InvalidEmail implements AuthFailure {
  const factory _InvalidEmail({required final String message}) =
      _$InvalidEmailImpl;

  @override
  String get message;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvalidEmailImplCopyWith<_$InvalidEmailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WeakPasswordImplCopyWith<$Res>
    implements $AuthFailureCopyWith<$Res> {
  factory _$$WeakPasswordImplCopyWith(
          _$WeakPasswordImpl value, $Res Function(_$WeakPasswordImpl) then) =
      __$$WeakPasswordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$WeakPasswordImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$WeakPasswordImpl>
    implements _$$WeakPasswordImplCopyWith<$Res> {
  __$$WeakPasswordImplCopyWithImpl(
      _$WeakPasswordImpl _value, $Res Function(_$WeakPasswordImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$WeakPasswordImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$WeakPasswordImpl implements _WeakPassword {
  const _$WeakPasswordImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'AuthFailure.weakPassword(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeakPasswordImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeakPasswordImplCopyWith<_$WeakPasswordImpl> get copyWith =>
      __$$WeakPasswordImplCopyWithImpl<_$WeakPasswordImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) invalidEmail,
    required TResult Function(String message) weakPassword,
    required TResult Function(String message) emailAlreadyInUse,
    required TResult Function(String message) invalidCredentials,
    required TResult Function(String message) userNotFound,
    required TResult Function(String message) sessionExpired,
  }) {
    return weakPassword(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? invalidEmail,
    TResult? Function(String message)? weakPassword,
    TResult? Function(String message)? emailAlreadyInUse,
    TResult? Function(String message)? invalidCredentials,
    TResult? Function(String message)? userNotFound,
    TResult? Function(String message)? sessionExpired,
  }) {
    return weakPassword?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? invalidEmail,
    TResult Function(String message)? weakPassword,
    TResult Function(String message)? emailAlreadyInUse,
    TResult Function(String message)? invalidCredentials,
    TResult Function(String message)? userNotFound,
    TResult Function(String message)? sessionExpired,
    required TResult orElse(),
  }) {
    if (weakPassword != null) {
      return weakPassword(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InvalidEmail value) invalidEmail,
    required TResult Function(_WeakPassword value) weakPassword,
    required TResult Function(_EmailAlreadyInUse value) emailAlreadyInUse,
    required TResult Function(_InvalidCredentials value) invalidCredentials,
    required TResult Function(_UserNotFound value) userNotFound,
    required TResult Function(_SessionExpired value) sessionExpired,
  }) {
    return weakPassword(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InvalidEmail value)? invalidEmail,
    TResult? Function(_WeakPassword value)? weakPassword,
    TResult? Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult? Function(_InvalidCredentials value)? invalidCredentials,
    TResult? Function(_UserNotFound value)? userNotFound,
    TResult? Function(_SessionExpired value)? sessionExpired,
  }) {
    return weakPassword?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InvalidEmail value)? invalidEmail,
    TResult Function(_WeakPassword value)? weakPassword,
    TResult Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult Function(_InvalidCredentials value)? invalidCredentials,
    TResult Function(_UserNotFound value)? userNotFound,
    TResult Function(_SessionExpired value)? sessionExpired,
    required TResult orElse(),
  }) {
    if (weakPassword != null) {
      return weakPassword(this);
    }
    return orElse();
  }
}

abstract class _WeakPassword implements AuthFailure {
  const factory _WeakPassword({required final String message}) =
      _$WeakPasswordImpl;

  @override
  String get message;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeakPasswordImplCopyWith<_$WeakPasswordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EmailAlreadyInUseImplCopyWith<$Res>
    implements $AuthFailureCopyWith<$Res> {
  factory _$$EmailAlreadyInUseImplCopyWith(_$EmailAlreadyInUseImpl value,
          $Res Function(_$EmailAlreadyInUseImpl) then) =
      __$$EmailAlreadyInUseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$EmailAlreadyInUseImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$EmailAlreadyInUseImpl>
    implements _$$EmailAlreadyInUseImplCopyWith<$Res> {
  __$$EmailAlreadyInUseImplCopyWithImpl(_$EmailAlreadyInUseImpl _value,
      $Res Function(_$EmailAlreadyInUseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$EmailAlreadyInUseImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$EmailAlreadyInUseImpl implements _EmailAlreadyInUse {
  const _$EmailAlreadyInUseImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'AuthFailure.emailAlreadyInUse(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailAlreadyInUseImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailAlreadyInUseImplCopyWith<_$EmailAlreadyInUseImpl> get copyWith =>
      __$$EmailAlreadyInUseImplCopyWithImpl<_$EmailAlreadyInUseImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) invalidEmail,
    required TResult Function(String message) weakPassword,
    required TResult Function(String message) emailAlreadyInUse,
    required TResult Function(String message) invalidCredentials,
    required TResult Function(String message) userNotFound,
    required TResult Function(String message) sessionExpired,
  }) {
    return emailAlreadyInUse(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? invalidEmail,
    TResult? Function(String message)? weakPassword,
    TResult? Function(String message)? emailAlreadyInUse,
    TResult? Function(String message)? invalidCredentials,
    TResult? Function(String message)? userNotFound,
    TResult? Function(String message)? sessionExpired,
  }) {
    return emailAlreadyInUse?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? invalidEmail,
    TResult Function(String message)? weakPassword,
    TResult Function(String message)? emailAlreadyInUse,
    TResult Function(String message)? invalidCredentials,
    TResult Function(String message)? userNotFound,
    TResult Function(String message)? sessionExpired,
    required TResult orElse(),
  }) {
    if (emailAlreadyInUse != null) {
      return emailAlreadyInUse(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InvalidEmail value) invalidEmail,
    required TResult Function(_WeakPassword value) weakPassword,
    required TResult Function(_EmailAlreadyInUse value) emailAlreadyInUse,
    required TResult Function(_InvalidCredentials value) invalidCredentials,
    required TResult Function(_UserNotFound value) userNotFound,
    required TResult Function(_SessionExpired value) sessionExpired,
  }) {
    return emailAlreadyInUse(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InvalidEmail value)? invalidEmail,
    TResult? Function(_WeakPassword value)? weakPassword,
    TResult? Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult? Function(_InvalidCredentials value)? invalidCredentials,
    TResult? Function(_UserNotFound value)? userNotFound,
    TResult? Function(_SessionExpired value)? sessionExpired,
  }) {
    return emailAlreadyInUse?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InvalidEmail value)? invalidEmail,
    TResult Function(_WeakPassword value)? weakPassword,
    TResult Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult Function(_InvalidCredentials value)? invalidCredentials,
    TResult Function(_UserNotFound value)? userNotFound,
    TResult Function(_SessionExpired value)? sessionExpired,
    required TResult orElse(),
  }) {
    if (emailAlreadyInUse != null) {
      return emailAlreadyInUse(this);
    }
    return orElse();
  }
}

abstract class _EmailAlreadyInUse implements AuthFailure {
  const factory _EmailAlreadyInUse({required final String message}) =
      _$EmailAlreadyInUseImpl;

  @override
  String get message;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailAlreadyInUseImplCopyWith<_$EmailAlreadyInUseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$InvalidCredentialsImplCopyWith<$Res>
    implements $AuthFailureCopyWith<$Res> {
  factory _$$InvalidCredentialsImplCopyWith(_$InvalidCredentialsImpl value,
          $Res Function(_$InvalidCredentialsImpl) then) =
      __$$InvalidCredentialsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$InvalidCredentialsImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$InvalidCredentialsImpl>
    implements _$$InvalidCredentialsImplCopyWith<$Res> {
  __$$InvalidCredentialsImplCopyWithImpl(_$InvalidCredentialsImpl _value,
      $Res Function(_$InvalidCredentialsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$InvalidCredentialsImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$InvalidCredentialsImpl implements _InvalidCredentials {
  const _$InvalidCredentialsImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'AuthFailure.invalidCredentials(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvalidCredentialsImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvalidCredentialsImplCopyWith<_$InvalidCredentialsImpl> get copyWith =>
      __$$InvalidCredentialsImplCopyWithImpl<_$InvalidCredentialsImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) invalidEmail,
    required TResult Function(String message) weakPassword,
    required TResult Function(String message) emailAlreadyInUse,
    required TResult Function(String message) invalidCredentials,
    required TResult Function(String message) userNotFound,
    required TResult Function(String message) sessionExpired,
  }) {
    return invalidCredentials(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? invalidEmail,
    TResult? Function(String message)? weakPassword,
    TResult? Function(String message)? emailAlreadyInUse,
    TResult? Function(String message)? invalidCredentials,
    TResult? Function(String message)? userNotFound,
    TResult? Function(String message)? sessionExpired,
  }) {
    return invalidCredentials?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? invalidEmail,
    TResult Function(String message)? weakPassword,
    TResult Function(String message)? emailAlreadyInUse,
    TResult Function(String message)? invalidCredentials,
    TResult Function(String message)? userNotFound,
    TResult Function(String message)? sessionExpired,
    required TResult orElse(),
  }) {
    if (invalidCredentials != null) {
      return invalidCredentials(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InvalidEmail value) invalidEmail,
    required TResult Function(_WeakPassword value) weakPassword,
    required TResult Function(_EmailAlreadyInUse value) emailAlreadyInUse,
    required TResult Function(_InvalidCredentials value) invalidCredentials,
    required TResult Function(_UserNotFound value) userNotFound,
    required TResult Function(_SessionExpired value) sessionExpired,
  }) {
    return invalidCredentials(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InvalidEmail value)? invalidEmail,
    TResult? Function(_WeakPassword value)? weakPassword,
    TResult? Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult? Function(_InvalidCredentials value)? invalidCredentials,
    TResult? Function(_UserNotFound value)? userNotFound,
    TResult? Function(_SessionExpired value)? sessionExpired,
  }) {
    return invalidCredentials?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InvalidEmail value)? invalidEmail,
    TResult Function(_WeakPassword value)? weakPassword,
    TResult Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult Function(_InvalidCredentials value)? invalidCredentials,
    TResult Function(_UserNotFound value)? userNotFound,
    TResult Function(_SessionExpired value)? sessionExpired,
    required TResult orElse(),
  }) {
    if (invalidCredentials != null) {
      return invalidCredentials(this);
    }
    return orElse();
  }
}

abstract class _InvalidCredentials implements AuthFailure {
  const factory _InvalidCredentials({required final String message}) =
      _$InvalidCredentialsImpl;

  @override
  String get message;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvalidCredentialsImplCopyWith<_$InvalidCredentialsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UserNotFoundImplCopyWith<$Res>
    implements $AuthFailureCopyWith<$Res> {
  factory _$$UserNotFoundImplCopyWith(
          _$UserNotFoundImpl value, $Res Function(_$UserNotFoundImpl) then) =
      __$$UserNotFoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UserNotFoundImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$UserNotFoundImpl>
    implements _$$UserNotFoundImplCopyWith<$Res> {
  __$$UserNotFoundImplCopyWithImpl(
      _$UserNotFoundImpl _value, $Res Function(_$UserNotFoundImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$UserNotFoundImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UserNotFoundImpl implements _UserNotFound {
  const _$UserNotFoundImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'AuthFailure.userNotFound(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserNotFoundImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserNotFoundImplCopyWith<_$UserNotFoundImpl> get copyWith =>
      __$$UserNotFoundImplCopyWithImpl<_$UserNotFoundImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) invalidEmail,
    required TResult Function(String message) weakPassword,
    required TResult Function(String message) emailAlreadyInUse,
    required TResult Function(String message) invalidCredentials,
    required TResult Function(String message) userNotFound,
    required TResult Function(String message) sessionExpired,
  }) {
    return userNotFound(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? invalidEmail,
    TResult? Function(String message)? weakPassword,
    TResult? Function(String message)? emailAlreadyInUse,
    TResult? Function(String message)? invalidCredentials,
    TResult? Function(String message)? userNotFound,
    TResult? Function(String message)? sessionExpired,
  }) {
    return userNotFound?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? invalidEmail,
    TResult Function(String message)? weakPassword,
    TResult Function(String message)? emailAlreadyInUse,
    TResult Function(String message)? invalidCredentials,
    TResult Function(String message)? userNotFound,
    TResult Function(String message)? sessionExpired,
    required TResult orElse(),
  }) {
    if (userNotFound != null) {
      return userNotFound(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InvalidEmail value) invalidEmail,
    required TResult Function(_WeakPassword value) weakPassword,
    required TResult Function(_EmailAlreadyInUse value) emailAlreadyInUse,
    required TResult Function(_InvalidCredentials value) invalidCredentials,
    required TResult Function(_UserNotFound value) userNotFound,
    required TResult Function(_SessionExpired value) sessionExpired,
  }) {
    return userNotFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InvalidEmail value)? invalidEmail,
    TResult? Function(_WeakPassword value)? weakPassword,
    TResult? Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult? Function(_InvalidCredentials value)? invalidCredentials,
    TResult? Function(_UserNotFound value)? userNotFound,
    TResult? Function(_SessionExpired value)? sessionExpired,
  }) {
    return userNotFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InvalidEmail value)? invalidEmail,
    TResult Function(_WeakPassword value)? weakPassword,
    TResult Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult Function(_InvalidCredentials value)? invalidCredentials,
    TResult Function(_UserNotFound value)? userNotFound,
    TResult Function(_SessionExpired value)? sessionExpired,
    required TResult orElse(),
  }) {
    if (userNotFound != null) {
      return userNotFound(this);
    }
    return orElse();
  }
}

abstract class _UserNotFound implements AuthFailure {
  const factory _UserNotFound({required final String message}) =
      _$UserNotFoundImpl;

  @override
  String get message;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserNotFoundImplCopyWith<_$UserNotFoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SessionExpiredImplCopyWith<$Res>
    implements $AuthFailureCopyWith<$Res> {
  factory _$$SessionExpiredImplCopyWith(_$SessionExpiredImpl value,
          $Res Function(_$SessionExpiredImpl) then) =
      __$$SessionExpiredImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$SessionExpiredImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$SessionExpiredImpl>
    implements _$$SessionExpiredImplCopyWith<$Res> {
  __$$SessionExpiredImplCopyWithImpl(
      _$SessionExpiredImpl _value, $Res Function(_$SessionExpiredImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$SessionExpiredImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SessionExpiredImpl implements _SessionExpired {
  const _$SessionExpiredImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'AuthFailure.sessionExpired(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionExpiredImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionExpiredImplCopyWith<_$SessionExpiredImpl> get copyWith =>
      __$$SessionExpiredImplCopyWithImpl<_$SessionExpiredImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) invalidEmail,
    required TResult Function(String message) weakPassword,
    required TResult Function(String message) emailAlreadyInUse,
    required TResult Function(String message) invalidCredentials,
    required TResult Function(String message) userNotFound,
    required TResult Function(String message) sessionExpired,
  }) {
    return sessionExpired(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? invalidEmail,
    TResult? Function(String message)? weakPassword,
    TResult? Function(String message)? emailAlreadyInUse,
    TResult? Function(String message)? invalidCredentials,
    TResult? Function(String message)? userNotFound,
    TResult? Function(String message)? sessionExpired,
  }) {
    return sessionExpired?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? invalidEmail,
    TResult Function(String message)? weakPassword,
    TResult Function(String message)? emailAlreadyInUse,
    TResult Function(String message)? invalidCredentials,
    TResult Function(String message)? userNotFound,
    TResult Function(String message)? sessionExpired,
    required TResult orElse(),
  }) {
    if (sessionExpired != null) {
      return sessionExpired(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InvalidEmail value) invalidEmail,
    required TResult Function(_WeakPassword value) weakPassword,
    required TResult Function(_EmailAlreadyInUse value) emailAlreadyInUse,
    required TResult Function(_InvalidCredentials value) invalidCredentials,
    required TResult Function(_UserNotFound value) userNotFound,
    required TResult Function(_SessionExpired value) sessionExpired,
  }) {
    return sessionExpired(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InvalidEmail value)? invalidEmail,
    TResult? Function(_WeakPassword value)? weakPassword,
    TResult? Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult? Function(_InvalidCredentials value)? invalidCredentials,
    TResult? Function(_UserNotFound value)? userNotFound,
    TResult? Function(_SessionExpired value)? sessionExpired,
  }) {
    return sessionExpired?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InvalidEmail value)? invalidEmail,
    TResult Function(_WeakPassword value)? weakPassword,
    TResult Function(_EmailAlreadyInUse value)? emailAlreadyInUse,
    TResult Function(_InvalidCredentials value)? invalidCredentials,
    TResult Function(_UserNotFound value)? userNotFound,
    TResult Function(_SessionExpired value)? sessionExpired,
    required TResult orElse(),
  }) {
    if (sessionExpired != null) {
      return sessionExpired(this);
    }
    return orElse();
  }
}

abstract class _SessionExpired implements AuthFailure {
  const factory _SessionExpired({required final String message}) =
      _$SessionExpiredImpl;

  @override
  String get message;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionExpiredImplCopyWith<_$SessionExpiredImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
