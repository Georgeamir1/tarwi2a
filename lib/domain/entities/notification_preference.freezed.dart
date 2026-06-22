// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_preference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NotificationPreference {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  bool get orderUpdates => throw _privateConstructorUsedError;
  bool get promotions => throw _privateConstructorUsedError;
  bool get pushEnabled => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPreferenceCopyWith<NotificationPreference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPreferenceCopyWith<$Res> {
  factory $NotificationPreferenceCopyWith(NotificationPreference value,
          $Res Function(NotificationPreference) then) =
      _$NotificationPreferenceCopyWithImpl<$Res, NotificationPreference>;
  @useResult
  $Res call(
      {String id,
      String userId,
      bool orderUpdates,
      bool promotions,
      bool pushEnabled,
      DateTime updatedAt});
}

/// @nodoc
class _$NotificationPreferenceCopyWithImpl<$Res,
        $Val extends NotificationPreference>
    implements $NotificationPreferenceCopyWith<$Res> {
  _$NotificationPreferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? orderUpdates = null,
    Object? promotions = null,
    Object? pushEnabled = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      orderUpdates: null == orderUpdates
          ? _value.orderUpdates
          : orderUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      promotions: null == promotions
          ? _value.promotions
          : promotions // ignore: cast_nullable_to_non_nullable
              as bool,
      pushEnabled: null == pushEnabled
          ? _value.pushEnabled
          : pushEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationPreferenceImplCopyWith<$Res>
    implements $NotificationPreferenceCopyWith<$Res> {
  factory _$$NotificationPreferenceImplCopyWith(
          _$NotificationPreferenceImpl value,
          $Res Function(_$NotificationPreferenceImpl) then) =
      __$$NotificationPreferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      bool orderUpdates,
      bool promotions,
      bool pushEnabled,
      DateTime updatedAt});
}

/// @nodoc
class __$$NotificationPreferenceImplCopyWithImpl<$Res>
    extends _$NotificationPreferenceCopyWithImpl<$Res,
        _$NotificationPreferenceImpl>
    implements _$$NotificationPreferenceImplCopyWith<$Res> {
  __$$NotificationPreferenceImplCopyWithImpl(
      _$NotificationPreferenceImpl _value,
      $Res Function(_$NotificationPreferenceImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? orderUpdates = null,
    Object? promotions = null,
    Object? pushEnabled = null,
    Object? updatedAt = null,
  }) {
    return _then(_$NotificationPreferenceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      orderUpdates: null == orderUpdates
          ? _value.orderUpdates
          : orderUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      promotions: null == promotions
          ? _value.promotions
          : promotions // ignore: cast_nullable_to_non_nullable
              as bool,
      pushEnabled: null == pushEnabled
          ? _value.pushEnabled
          : pushEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$NotificationPreferenceImpl implements _NotificationPreference {
  const _$NotificationPreferenceImpl(
      {required this.id,
      required this.userId,
      this.orderUpdates = true,
      this.promotions = true,
      this.pushEnabled = true,
      required this.updatedAt});

  @override
  final String id;
  @override
  final String userId;
  @override
  @JsonKey()
  final bool orderUpdates;
  @override
  @JsonKey()
  final bool promotions;
  @override
  @JsonKey()
  final bool pushEnabled;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'NotificationPreference(id: $id, userId: $userId, orderUpdates: $orderUpdates, promotions: $promotions, pushEnabled: $pushEnabled, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPreferenceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.orderUpdates, orderUpdates) ||
                other.orderUpdates == orderUpdates) &&
            (identical(other.promotions, promotions) ||
                other.promotions == promotions) &&
            (identical(other.pushEnabled, pushEnabled) ||
                other.pushEnabled == pushEnabled) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, userId, orderUpdates,
      promotions, pushEnabled, updatedAt);

  /// Create a copy of NotificationPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPreferenceImplCopyWith<_$NotificationPreferenceImpl>
      get copyWith => __$$NotificationPreferenceImplCopyWithImpl<
          _$NotificationPreferenceImpl>(this, _$identity);
}

abstract class _NotificationPreference implements NotificationPreference {
  const factory _NotificationPreference(
      {required final String id,
      required final String userId,
      final bool orderUpdates,
      final bool promotions,
      final bool pushEnabled,
      required final DateTime updatedAt}) = _$NotificationPreferenceImpl;

  @override
  String get id;
  @override
  String get userId;
  @override
  bool get orderUpdates;
  @override
  bool get promotions;
  @override
  bool get pushEnabled;
  @override
  DateTime get updatedAt;

  /// Create a copy of NotificationPreference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPreferenceImplCopyWith<_$NotificationPreferenceImpl>
      get copyWith => throw _privateConstructorUsedError;
}
