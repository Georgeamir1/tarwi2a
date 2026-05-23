// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_setting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BusinessSetting {
  String get id => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;
  Map<String, dynamic> get value => throw _privateConstructorUsedError;

  /// Create a copy of BusinessSetting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusinessSettingCopyWith<BusinessSetting> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusinessSettingCopyWith<$Res> {
  factory $BusinessSettingCopyWith(
          BusinessSetting value, $Res Function(BusinessSetting) then) =
      _$BusinessSettingCopyWithImpl<$Res, BusinessSetting>;
  @useResult
  $Res call({String id, String key, Map<String, dynamic> value});
}

/// @nodoc
class _$BusinessSettingCopyWithImpl<$Res, $Val extends BusinessSetting>
    implements $BusinessSettingCopyWith<$Res> {
  _$BusinessSettingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusinessSetting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? key = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusinessSettingImplCopyWith<$Res>
    implements $BusinessSettingCopyWith<$Res> {
  factory _$$BusinessSettingImplCopyWith(_$BusinessSettingImpl value,
          $Res Function(_$BusinessSettingImpl) then) =
      __$$BusinessSettingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String key, Map<String, dynamic> value});
}

/// @nodoc
class __$$BusinessSettingImplCopyWithImpl<$Res>
    extends _$BusinessSettingCopyWithImpl<$Res, _$BusinessSettingImpl>
    implements _$$BusinessSettingImplCopyWith<$Res> {
  __$$BusinessSettingImplCopyWithImpl(
      _$BusinessSettingImpl _value, $Res Function(_$BusinessSettingImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusinessSetting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? key = null,
    Object? value = null,
  }) {
    return _then(_$BusinessSettingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value._value
          : value // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$BusinessSettingImpl implements _BusinessSetting {
  const _$BusinessSettingImpl(
      {required this.id,
      required this.key,
      required final Map<String, dynamic> value})
      : _value = value;

  @override
  final String id;
  @override
  final String key;
  final Map<String, dynamic> _value;
  @override
  Map<String, dynamic> get value {
    if (_value is EqualUnmodifiableMapView) return _value;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_value);
  }

  @override
  String toString() {
    return 'BusinessSetting(id: $id, key: $key, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessSettingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.key, key) || other.key == key) &&
            const DeepCollectionEquality().equals(other._value, _value));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, key, const DeepCollectionEquality().hash(_value));

  /// Create a copy of BusinessSetting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessSettingImplCopyWith<_$BusinessSettingImpl> get copyWith =>
      __$$BusinessSettingImplCopyWithImpl<_$BusinessSettingImpl>(
          this, _$identity);
}

abstract class _BusinessSetting implements BusinessSetting {
  const factory _BusinessSetting(
      {required final String id,
      required final String key,
      required final Map<String, dynamic> value}) = _$BusinessSettingImpl;

  @override
  String get id;
  @override
  String get key;
  @override
  Map<String, dynamic> get value;

  /// Create a copy of BusinessSetting
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessSettingImplCopyWith<_$BusinessSettingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
