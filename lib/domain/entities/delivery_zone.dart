import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_zone.freezed.dart';

@freezed
class DeliveryZone with _$DeliveryZone {
  const factory DeliveryZone({
    required String id,
    required String name,
    required double fee,
    @Default(0.0) double minOrderAmount,
    String? estimatedTime,
    required bool isActive,
    required DateTime createdAt,
    Map<String, dynamic>? coordinates,
  }) = _DeliveryZone;
}
