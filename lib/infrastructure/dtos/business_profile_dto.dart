import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/business_profile.dart';

part 'business_profile_dto.g.dart';

@JsonSerializable()
class BusinessProfileDTO {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  @JsonKey(name: 'opening_hours')
  final Map<String, dynamic>? openingHours;
  @JsonKey(name: 'min_order')
  final double minOrder;
  @JsonKey(name: 'default_prep_time')
  final int defaultPrepTime;
  @JsonKey(name: 'is_busy')
  final bool isBusy;
  @JsonKey(name: 'busy_message')
  final String? busyMessage;
  @JsonKey(name: 'accept_orders')
  final bool acceptOrders;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const BusinessProfileDTO({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.logoUrl,
    this.openingHours,
    required this.minOrder,
    required this.defaultPrepTime,
    required this.isBusy,
    this.busyMessage,
    required this.acceptOrders,
    required this.updatedAt,
  });

  factory BusinessProfileDTO.fromJson(Map<String, dynamic> json) =>
      _$BusinessProfileDTOFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessProfileDTOToJson(this);

  BusinessProfile toDomain() {
    final hours = (openingHours ?? {}).map(
      (key, value) {
        final v = Map<String, dynamic>.from(value as Map);
        return MapEntry(
          key,
          OpeningPeriod(
            open: v['open'] as String? ?? '00:00',
            close: v['close'] as String? ?? '00:00',
          ),
        );
      },
    );
    return BusinessProfile(
      id: id,
      name: name,
      phone: phone,
      address: address,
      logoUrl: logoUrl,
      openingHours: hours,
      minOrder: minOrder,
      defaultPrepTime: defaultPrepTime,
      isBusy: isBusy,
      busyMessage: busyMessage,
      acceptOrders: acceptOrders,
      updatedAt: updatedAt,
    );
  }
}
