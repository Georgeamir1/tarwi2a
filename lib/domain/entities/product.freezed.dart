// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Product {
  String get id => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get nameAr => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get descriptionAr => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  int? get preparationTime => throw _privateConstructorUsedError;
  int? get calories => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  Map<String, dynamic>? get businessHours => throw _privateConstructorUsedError;
  List<ProductOption> get options => throw _privateConstructorUsedError;
  bool get showInBanner => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call(
      {String id,
      String? categoryId,
      String name,
      String nameAr,
      String? description,
      String? descriptionAr,
      double price,
      String? imageUrl,
      bool isAvailable,
      int sortOrder,
      int? preparationTime,
      int? calories,
      List<String> tags,
      Map<String, dynamic>? businessHours,
      List<ProductOption> options,
      bool showInBanner});
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = freezed,
    Object? name = null,
    Object? nameAr = null,
    Object? description = freezed,
    Object? descriptionAr = freezed,
    Object? price = null,
    Object? imageUrl = freezed,
    Object? isAvailable = null,
    Object? sortOrder = null,
    Object? preparationTime = freezed,
    Object? calories = freezed,
    Object? tags = null,
    Object? businessHours = freezed,
    Object? options = null,
    Object? showInBanner = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: null == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionAr: freezed == descriptionAr
          ? _value.descriptionAr
          : descriptionAr // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      preparationTime: freezed == preparationTime
          ? _value.preparationTime
          : preparationTime // ignore: cast_nullable_to_non_nullable
              as int?,
      calories: freezed == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      businessHours: freezed == businessHours
          ? _value.businessHours
          : businessHours // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<ProductOption>,
      showInBanner: null == showInBanner
          ? _value.showInBanner
          : showInBanner // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
          _$ProductImpl value, $Res Function(_$ProductImpl) then) =
      __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? categoryId,
      String name,
      String nameAr,
      String? description,
      String? descriptionAr,
      double price,
      String? imageUrl,
      bool isAvailable,
      int sortOrder,
      int? preparationTime,
      int? calories,
      List<String> tags,
      Map<String, dynamic>? businessHours,
      List<ProductOption> options,
      bool showInBanner});
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
      _$ProductImpl _value, $Res Function(_$ProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = freezed,
    Object? name = null,
    Object? nameAr = null,
    Object? description = freezed,
    Object? descriptionAr = freezed,
    Object? price = null,
    Object? imageUrl = freezed,
    Object? isAvailable = null,
    Object? sortOrder = null,
    Object? preparationTime = freezed,
    Object? calories = freezed,
    Object? tags = null,
    Object? businessHours = freezed,
    Object? options = null,
    Object? showInBanner = null,
  }) {
    return _then(_$ProductImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: null == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionAr: freezed == descriptionAr
          ? _value.descriptionAr
          : descriptionAr // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      preparationTime: freezed == preparationTime
          ? _value.preparationTime
          : preparationTime // ignore: cast_nullable_to_non_nullable
              as int?,
      calories: freezed == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      businessHours: freezed == businessHours
          ? _value._businessHours
          : businessHours // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<ProductOption>,
      showInBanner: null == showInBanner
          ? _value.showInBanner
          : showInBanner // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ProductImpl implements _Product {
  const _$ProductImpl(
      {required this.id,
      this.categoryId,
      required this.name,
      required this.nameAr,
      this.description,
      this.descriptionAr,
      required this.price,
      this.imageUrl,
      required this.isAvailable,
      required this.sortOrder,
      this.preparationTime,
      this.calories,
      final List<String> tags = const [],
      final Map<String, dynamic>? businessHours,
      final List<ProductOption> options = const [],
      this.showInBanner = false})
      : _tags = tags,
        _businessHours = businessHours,
        _options = options;

  @override
  final String id;
  @override
  final String? categoryId;
  @override
  final String name;
  @override
  final String nameAr;
  @override
  final String? description;
  @override
  final String? descriptionAr;
  @override
  final double price;
  @override
  final String? imageUrl;
  @override
  final bool isAvailable;
  @override
  final int sortOrder;
  @override
  final int? preparationTime;
  @override
  final int? calories;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final Map<String, dynamic>? _businessHours;
  @override
  Map<String, dynamic>? get businessHours {
    final value = _businessHours;
    if (value == null) return null;
    if (_businessHours is EqualUnmodifiableMapView) return _businessHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<ProductOption> _options;
  @override
  @JsonKey()
  List<ProductOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  @JsonKey()
  final bool showInBanner;

  @override
  String toString() {
    return 'Product(id: $id, categoryId: $categoryId, name: $name, nameAr: $nameAr, description: $description, descriptionAr: $descriptionAr, price: $price, imageUrl: $imageUrl, isAvailable: $isAvailable, sortOrder: $sortOrder, preparationTime: $preparationTime, calories: $calories, tags: $tags, businessHours: $businessHours, options: $options, showInBanner: $showInBanner)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.descriptionAr, descriptionAr) ||
                other.descriptionAr == descriptionAr) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.preparationTime, preparationTime) ||
                other.preparationTime == preparationTime) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._businessHours, _businessHours) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.showInBanner, showInBanner) ||
                other.showInBanner == showInBanner));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      categoryId,
      name,
      nameAr,
      description,
      descriptionAr,
      price,
      imageUrl,
      isAvailable,
      sortOrder,
      preparationTime,
      calories,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_businessHours),
      const DeepCollectionEquality().hash(_options),
      showInBanner);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);
}

abstract class _Product implements Product {
  const factory _Product(
      {required final String id,
      final String? categoryId,
      required final String name,
      required final String nameAr,
      final String? description,
      final String? descriptionAr,
      required final double price,
      final String? imageUrl,
      required final bool isAvailable,
      required final int sortOrder,
      final int? preparationTime,
      final int? calories,
      final List<String> tags,
      final Map<String, dynamic>? businessHours,
      final List<ProductOption> options,
      final bool showInBanner}) = _$ProductImpl;

  @override
  String get id;
  @override
  String? get categoryId;
  @override
  String get name;
  @override
  String get nameAr;
  @override
  String? get description;
  @override
  String? get descriptionAr;
  @override
  double get price;
  @override
  String? get imageUrl;
  @override
  bool get isAvailable;
  @override
  int get sortOrder;
  @override
  int? get preparationTime;
  @override
  int? get calories;
  @override
  List<String> get tags;
  @override
  Map<String, dynamic>? get businessHours;
  @override
  List<ProductOption> get options;
  @override
  bool get showInBanner;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
