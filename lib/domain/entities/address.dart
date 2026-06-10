import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';

@freezed
class Address with _$Address {
  const factory Address({
    required String id,
    required String userId,
    required String label,
    required String address,
    double? latitude,
    double? longitude,
    String? building,
    String? floor,
    String? apartment,
    String? notes,
    @Default(false) bool isDefault,
    required DateTime createdAt,
    String? deliveryZoneId,
    String? deliveryZoneName,
    double? deliveryFee,
  }) = _Address;
}
