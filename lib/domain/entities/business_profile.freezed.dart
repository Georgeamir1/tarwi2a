// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BusinessProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  Map<String, OpeningPeriod> get openingHours =>
      throw _privateConstructorUsedError;
  double get minOrder => throw _privateConstructorUsedError;
  int get defaultPrepTime => throw _privateConstructorUsedError;
  bool get isBusy => throw _privateConstructorUsedError;
  String? get busyMessage => throw _privateConstructorUsedError;
  bool get acceptOrders => throw _privateConstructorUsedError;
  String? get whatsappNumber => throw _privateConstructorUsedError;
  String? get vodafoneCashNumber => throw _privateConstructorUsedError;
  String? get instapayHandle => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of BusinessProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusinessProfileCopyWith<BusinessProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusinessProfileCopyWith<$Res> {
  factory $BusinessProfileCopyWith(
          BusinessProfile value, $Res Function(BusinessProfile) then) =
      _$BusinessProfileCopyWithImpl<$Res, BusinessProfile>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? phone,
      String? address,
      String? logoUrl,
      Map<String, OpeningPeriod> openingHours,
      double minOrder,
      int defaultPrepTime,
      bool isBusy,
      String? busyMessage,
      bool acceptOrders,
      String? whatsappNumber,
      String? vodafoneCashNumber,
      String? instapayHandle,
      DateTime updatedAt});
}

/// @nodoc
class _$BusinessProfileCopyWithImpl<$Res, $Val extends BusinessProfile>
    implements $BusinessProfileCopyWith<$Res> {
  _$BusinessProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusinessProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = freezed,
    Object? address = freezed,
    Object? logoUrl = freezed,
    Object? openingHours = null,
    Object? minOrder = null,
    Object? defaultPrepTime = null,
    Object? isBusy = null,
    Object? busyMessage = freezed,
    Object? acceptOrders = null,
    Object? whatsappNumber = freezed,
    Object? vodafoneCashNumber = freezed,
    Object? instapayHandle = freezed,
    Object? updatedAt = null,
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
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      openingHours: null == openingHours
          ? _value.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as Map<String, OpeningPeriod>,
      minOrder: null == minOrder
          ? _value.minOrder
          : minOrder // ignore: cast_nullable_to_non_nullable
              as double,
      defaultPrepTime: null == defaultPrepTime
          ? _value.defaultPrepTime
          : defaultPrepTime // ignore: cast_nullable_to_non_nullable
              as int,
      isBusy: null == isBusy
          ? _value.isBusy
          : isBusy // ignore: cast_nullable_to_non_nullable
              as bool,
      busyMessage: freezed == busyMessage
          ? _value.busyMessage
          : busyMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      acceptOrders: null == acceptOrders
          ? _value.acceptOrders
          : acceptOrders // ignore: cast_nullable_to_non_nullable
              as bool,
      whatsappNumber: freezed == whatsappNumber
          ? _value.whatsappNumber
          : whatsappNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      vodafoneCashNumber: freezed == vodafoneCashNumber
          ? _value.vodafoneCashNumber
          : vodafoneCashNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      instapayHandle: freezed == instapayHandle
          ? _value.instapayHandle
          : instapayHandle // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusinessProfileImplCopyWith<$Res>
    implements $BusinessProfileCopyWith<$Res> {
  factory _$$BusinessProfileImplCopyWith(_$BusinessProfileImpl value,
          $Res Function(_$BusinessProfileImpl) then) =
      __$$BusinessProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? phone,
      String? address,
      String? logoUrl,
      Map<String, OpeningPeriod> openingHours,
      double minOrder,
      int defaultPrepTime,
      bool isBusy,
      String? busyMessage,
      bool acceptOrders,
      String? whatsappNumber,
      String? vodafoneCashNumber,
      String? instapayHandle,
      DateTime updatedAt});
}

/// @nodoc
class __$$BusinessProfileImplCopyWithImpl<$Res>
    extends _$BusinessProfileCopyWithImpl<$Res, _$BusinessProfileImpl>
    implements _$$BusinessProfileImplCopyWith<$Res> {
  __$$BusinessProfileImplCopyWithImpl(
      _$BusinessProfileImpl _value, $Res Function(_$BusinessProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusinessProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = freezed,
    Object? address = freezed,
    Object? logoUrl = freezed,
    Object? openingHours = null,
    Object? minOrder = null,
    Object? defaultPrepTime = null,
    Object? isBusy = null,
    Object? busyMessage = freezed,
    Object? acceptOrders = null,
    Object? whatsappNumber = freezed,
    Object? vodafoneCashNumber = freezed,
    Object? instapayHandle = freezed,
    Object? updatedAt = null,
  }) {
    return _then(_$BusinessProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      openingHours: null == openingHours
          ? _value._openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as Map<String, OpeningPeriod>,
      minOrder: null == minOrder
          ? _value.minOrder
          : minOrder // ignore: cast_nullable_to_non_nullable
              as double,
      defaultPrepTime: null == defaultPrepTime
          ? _value.defaultPrepTime
          : defaultPrepTime // ignore: cast_nullable_to_non_nullable
              as int,
      isBusy: null == isBusy
          ? _value.isBusy
          : isBusy // ignore: cast_nullable_to_non_nullable
              as bool,
      busyMessage: freezed == busyMessage
          ? _value.busyMessage
          : busyMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      acceptOrders: null == acceptOrders
          ? _value.acceptOrders
          : acceptOrders // ignore: cast_nullable_to_non_nullable
              as bool,
      whatsappNumber: freezed == whatsappNumber
          ? _value.whatsappNumber
          : whatsappNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      vodafoneCashNumber: freezed == vodafoneCashNumber
          ? _value.vodafoneCashNumber
          : vodafoneCashNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      instapayHandle: freezed == instapayHandle
          ? _value.instapayHandle
          : instapayHandle // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$BusinessProfileImpl implements _BusinessProfile {
  const _$BusinessProfileImpl(
      {required this.id,
      required this.name,
      this.phone,
      this.address,
      this.logoUrl,
      required final Map<String, OpeningPeriod> openingHours,
      this.minOrder = 0.0,
      this.defaultPrepTime = 30,
      this.isBusy = false,
      this.busyMessage,
      this.acceptOrders = true,
      this.whatsappNumber,
      this.vodafoneCashNumber,
      this.instapayHandle,
      required this.updatedAt})
      : _openingHours = openingHours;

  @override
  final String id;
  @override
  final String name;
  @override
  final String? phone;
  @override
  final String? address;
  @override
  final String? logoUrl;
  final Map<String, OpeningPeriod> _openingHours;
  @override
  Map<String, OpeningPeriod> get openingHours {
    if (_openingHours is EqualUnmodifiableMapView) return _openingHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_openingHours);
  }

  @override
  @JsonKey()
  final double minOrder;
  @override
  @JsonKey()
  final int defaultPrepTime;
  @override
  @JsonKey()
  final bool isBusy;
  @override
  final String? busyMessage;
  @override
  @JsonKey()
  final bool acceptOrders;
  @override
  final String? whatsappNumber;
  @override
  final String? vodafoneCashNumber;
  @override
  final String? instapayHandle;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'BusinessProfile(id: $id, name: $name, phone: $phone, address: $address, logoUrl: $logoUrl, openingHours: $openingHours, minOrder: $minOrder, defaultPrepTime: $defaultPrepTime, isBusy: $isBusy, busyMessage: $busyMessage, acceptOrders: $acceptOrders, whatsappNumber: $whatsappNumber, vodafoneCashNumber: $vodafoneCashNumber, instapayHandle: $instapayHandle, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            const DeepCollectionEquality()
                .equals(other._openingHours, _openingHours) &&
            (identical(other.minOrder, minOrder) ||
                other.minOrder == minOrder) &&
            (identical(other.defaultPrepTime, defaultPrepTime) ||
                other.defaultPrepTime == defaultPrepTime) &&
            (identical(other.isBusy, isBusy) || other.isBusy == isBusy) &&
            (identical(other.busyMessage, busyMessage) ||
                other.busyMessage == busyMessage) &&
            (identical(other.acceptOrders, acceptOrders) ||
                other.acceptOrders == acceptOrders) &&
            (identical(other.whatsappNumber, whatsappNumber) ||
                other.whatsappNumber == whatsappNumber) &&
            (identical(other.vodafoneCashNumber, vodafoneCashNumber) ||
                other.vodafoneCashNumber == vodafoneCashNumber) &&
            (identical(other.instapayHandle, instapayHandle) ||
                other.instapayHandle == instapayHandle) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      phone,
      address,
      logoUrl,
      const DeepCollectionEquality().hash(_openingHours),
      minOrder,
      defaultPrepTime,
      isBusy,
      busyMessage,
      acceptOrders,
      whatsappNumber,
      vodafoneCashNumber,
      instapayHandle,
      updatedAt);

  /// Create a copy of BusinessProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessProfileImplCopyWith<_$BusinessProfileImpl> get copyWith =>
      __$$BusinessProfileImplCopyWithImpl<_$BusinessProfileImpl>(
          this, _$identity);
}

abstract class _BusinessProfile implements BusinessProfile {
  const factory _BusinessProfile(
      {required final String id,
      required final String name,
      final String? phone,
      final String? address,
      final String? logoUrl,
      required final Map<String, OpeningPeriod> openingHours,
      final double minOrder,
      final int defaultPrepTime,
      final bool isBusy,
      final String? busyMessage,
      final bool acceptOrders,
      final String? whatsappNumber,
      final String? vodafoneCashNumber,
      final String? instapayHandle,
      required final DateTime updatedAt}) = _$BusinessProfileImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get phone;
  @override
  String? get address;
  @override
  String? get logoUrl;
  @override
  Map<String, OpeningPeriod> get openingHours;
  @override
  double get minOrder;
  @override
  int get defaultPrepTime;
  @override
  bool get isBusy;
  @override
  String? get busyMessage;
  @override
  bool get acceptOrders;
  @override
  String? get whatsappNumber;
  @override
  String? get vodafoneCashNumber;
  @override
  String? get instapayHandle;
  @override
  DateTime get updatedAt;

  /// Create a copy of BusinessProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessProfileImplCopyWith<_$BusinessProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OpeningPeriod {
  String get open => throw _privateConstructorUsedError;
  String get close => throw _privateConstructorUsedError;

  /// Create a copy of OpeningPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OpeningPeriodCopyWith<OpeningPeriod> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpeningPeriodCopyWith<$Res> {
  factory $OpeningPeriodCopyWith(
          OpeningPeriod value, $Res Function(OpeningPeriod) then) =
      _$OpeningPeriodCopyWithImpl<$Res, OpeningPeriod>;
  @useResult
  $Res call({String open, String close});
}

/// @nodoc
class _$OpeningPeriodCopyWithImpl<$Res, $Val extends OpeningPeriod>
    implements $OpeningPeriodCopyWith<$Res> {
  _$OpeningPeriodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OpeningPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? open = null,
    Object? close = null,
  }) {
    return _then(_value.copyWith(
      open: null == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as String,
      close: null == close
          ? _value.close
          : close // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OpeningPeriodImplCopyWith<$Res>
    implements $OpeningPeriodCopyWith<$Res> {
  factory _$$OpeningPeriodImplCopyWith(
          _$OpeningPeriodImpl value, $Res Function(_$OpeningPeriodImpl) then) =
      __$$OpeningPeriodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String open, String close});
}

/// @nodoc
class __$$OpeningPeriodImplCopyWithImpl<$Res>
    extends _$OpeningPeriodCopyWithImpl<$Res, _$OpeningPeriodImpl>
    implements _$$OpeningPeriodImplCopyWith<$Res> {
  __$$OpeningPeriodImplCopyWithImpl(
      _$OpeningPeriodImpl _value, $Res Function(_$OpeningPeriodImpl) _then)
      : super(_value, _then);

  /// Create a copy of OpeningPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? open = null,
    Object? close = null,
  }) {
    return _then(_$OpeningPeriodImpl(
      open: null == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as String,
      close: null == close
          ? _value.close
          : close // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$OpeningPeriodImpl implements _OpeningPeriod {
  const _$OpeningPeriodImpl({required this.open, required this.close});

  @override
  final String open;
  @override
  final String close;

  @override
  String toString() {
    return 'OpeningPeriod(open: $open, close: $close)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpeningPeriodImpl &&
            (identical(other.open, open) || other.open == open) &&
            (identical(other.close, close) || other.close == close));
  }

  @override
  int get hashCode => Object.hash(runtimeType, open, close);

  /// Create a copy of OpeningPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OpeningPeriodImplCopyWith<_$OpeningPeriodImpl> get copyWith =>
      __$$OpeningPeriodImplCopyWithImpl<_$OpeningPeriodImpl>(this, _$identity);
}

abstract class _OpeningPeriod implements OpeningPeriod {
  const factory _OpeningPeriod(
      {required final String open,
      required final String close}) = _$OpeningPeriodImpl;

  @override
  String get open;
  @override
  String get close;

  /// Create a copy of OpeningPeriod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OpeningPeriodImplCopyWith<_$OpeningPeriodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
