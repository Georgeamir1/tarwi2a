// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'broadcast_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BroadcastLog {
  String get id => throw _privateConstructorUsedError;
  String? get senderId => throw _privateConstructorUsedError;
  String get titleAr => throw _privateConstructorUsedError;
  String get bodyAr => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  BroadcastTargetType get targetType => throw _privateConstructorUsedError;
  List<String> get targetUserIds => throw _privateConstructorUsedError;
  String? get referenceType => throw _privateConstructorUsedError;
  String? get referenceId => throw _privateConstructorUsedError;
  int get recipientCount => throw _privateConstructorUsedError;
  int get sentCount => throw _privateConstructorUsedError;
  int get skippedCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of BroadcastLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BroadcastLogCopyWith<BroadcastLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BroadcastLogCopyWith<$Res> {
  factory $BroadcastLogCopyWith(
          BroadcastLog value, $Res Function(BroadcastLog) then) =
      _$BroadcastLogCopyWithImpl<$Res, BroadcastLog>;
  @useResult
  $Res call(
      {String id,
      String? senderId,
      String titleAr,
      String bodyAr,
      NotificationType type,
      BroadcastTargetType targetType,
      List<String> targetUserIds,
      String? referenceType,
      String? referenceId,
      int recipientCount,
      int sentCount,
      int skippedCount,
      DateTime createdAt});
}

/// @nodoc
class _$BroadcastLogCopyWithImpl<$Res, $Val extends BroadcastLog>
    implements $BroadcastLogCopyWith<$Res> {
  _$BroadcastLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BroadcastLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = freezed,
    Object? titleAr = null,
    Object? bodyAr = null,
    Object? type = null,
    Object? targetType = null,
    Object? targetUserIds = null,
    Object? referenceType = freezed,
    Object? referenceId = freezed,
    Object? recipientCount = null,
    Object? sentCount = null,
    Object? skippedCount = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: freezed == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String?,
      titleAr: null == titleAr
          ? _value.titleAr
          : titleAr // ignore: cast_nullable_to_non_nullable
              as String,
      bodyAr: null == bodyAr
          ? _value.bodyAr
          : bodyAr // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      targetType: null == targetType
          ? _value.targetType
          : targetType // ignore: cast_nullable_to_non_nullable
              as BroadcastTargetType,
      targetUserIds: null == targetUserIds
          ? _value.targetUserIds
          : targetUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      referenceType: freezed == referenceType
          ? _value.referenceType
          : referenceType // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      recipientCount: null == recipientCount
          ? _value.recipientCount
          : recipientCount // ignore: cast_nullable_to_non_nullable
              as int,
      sentCount: null == sentCount
          ? _value.sentCount
          : sentCount // ignore: cast_nullable_to_non_nullable
              as int,
      skippedCount: null == skippedCount
          ? _value.skippedCount
          : skippedCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BroadcastLogImplCopyWith<$Res>
    implements $BroadcastLogCopyWith<$Res> {
  factory _$$BroadcastLogImplCopyWith(
          _$BroadcastLogImpl value, $Res Function(_$BroadcastLogImpl) then) =
      __$$BroadcastLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? senderId,
      String titleAr,
      String bodyAr,
      NotificationType type,
      BroadcastTargetType targetType,
      List<String> targetUserIds,
      String? referenceType,
      String? referenceId,
      int recipientCount,
      int sentCount,
      int skippedCount,
      DateTime createdAt});
}

/// @nodoc
class __$$BroadcastLogImplCopyWithImpl<$Res>
    extends _$BroadcastLogCopyWithImpl<$Res, _$BroadcastLogImpl>
    implements _$$BroadcastLogImplCopyWith<$Res> {
  __$$BroadcastLogImplCopyWithImpl(
      _$BroadcastLogImpl _value, $Res Function(_$BroadcastLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of BroadcastLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = freezed,
    Object? titleAr = null,
    Object? bodyAr = null,
    Object? type = null,
    Object? targetType = null,
    Object? targetUserIds = null,
    Object? referenceType = freezed,
    Object? referenceId = freezed,
    Object? recipientCount = null,
    Object? sentCount = null,
    Object? skippedCount = null,
    Object? createdAt = null,
  }) {
    return _then(_$BroadcastLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: freezed == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String?,
      titleAr: null == titleAr
          ? _value.titleAr
          : titleAr // ignore: cast_nullable_to_non_nullable
              as String,
      bodyAr: null == bodyAr
          ? _value.bodyAr
          : bodyAr // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      targetType: null == targetType
          ? _value.targetType
          : targetType // ignore: cast_nullable_to_non_nullable
              as BroadcastTargetType,
      targetUserIds: null == targetUserIds
          ? _value._targetUserIds
          : targetUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      referenceType: freezed == referenceType
          ? _value.referenceType
          : referenceType // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      recipientCount: null == recipientCount
          ? _value.recipientCount
          : recipientCount // ignore: cast_nullable_to_non_nullable
              as int,
      sentCount: null == sentCount
          ? _value.sentCount
          : sentCount // ignore: cast_nullable_to_non_nullable
              as int,
      skippedCount: null == skippedCount
          ? _value.skippedCount
          : skippedCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$BroadcastLogImpl implements _BroadcastLog {
  const _$BroadcastLogImpl(
      {required this.id,
      this.senderId,
      required this.titleAr,
      required this.bodyAr,
      required this.type,
      required this.targetType,
      final List<String> targetUserIds = const <String>[],
      this.referenceType,
      this.referenceId,
      this.recipientCount = 0,
      this.sentCount = 0,
      this.skippedCount = 0,
      required this.createdAt})
      : _targetUserIds = targetUserIds;

  @override
  final String id;
  @override
  final String? senderId;
  @override
  final String titleAr;
  @override
  final String bodyAr;
  @override
  final NotificationType type;
  @override
  final BroadcastTargetType targetType;
  final List<String> _targetUserIds;
  @override
  @JsonKey()
  List<String> get targetUserIds {
    if (_targetUserIds is EqualUnmodifiableListView) return _targetUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetUserIds);
  }

  @override
  final String? referenceType;
  @override
  final String? referenceId;
  @override
  @JsonKey()
  final int recipientCount;
  @override
  @JsonKey()
  final int sentCount;
  @override
  @JsonKey()
  final int skippedCount;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'BroadcastLog(id: $id, senderId: $senderId, titleAr: $titleAr, bodyAr: $bodyAr, type: $type, targetType: $targetType, targetUserIds: $targetUserIds, referenceType: $referenceType, referenceId: $referenceId, recipientCount: $recipientCount, sentCount: $sentCount, skippedCount: $skippedCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BroadcastLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.titleAr, titleAr) || other.titleAr == titleAr) &&
            (identical(other.bodyAr, bodyAr) || other.bodyAr == bodyAr) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            const DeepCollectionEquality()
                .equals(other._targetUserIds, _targetUserIds) &&
            (identical(other.referenceType, referenceType) ||
                other.referenceType == referenceType) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.recipientCount, recipientCount) ||
                other.recipientCount == recipientCount) &&
            (identical(other.sentCount, sentCount) ||
                other.sentCount == sentCount) &&
            (identical(other.skippedCount, skippedCount) ||
                other.skippedCount == skippedCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      senderId,
      titleAr,
      bodyAr,
      type,
      targetType,
      const DeepCollectionEquality().hash(_targetUserIds),
      referenceType,
      referenceId,
      recipientCount,
      sentCount,
      skippedCount,
      createdAt);

  /// Create a copy of BroadcastLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BroadcastLogImplCopyWith<_$BroadcastLogImpl> get copyWith =>
      __$$BroadcastLogImplCopyWithImpl<_$BroadcastLogImpl>(this, _$identity);
}

abstract class _BroadcastLog implements BroadcastLog {
  const factory _BroadcastLog(
      {required final String id,
      final String? senderId,
      required final String titleAr,
      required final String bodyAr,
      required final NotificationType type,
      required final BroadcastTargetType targetType,
      final List<String> targetUserIds,
      final String? referenceType,
      final String? referenceId,
      final int recipientCount,
      final int sentCount,
      final int skippedCount,
      required final DateTime createdAt}) = _$BroadcastLogImpl;

  @override
  String get id;
  @override
  String? get senderId;
  @override
  String get titleAr;
  @override
  String get bodyAr;
  @override
  NotificationType get type;
  @override
  BroadcastTargetType get targetType;
  @override
  List<String> get targetUserIds;
  @override
  String? get referenceType;
  @override
  String? get referenceId;
  @override
  int get recipientCount;
  @override
  int get sentCount;
  @override
  int get skippedCount;
  @override
  DateTime get createdAt;

  /// Create a copy of BroadcastLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BroadcastLogImplCopyWith<_$BroadcastLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
