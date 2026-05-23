// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selected_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SelectedOption {
  String get optionId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get priceAdjustment => throw _privateConstructorUsedError;

  /// Create a copy of SelectedOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SelectedOptionCopyWith<SelectedOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectedOptionCopyWith<$Res> {
  factory $SelectedOptionCopyWith(
          SelectedOption value, $Res Function(SelectedOption) then) =
      _$SelectedOptionCopyWithImpl<$Res, SelectedOption>;
  @useResult
  $Res call({String optionId, String name, double priceAdjustment});
}

/// @nodoc
class _$SelectedOptionCopyWithImpl<$Res, $Val extends SelectedOption>
    implements $SelectedOptionCopyWith<$Res> {
  _$SelectedOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SelectedOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? optionId = null,
    Object? name = null,
    Object? priceAdjustment = null,
  }) {
    return _then(_value.copyWith(
      optionId: null == optionId
          ? _value.optionId
          : optionId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      priceAdjustment: null == priceAdjustment
          ? _value.priceAdjustment
          : priceAdjustment // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SelectedOptionImplCopyWith<$Res>
    implements $SelectedOptionCopyWith<$Res> {
  factory _$$SelectedOptionImplCopyWith(_$SelectedOptionImpl value,
          $Res Function(_$SelectedOptionImpl) then) =
      __$$SelectedOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String optionId, String name, double priceAdjustment});
}

/// @nodoc
class __$$SelectedOptionImplCopyWithImpl<$Res>
    extends _$SelectedOptionCopyWithImpl<$Res, _$SelectedOptionImpl>
    implements _$$SelectedOptionImplCopyWith<$Res> {
  __$$SelectedOptionImplCopyWithImpl(
      _$SelectedOptionImpl _value, $Res Function(_$SelectedOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SelectedOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? optionId = null,
    Object? name = null,
    Object? priceAdjustment = null,
  }) {
    return _then(_$SelectedOptionImpl(
      optionId: null == optionId
          ? _value.optionId
          : optionId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      priceAdjustment: null == priceAdjustment
          ? _value.priceAdjustment
          : priceAdjustment // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$SelectedOptionImpl implements _SelectedOption {
  const _$SelectedOptionImpl(
      {required this.optionId,
      required this.name,
      required this.priceAdjustment});

  @override
  final String optionId;
  @override
  final String name;
  @override
  final double priceAdjustment;

  @override
  String toString() {
    return 'SelectedOption(optionId: $optionId, name: $name, priceAdjustment: $priceAdjustment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectedOptionImpl &&
            (identical(other.optionId, optionId) ||
                other.optionId == optionId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.priceAdjustment, priceAdjustment) ||
                other.priceAdjustment == priceAdjustment));
  }

  @override
  int get hashCode => Object.hash(runtimeType, optionId, name, priceAdjustment);

  /// Create a copy of SelectedOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectedOptionImplCopyWith<_$SelectedOptionImpl> get copyWith =>
      __$$SelectedOptionImplCopyWithImpl<_$SelectedOptionImpl>(
          this, _$identity);
}

abstract class _SelectedOption implements SelectedOption {
  const factory _SelectedOption(
      {required final String optionId,
      required final String name,
      required final double priceAdjustment}) = _$SelectedOptionImpl;

  @override
  String get optionId;
  @override
  String get name;
  @override
  double get priceAdjustment;

  /// Create a copy of SelectedOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelectedOptionImplCopyWith<_$SelectedOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
