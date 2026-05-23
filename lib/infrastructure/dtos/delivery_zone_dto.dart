import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/delivery_zone.dart';

part 'delivery_zone_dto.g.dart';

@JsonSerializable()
class DeliveryZoneDTO {
  final String id;
  final String name;
  final double fee;
  @JsonKey(name: 'min_order')
  final double minOrderAmount;
  @JsonKey(name: 'estimated_time')
  final String? estimatedTime;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final Map<String, dynamic>? coordinates;

  const DeliveryZoneDTO({
    required this.id,
    required this.name,
    required this.fee,
    required this.minOrderAmount,
    this.estimatedTime,
    required this.isActive,
    required this.createdAt,
    this.coordinates,
  });

  factory DeliveryZoneDTO.fromJson(Map<String, dynamic> json) =>
      _$DeliveryZoneDTOFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryZoneDTOToJson(this);

  DeliveryZone toDomain() => DeliveryZone(
        id: id,
        name: name,
        fee: fee,
        minOrderAmount: minOrderAmount,
        estimatedTime: estimatedTime,
        isActive: isActive,
        createdAt: createdAt,
        coordinates: coordinates,
      );
}
