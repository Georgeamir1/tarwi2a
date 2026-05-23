import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_setting.freezed.dart';

@freezed
class BusinessSetting with _$BusinessSetting {
  const factory BusinessSetting({
    required String id,
    required String key,
    required Map<String, dynamic> value,
  }) = _BusinessSetting;
}
