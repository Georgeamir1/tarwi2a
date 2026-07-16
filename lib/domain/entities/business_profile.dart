import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_profile.freezed.dart';

@freezed
class BusinessProfile with _$BusinessProfile {
  const factory BusinessProfile({
    required String id,
    required String name,
    String? phone,
    String? address,
    String? logoUrl,
    required Map<String, OpeningPeriod> openingHours,
    @Default(0.0) double minOrder,
    @Default(30) int defaultPrepTime,
    @Default(false) bool isBusy,
    String? busyMessage,
    @Default(true) bool acceptOrders,
    String? whatsappNumber,
    String? vodafoneCashNumber,
    String? instapayHandle,
    required DateTime updatedAt,
  }) = _BusinessProfile;
}

@freezed
class OpeningPeriod with _$OpeningPeriod {
  const factory OpeningPeriod({
    required String open,
    required String close,
  }) = _OpeningPeriod;
}
