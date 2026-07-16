// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_rating.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OrderRating {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of OrderRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderRatingCopyWith<OrderRating> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderRatingCopyWith<$Res> {
  factory $OrderRatingCopyWith(
          OrderRating value, $Res Function(OrderRating) then) =
      _$OrderRatingCopyWithImpl<$Res, OrderRating>;
  @useResult
  $Res call(
      {String id,
      String orderId,
      String? customerId,
      String customerName,
      int rating,
      String? comment,
      DateTime createdAt});
}

/// @nodoc
class _$OrderRatingCopyWithImpl<$Res, $Val extends OrderRating>
    implements $OrderRatingCopyWith<$Res> {
  _$OrderRatingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? customerId = freezed,
    Object? customerName = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderRatingImplCopyWith<$Res>
    implements $OrderRatingCopyWith<$Res> {
  factory _$$OrderRatingImplCopyWith(
          _$OrderRatingImpl value, $Res Function(_$OrderRatingImpl) then) =
      __$$OrderRatingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String orderId,
      String? customerId,
      String customerName,
      int rating,
      String? comment,
      DateTime createdAt});
}

/// @nodoc
class __$$OrderRatingImplCopyWithImpl<$Res>
    extends _$OrderRatingCopyWithImpl<$Res, _$OrderRatingImpl>
    implements _$$OrderRatingImplCopyWith<$Res> {
  __$$OrderRatingImplCopyWithImpl(
      _$OrderRatingImpl _value, $Res Function(_$OrderRatingImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? customerId = freezed,
    Object? customerName = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$OrderRatingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$OrderRatingImpl implements _OrderRating {
  const _$OrderRatingImpl(
      {required this.id,
      required this.orderId,
      this.customerId,
      required this.customerName,
      required this.rating,
      this.comment,
      required this.createdAt});

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String? customerId;
  @override
  final String customerName;
  @override
  final int rating;
  @override
  final String? comment;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'OrderRating(id: $id, orderId: $orderId, customerId: $customerId, customerName: $customerName, rating: $rating, comment: $comment, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderRatingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, orderId, customerId,
      customerName, rating, comment, createdAt);

  /// Create a copy of OrderRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderRatingImplCopyWith<_$OrderRatingImpl> get copyWith =>
      __$$OrderRatingImplCopyWithImpl<_$OrderRatingImpl>(this, _$identity);
}

abstract class _OrderRating implements OrderRating {
  const factory _OrderRating(
      {required final String id,
      required final String orderId,
      final String? customerId,
      required final String customerName,
      required final int rating,
      final String? comment,
      required final DateTime createdAt}) = _$OrderRatingImpl;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String? get customerId;
  @override
  String get customerName;
  @override
  int get rating;
  @override
  String? get comment;
  @override
  DateTime get createdAt;

  /// Create a copy of OrderRating
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderRatingImplCopyWith<_$OrderRatingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
