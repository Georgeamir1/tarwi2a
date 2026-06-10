// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Address {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get building => throw _privateConstructorUsedError;
  String? get floor => throw _privateConstructorUsedError;
  String? get apartment => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get deliveryZoneId => throw _privateConstructorUsedError;
  String? get deliveryZoneName => throw _privateConstructorUsedError;
  double? get deliveryFee => throw _privateConstructorUsedError;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressCopyWith<Address> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressCopyWith<$Res> {
  factory $AddressCopyWith(Address value, $Res Function(Address) then) =
      _$AddressCopyWithImpl<$Res, Address>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String label,
      String address,
      double? latitude,
      double? longitude,
      String? building,
      String? floor,
      String? apartment,
      String? notes,
      bool isDefault,
      DateTime createdAt,
      String? deliveryZoneId,
      String? deliveryZoneName,
      double? deliveryFee});
}

/// @nodoc
class _$AddressCopyWithImpl<$Res, $Val extends Address>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? label = null,
    Object? address = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? building = freezed,
    Object? floor = freezed,
    Object? apartment = freezed,
    Object? notes = freezed,
    Object? isDefault = null,
    Object? createdAt = null,
    Object? deliveryZoneId = freezed,
    Object? deliveryZoneName = freezed,
    Object? deliveryFee = freezed,
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
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      building: freezed == building
          ? _value.building
          : building // ignore: cast_nullable_to_non_nullable
              as String?,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as String?,
      apartment: freezed == apartment
          ? _value.apartment
          : apartment // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveryZoneId: freezed == deliveryZoneId
          ? _value.deliveryZoneId
          : deliveryZoneId // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryZoneName: freezed == deliveryZoneName
          ? _value.deliveryZoneName
          : deliveryZoneName // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryFee: freezed == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AddressImplCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$$AddressImplCopyWith(
          _$AddressImpl value, $Res Function(_$AddressImpl) then) =
      __$$AddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String label,
      String address,
      double? latitude,
      double? longitude,
      String? building,
      String? floor,
      String? apartment,
      String? notes,
      bool isDefault,
      DateTime createdAt,
      String? deliveryZoneId,
      String? deliveryZoneName,
      double? deliveryFee});
}

/// @nodoc
class __$$AddressImplCopyWithImpl<$Res>
    extends _$AddressCopyWithImpl<$Res, _$AddressImpl>
    implements _$$AddressImplCopyWith<$Res> {
  __$$AddressImplCopyWithImpl(
      _$AddressImpl _value, $Res Function(_$AddressImpl) _then)
      : super(_value, _then);

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? label = null,
    Object? address = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? building = freezed,
    Object? floor = freezed,
    Object? apartment = freezed,
    Object? notes = freezed,
    Object? isDefault = null,
    Object? createdAt = null,
    Object? deliveryZoneId = freezed,
    Object? deliveryZoneName = freezed,
    Object? deliveryFee = freezed,
  }) {
    return _then(_$AddressImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      building: freezed == building
          ? _value.building
          : building // ignore: cast_nullable_to_non_nullable
              as String?,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as String?,
      apartment: freezed == apartment
          ? _value.apartment
          : apartment // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveryZoneId: freezed == deliveryZoneId
          ? _value.deliveryZoneId
          : deliveryZoneId // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryZoneName: freezed == deliveryZoneName
          ? _value.deliveryZoneName
          : deliveryZoneName // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryFee: freezed == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$AddressImpl implements _Address {
  const _$AddressImpl(
      {required this.id,
      required this.userId,
      required this.label,
      required this.address,
      this.latitude,
      this.longitude,
      this.building,
      this.floor,
      this.apartment,
      this.notes,
      this.isDefault = false,
      required this.createdAt,
      this.deliveryZoneId,
      this.deliveryZoneName,
      this.deliveryFee});

  @override
  final String id;
  @override
  final String userId;
  @override
  final String label;
  @override
  final String address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? building;
  @override
  final String? floor;
  @override
  final String? apartment;
  @override
  final String? notes;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  final DateTime createdAt;
  @override
  final String? deliveryZoneId;
  @override
  final String? deliveryZoneName;
  @override
  final double? deliveryFee;

  @override
  String toString() {
    return 'Address(id: $id, userId: $userId, label: $label, address: $address, latitude: $latitude, longitude: $longitude, building: $building, floor: $floor, apartment: $apartment, notes: $notes, isDefault: $isDefault, createdAt: $createdAt, deliveryZoneId: $deliveryZoneId, deliveryZoneName: $deliveryZoneName, deliveryFee: $deliveryFee)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.building, building) ||
                other.building == building) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.apartment, apartment) ||
                other.apartment == apartment) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.deliveryZoneId, deliveryZoneId) ||
                other.deliveryZoneId == deliveryZoneId) &&
            (identical(other.deliveryZoneName, deliveryZoneName) ||
                other.deliveryZoneName == deliveryZoneName) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      label,
      address,
      latitude,
      longitude,
      building,
      floor,
      apartment,
      notes,
      isDefault,
      createdAt,
      deliveryZoneId,
      deliveryZoneName,
      deliveryFee);

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      __$$AddressImplCopyWithImpl<_$AddressImpl>(this, _$identity);
}

abstract class _Address implements Address {
  const factory _Address(
      {required final String id,
      required final String userId,
      required final String label,
      required final String address,
      final double? latitude,
      final double? longitude,
      final String? building,
      final String? floor,
      final String? apartment,
      final String? notes,
      final bool isDefault,
      required final DateTime createdAt,
      final String? deliveryZoneId,
      final String? deliveryZoneName,
      final double? deliveryFee}) = _$AddressImpl;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get label;
  @override
  String get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get building;
  @override
  String? get floor;
  @override
  String? get apartment;
  @override
  String? get notes;
  @override
  bool get isDefault;
  @override
  DateTime get createdAt;
  @override
  String? get deliveryZoneId;
  @override
  String? get deliveryZoneName;
  @override
  double? get deliveryFee;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
