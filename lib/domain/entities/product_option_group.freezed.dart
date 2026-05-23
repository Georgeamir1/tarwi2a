// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_option_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProductOptionGroup {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  bool get isRequired => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;

  /// Create a copy of ProductOptionGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductOptionGroupCopyWith<ProductOptionGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductOptionGroupCopyWith<$Res> {
  factory $ProductOptionGroupCopyWith(
          ProductOptionGroup value, $Res Function(ProductOptionGroup) then) =
      _$ProductOptionGroupCopyWithImpl<$Res, ProductOptionGroup>;
  @useResult
  $Res call(
      {String id,
      String productId,
      String name,
      String type,
      bool isRequired,
      int sortOrder});
}

/// @nodoc
class _$ProductOptionGroupCopyWithImpl<$Res, $Val extends ProductOptionGroup>
    implements $ProductOptionGroupCopyWith<$Res> {
  _$ProductOptionGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductOptionGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? name = null,
    Object? type = null,
    Object? isRequired = null,
    Object? sortOrder = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isRequired: null == isRequired
          ? _value.isRequired
          : isRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductOptionGroupImplCopyWith<$Res>
    implements $ProductOptionGroupCopyWith<$Res> {
  factory _$$ProductOptionGroupImplCopyWith(_$ProductOptionGroupImpl value,
          $Res Function(_$ProductOptionGroupImpl) then) =
      __$$ProductOptionGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String productId,
      String name,
      String type,
      bool isRequired,
      int sortOrder});
}

/// @nodoc
class __$$ProductOptionGroupImplCopyWithImpl<$Res>
    extends _$ProductOptionGroupCopyWithImpl<$Res, _$ProductOptionGroupImpl>
    implements _$$ProductOptionGroupImplCopyWith<$Res> {
  __$$ProductOptionGroupImplCopyWithImpl(_$ProductOptionGroupImpl _value,
      $Res Function(_$ProductOptionGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductOptionGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? name = null,
    Object? type = null,
    Object? isRequired = null,
    Object? sortOrder = null,
  }) {
    return _then(_$ProductOptionGroupImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isRequired: null == isRequired
          ? _value.isRequired
          : isRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ProductOptionGroupImpl implements _ProductOptionGroup {
  const _$ProductOptionGroupImpl(
      {required this.id,
      required this.productId,
      required this.name,
      this.type = 'single',
      this.isRequired = false,
      this.sortOrder = 0});

  @override
  final String id;
  @override
  final String productId;
  @override
  final String name;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final bool isRequired;
  @override
  @JsonKey()
  final int sortOrder;

  @override
  String toString() {
    return 'ProductOptionGroup(id: $id, productId: $productId, name: $name, type: $type, isRequired: $isRequired, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductOptionGroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isRequired, isRequired) ||
                other.isRequired == isRequired) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, productId, name, type, isRequired, sortOrder);

  /// Create a copy of ProductOptionGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductOptionGroupImplCopyWith<_$ProductOptionGroupImpl> get copyWith =>
      __$$ProductOptionGroupImplCopyWithImpl<_$ProductOptionGroupImpl>(
          this, _$identity);
}

abstract class _ProductOptionGroup implements ProductOptionGroup {
  const factory _ProductOptionGroup(
      {required final String id,
      required final String productId,
      required final String name,
      final String type,
      final bool isRequired,
      final int sortOrder}) = _$ProductOptionGroupImpl;

  @override
  String get id;
  @override
  String get productId;
  @override
  String get name;
  @override
  String get type;
  @override
  bool get isRequired;
  @override
  int get sortOrder;

  /// Create a copy of ProductOptionGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductOptionGroupImplCopyWith<_$ProductOptionGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
