// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CartItem {
  String get productId => throw _privateConstructorUsedError;
  String get productNameAr => throw _privateConstructorUsedError;
  double get productPrice => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  List<SelectedOption> get selectedOptions =>
      throw _privateConstructorUsedError;
  String? get productImageUrl => throw _privateConstructorUsedError;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartItemCopyWith<CartItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemCopyWith<$Res> {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) then) =
      _$CartItemCopyWithImpl<$Res, CartItem>;
  @useResult
  $Res call(
      {String productId,
      String productNameAr,
      double productPrice,
      int quantity,
      List<SelectedOption> selectedOptions,
      String? productImageUrl});
}

/// @nodoc
class _$CartItemCopyWithImpl<$Res, $Val extends CartItem>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productNameAr = null,
    Object? productPrice = null,
    Object? quantity = null,
    Object? selectedOptions = null,
    Object? productImageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productNameAr: null == productNameAr
          ? _value.productNameAr
          : productNameAr // ignore: cast_nullable_to_non_nullable
              as String,
      productPrice: null == productPrice
          ? _value.productPrice
          : productPrice // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      selectedOptions: null == selectedOptions
          ? _value.selectedOptions
          : selectedOptions // ignore: cast_nullable_to_non_nullable
              as List<SelectedOption>,
      productImageUrl: freezed == productImageUrl
          ? _value.productImageUrl
          : productImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CartItemImplCopyWith<$Res>
    implements $CartItemCopyWith<$Res> {
  factory _$$CartItemImplCopyWith(
          _$CartItemImpl value, $Res Function(_$CartItemImpl) then) =
      __$$CartItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String productId,
      String productNameAr,
      double productPrice,
      int quantity,
      List<SelectedOption> selectedOptions,
      String? productImageUrl});
}

/// @nodoc
class __$$CartItemImplCopyWithImpl<$Res>
    extends _$CartItemCopyWithImpl<$Res, _$CartItemImpl>
    implements _$$CartItemImplCopyWith<$Res> {
  __$$CartItemImplCopyWithImpl(
      _$CartItemImpl _value, $Res Function(_$CartItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productNameAr = null,
    Object? productPrice = null,
    Object? quantity = null,
    Object? selectedOptions = null,
    Object? productImageUrl = freezed,
  }) {
    return _then(_$CartItemImpl(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productNameAr: null == productNameAr
          ? _value.productNameAr
          : productNameAr // ignore: cast_nullable_to_non_nullable
              as String,
      productPrice: null == productPrice
          ? _value.productPrice
          : productPrice // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      selectedOptions: null == selectedOptions
          ? _value._selectedOptions
          : selectedOptions // ignore: cast_nullable_to_non_nullable
              as List<SelectedOption>,
      productImageUrl: freezed == productImageUrl
          ? _value.productImageUrl
          : productImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CartItemImpl extends _CartItem {
  const _$CartItemImpl(
      {required this.productId,
      required this.productNameAr,
      required this.productPrice,
      required this.quantity,
      final List<SelectedOption> selectedOptions = const [],
      this.productImageUrl})
      : _selectedOptions = selectedOptions,
        super._();

  @override
  final String productId;
  @override
  final String productNameAr;
  @override
  final double productPrice;
  @override
  final int quantity;
  final List<SelectedOption> _selectedOptions;
  @override
  @JsonKey()
  List<SelectedOption> get selectedOptions {
    if (_selectedOptions is EqualUnmodifiableListView) return _selectedOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedOptions);
  }

  @override
  final String? productImageUrl;

  @override
  String toString() {
    return 'CartItem(productId: $productId, productNameAr: $productNameAr, productPrice: $productPrice, quantity: $quantity, selectedOptions: $selectedOptions, productImageUrl: $productImageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productNameAr, productNameAr) ||
                other.productNameAr == productNameAr) &&
            (identical(other.productPrice, productPrice) ||
                other.productPrice == productPrice) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            const DeepCollectionEquality()
                .equals(other._selectedOptions, _selectedOptions) &&
            (identical(other.productImageUrl, productImageUrl) ||
                other.productImageUrl == productImageUrl));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      productId,
      productNameAr,
      productPrice,
      quantity,
      const DeepCollectionEquality().hash(_selectedOptions),
      productImageUrl);

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      __$$CartItemImplCopyWithImpl<_$CartItemImpl>(this, _$identity);
}

abstract class _CartItem extends CartItem {
  const factory _CartItem(
      {required final String productId,
      required final String productNameAr,
      required final double productPrice,
      required final int quantity,
      final List<SelectedOption> selectedOptions,
      final String? productImageUrl}) = _$CartItemImpl;
  const _CartItem._() : super._();

  @override
  String get productId;
  @override
  String get productNameAr;
  @override
  double get productPrice;
  @override
  int get quantity;
  @override
  List<SelectedOption> get selectedOptions;
  @override
  String? get productImageUrl;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
