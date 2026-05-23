import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_option.freezed.dart';

@freezed
class SelectedOption with _$SelectedOption {
  const factory SelectedOption({
    required String optionId,
    required String name,
    required double priceAdjustment,
  }) = _SelectedOption;
}
