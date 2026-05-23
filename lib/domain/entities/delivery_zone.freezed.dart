// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_zone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DeliveryZone {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get fee => throw _privateConstructorUsedError;
  double get minOrderAmount => throw _privateConstructorUsedError;
  String? get estimatedTime => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get coordinates => throw _privateConstructorUsedError;

  /// Create a copy of DeliveryZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryZoneCopyWith<DeliveryZone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryZoneCopyWith<$Res> {
  factory $DeliveryZoneCopyWith(
          DeliveryZone value, $Res Function(DeliveryZone) then) =
      _$DeliveryZoneCopyWithImpl<$Res, DeliveryZone>;
  @useResult
  $Res call(
      {String id,
      String name,
      double fee,
      double minOrderAmount,
      String? estimatedTime,
      bool isActive,
      DateTime createdAt,
      Map<String, dynamic>? coordinates});
}

/// @nodoc
class _$DeliveryZoneCopyWithImpl<$Res, $Val extends DeliveryZone>
    implements $DeliveryZoneCopyWith<$Res> {
  _$DeliveryZoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeliveryZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? fee = null,
    Object? minOrderAmount = null,
    Object? estimatedTime = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? coordinates = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      fee: null == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as double,
      minOrderAmount: null == minOrderAmount
          ? _value.minOrderAmount
          : minOrderAmount // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedTime: freezed == estimatedTime
          ? _value.estimatedTime
          : estimatedTime // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      coordinates: freezed == coordinates
          ? _value.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeliveryZoneImplCopyWith<$Res>
    implements $DeliveryZoneCopyWith<$Res> {
  factory _$$DeliveryZoneImplCopyWith(
          _$DeliveryZoneImpl value, $Res Function(_$DeliveryZoneImpl) then) =
      __$$DeliveryZoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double fee,
      double minOrderAmount,
      String? estimatedTime,
      bool isActive,
      DateTime createdAt,
      Map<String, dynamic>? coordinates});
}

/// @nodoc
class __$$DeliveryZoneImplCopyWithImpl<$Res>
    extends _$DeliveryZoneCopyWithImpl<$Res, _$DeliveryZoneImpl>
    implements _$$DeliveryZoneImplCopyWith<$Res> {
  __$$DeliveryZoneImplCopyWithImpl(
      _$DeliveryZoneImpl _value, $Res Function(_$DeliveryZoneImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeliveryZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? fee = null,
    Object? minOrderAmount = null,
    Object? estimatedTime = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? coordinates = freezed,
  }) {
    return _then(_$DeliveryZoneImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      fee: null == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as double,
      minOrderAmount: null == minOrderAmount
          ? _value.minOrderAmount
          : minOrderAmount // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedTime: freezed == estimatedTime
          ? _value.estimatedTime
          : estimatedTime // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      coordinates: freezed == coordinates
          ? _value._coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$DeliveryZoneImpl implements _DeliveryZone {
  const _$DeliveryZoneImpl(
      {required this.id,
      required this.name,
      required this.fee,
      this.minOrderAmount = 0.0,
      this.estimatedTime,
      required this.isActive,
      required this.createdAt,
      final Map<String, dynamic>? coordinates})
      : _coordinates = coordinates;

  @override
  final String id;
  @override
  final String name;
  @override
  final double fee;
  @override
  @JsonKey()
  final double minOrderAmount;
  @override
  final String? estimatedTime;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  final Map<String, dynamic>? _coordinates;
  @override
  Map<String, dynamic>? get coordinates {
    final value = _coordinates;
    if (value == null) return null;
    if (_coordinates is EqualUnmodifiableMapView) return _coordinates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'DeliveryZone(id: $id, name: $name, fee: $fee, minOrderAmount: $minOrderAmount, estimatedTime: $estimatedTime, isActive: $isActive, createdAt: $createdAt, coordinates: $coordinates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryZoneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.fee, fee) || other.fee == fee) &&
            (identical(other.minOrderAmount, minOrderAmount) ||
                other.minOrderAmount == minOrderAmount) &&
            (identical(other.estimatedTime, estimatedTime) ||
                other.estimatedTime == estimatedTime) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._coordinates, _coordinates));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      fee,
      minOrderAmount,
      estimatedTime,
      isActive,
      createdAt,
      const DeepCollectionEquality().hash(_coordinates));

  /// Create a copy of DeliveryZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryZoneImplCopyWith<_$DeliveryZoneImpl> get copyWith =>
      __$$DeliveryZoneImplCopyWithImpl<_$DeliveryZoneImpl>(this, _$identity);
}

abstract class _DeliveryZone implements DeliveryZone {
  const factory _DeliveryZone(
      {required final String id,
      required final String name,
      required final double fee,
      final double minOrderAmount,
      final String? estimatedTime,
      required final bool isActive,
      required final DateTime createdAt,
      final Map<String, dynamic>? coordinates}) = _$DeliveryZoneImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  double get fee;
  @override
  double get minOrderAmount;
  @override
  String? get estimatedTime;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  Map<String, dynamic>? get coordinates;

  /// Create a copy of DeliveryZone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryZoneImplCopyWith<_$DeliveryZoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
