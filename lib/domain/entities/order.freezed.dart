// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Order {
  String get id => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get customerPhone => throw _privateConstructorUsedError;
  String? get customerAddress => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  PaymentMethod get paymentMethod => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  List<OrderItem> get items => throw _privateConstructorUsedError;
  DateTime? get scheduledFor => throw _privateConstructorUsedError;
  String get orderType => throw _privateConstructorUsedError;
  String? get addressId => throw _privateConstructorUsedError;
  String get paymentStatus => throw _privateConstructorUsedError;
  String? get paymentProofUrl => throw _privateConstructorUsedError;
  String? get couponId => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  double get deliveryFee => throw _privateConstructorUsedError;
  String? get deliveryZoneId => throw _privateConstructorUsedError;
  String? get deliveryZoneName => throw _privateConstructorUsedError;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCopyWith<Order> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res, Order>;
  @useResult
  $Res call(
      {String id,
      String? customerId,
      String customerName,
      String customerPhone,
      String? customerAddress,
      String? notes,
      PaymentMethod paymentMethod,
      OrderStatus status,
      double totalAmount,
      DateTime createdAt,
      DateTime updatedAt,
      List<OrderItem> items,
      DateTime? scheduledFor,
      String orderType,
      String? addressId,
      String paymentStatus,
      String? paymentProofUrl,
      String? couponId,
      double discountAmount,
      double deliveryFee,
      String? deliveryZoneId,
      String? deliveryZoneName});
}

/// @nodoc
class _$OrderCopyWithImpl<$Res, $Val extends Order>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = freezed,
    Object? customerName = null,
    Object? customerPhone = null,
    Object? customerAddress = freezed,
    Object? notes = freezed,
    Object? paymentMethod = null,
    Object? status = null,
    Object? totalAmount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? items = null,
    Object? scheduledFor = freezed,
    Object? orderType = null,
    Object? addressId = freezed,
    Object? paymentStatus = null,
    Object? paymentProofUrl = freezed,
    Object? couponId = freezed,
    Object? discountAmount = null,
    Object? deliveryFee = null,
    Object? deliveryZoneId = freezed,
    Object? deliveryZoneName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: null == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      customerAddress: freezed == customerAddress
          ? _value.customerAddress
          : customerAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      scheduledFor: freezed == scheduledFor
          ? _value.scheduledFor
          : scheduledFor // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      orderType: null == orderType
          ? _value.orderType
          : orderType // ignore: cast_nullable_to_non_nullable
              as String,
      addressId: freezed == addressId
          ? _value.addressId
          : addressId // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      paymentProofUrl: freezed == paymentProofUrl
          ? _value.paymentProofUrl
          : paymentProofUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      couponId: freezed == couponId
          ? _value.couponId
          : couponId // ignore: cast_nullable_to_non_nullable
              as String?,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryFee: null == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryZoneId: freezed == deliveryZoneId
          ? _value.deliveryZoneId
          : deliveryZoneId // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryZoneName: freezed == deliveryZoneName
          ? _value.deliveryZoneName
          : deliveryZoneName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
          _$OrderImpl value, $Res Function(_$OrderImpl) then) =
      __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? customerId,
      String customerName,
      String customerPhone,
      String? customerAddress,
      String? notes,
      PaymentMethod paymentMethod,
      OrderStatus status,
      double totalAmount,
      DateTime createdAt,
      DateTime updatedAt,
      List<OrderItem> items,
      DateTime? scheduledFor,
      String orderType,
      String? addressId,
      String paymentStatus,
      String? paymentProofUrl,
      String? couponId,
      double discountAmount,
      double deliveryFee,
      String? deliveryZoneId,
      String? deliveryZoneName});
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
      _$OrderImpl _value, $Res Function(_$OrderImpl) _then)
      : super(_value, _then);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = freezed,
    Object? customerName = null,
    Object? customerPhone = null,
    Object? customerAddress = freezed,
    Object? notes = freezed,
    Object? paymentMethod = null,
    Object? status = null,
    Object? totalAmount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? items = null,
    Object? scheduledFor = freezed,
    Object? orderType = null,
    Object? addressId = freezed,
    Object? paymentStatus = null,
    Object? paymentProofUrl = freezed,
    Object? couponId = freezed,
    Object? discountAmount = null,
    Object? deliveryFee = null,
    Object? deliveryZoneId = freezed,
    Object? deliveryZoneName = freezed,
  }) {
    return _then(_$OrderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: null == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      customerAddress: freezed == customerAddress
          ? _value.customerAddress
          : customerAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      scheduledFor: freezed == scheduledFor
          ? _value.scheduledFor
          : scheduledFor // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      orderType: null == orderType
          ? _value.orderType
          : orderType // ignore: cast_nullable_to_non_nullable
              as String,
      addressId: freezed == addressId
          ? _value.addressId
          : addressId // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      paymentProofUrl: freezed == paymentProofUrl
          ? _value.paymentProofUrl
          : paymentProofUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      couponId: freezed == couponId
          ? _value.couponId
          : couponId // ignore: cast_nullable_to_non_nullable
              as String?,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryFee: null == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryZoneId: freezed == deliveryZoneId
          ? _value.deliveryZoneId
          : deliveryZoneId // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryZoneName: freezed == deliveryZoneName
          ? _value.deliveryZoneName
          : deliveryZoneName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$OrderImpl implements _Order {
  const _$OrderImpl(
      {required this.id,
      this.customerId,
      required this.customerName,
      required this.customerPhone,
      this.customerAddress,
      this.notes,
      required this.paymentMethod,
      required this.status,
      required this.totalAmount,
      required this.createdAt,
      required this.updatedAt,
      final List<OrderItem> items = const [],
      this.scheduledFor,
      this.orderType = 'delivery',
      this.addressId,
      this.paymentStatus = 'pending',
      this.paymentProofUrl,
      this.couponId,
      this.discountAmount = 0.0,
      this.deliveryFee = 0.0,
      this.deliveryZoneId,
      this.deliveryZoneName})
      : _items = items;

  @override
  final String id;
  @override
  final String? customerId;
  @override
  final String customerName;
  @override
  final String customerPhone;
  @override
  final String? customerAddress;
  @override
  final String? notes;
  @override
  final PaymentMethod paymentMethod;
  @override
  final OrderStatus status;
  @override
  final double totalAmount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final List<OrderItem> _items;
  @override
  @JsonKey()
  List<OrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final DateTime? scheduledFor;
  @override
  @JsonKey()
  final String orderType;
  @override
  final String? addressId;
  @override
  @JsonKey()
  final String paymentStatus;
  @override
  final String? paymentProofUrl;
  @override
  final String? couponId;
  @override
  @JsonKey()
  final double discountAmount;
  @override
  @JsonKey()
  final double deliveryFee;
  @override
  final String? deliveryZoneId;
  @override
  final String? deliveryZoneName;

  @override
  String toString() {
    return 'Order(id: $id, customerId: $customerId, customerName: $customerName, customerPhone: $customerPhone, customerAddress: $customerAddress, notes: $notes, paymentMethod: $paymentMethod, status: $status, totalAmount: $totalAmount, createdAt: $createdAt, updatedAt: $updatedAt, items: $items, scheduledFor: $scheduledFor, orderType: $orderType, addressId: $addressId, paymentStatus: $paymentStatus, paymentProofUrl: $paymentProofUrl, couponId: $couponId, discountAmount: $discountAmount, deliveryFee: $deliveryFee, deliveryZoneId: $deliveryZoneId, deliveryZoneName: $deliveryZoneName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.customerAddress, customerAddress) ||
                other.customerAddress == customerAddress) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.scheduledFor, scheduledFor) ||
                other.scheduledFor == scheduledFor) &&
            (identical(other.orderType, orderType) ||
                other.orderType == orderType) &&
            (identical(other.addressId, addressId) ||
                other.addressId == addressId) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentProofUrl, paymentProofUrl) ||
                other.paymentProofUrl == paymentProofUrl) &&
            (identical(other.couponId, couponId) ||
                other.couponId == couponId) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.deliveryZoneId, deliveryZoneId) ||
                other.deliveryZoneId == deliveryZoneId) &&
            (identical(other.deliveryZoneName, deliveryZoneName) ||
                other.deliveryZoneName == deliveryZoneName));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        customerId,
        customerName,
        customerPhone,
        customerAddress,
        notes,
        paymentMethod,
        status,
        totalAmount,
        createdAt,
        updatedAt,
        const DeepCollectionEquality().hash(_items),
        scheduledFor,
        orderType,
        addressId,
        paymentStatus,
        paymentProofUrl,
        couponId,
        discountAmount,
        deliveryFee,
        deliveryZoneId,
        deliveryZoneName
      ]);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);
}

abstract class _Order implements Order {
  const factory _Order(
      {required final String id,
      final String? customerId,
      required final String customerName,
      required final String customerPhone,
      final String? customerAddress,
      final String? notes,
      required final PaymentMethod paymentMethod,
      required final OrderStatus status,
      required final double totalAmount,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final List<OrderItem> items,
      final DateTime? scheduledFor,
      final String orderType,
      final String? addressId,
      final String paymentStatus,
      final String? paymentProofUrl,
      final String? couponId,
      final double discountAmount,
      final double deliveryFee,
      final String? deliveryZoneId,
      final String? deliveryZoneName}) = _$OrderImpl;

  @override
  String get id;
  @override
  String? get customerId;
  @override
  String get customerName;
  @override
  String get customerPhone;
  @override
  String? get customerAddress;
  @override
  String? get notes;
  @override
  PaymentMethod get paymentMethod;
  @override
  OrderStatus get status;
  @override
  double get totalAmount;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  List<OrderItem> get items;
  @override
  DateTime? get scheduledFor;
  @override
  String get orderType;
  @override
  String? get addressId;
  @override
  String get paymentStatus;
  @override
  String? get paymentProofUrl;
  @override
  String? get couponId;
  @override
  double get discountAmount;
  @override
  double get deliveryFee;
  @override
  String? get deliveryZoneId;
  @override
  String? get deliveryZoneName;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
