import '../../domain/entities/address.dart';

class AddressDTO {
  final String id;
  final String userId;
  final String label;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? notes;
  final bool isDefault;
  final DateTime createdAt;
  final String? deliveryZoneId;
  final String? deliveryZoneName;
  final double? deliveryFee;

  const AddressDTO({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    this.latitude,
    this.longitude,
    this.building,
    this.floor,
    this.apartment,
    this.notes,
    required this.isDefault,
    required this.createdAt,
    this.deliveryZoneId,
    this.deliveryZoneName,
    this.deliveryFee,
  });

  factory AddressDTO.fromJson(Map<String, dynamic> json) {
    return AddressDTO(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
      notes: json['notes'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      deliveryZoneId: json['delivery_zone_id'] as String?,
      deliveryZoneName: json['delivery_zone_name'] as String?,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (building != null) 'building': building,
      if (floor != null) 'floor': floor,
      if (apartment != null) 'apartment': apartment,
      if (notes != null) 'notes': notes,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      if (deliveryZoneId != null) 'delivery_zone_id': deliveryZoneId,
      if (deliveryZoneName != null) 'delivery_zone_name': deliveryZoneName,
      if (deliveryFee != null) 'delivery_fee': deliveryFee,
    };
  }

  Address toDomain() {
    return Address(
      id: id,
      userId: userId,
      label: label,
      address: address,
      latitude: latitude,
      longitude: longitude,
      building: building,
      floor: floor,
      apartment: apartment,
      notes: notes,
      isDefault: isDefault,
      createdAt: createdAt,
      deliveryZoneId: deliveryZoneId,
      deliveryZoneName: deliveryZoneName,
      deliveryFee: deliveryFee,
    );
  }
}
