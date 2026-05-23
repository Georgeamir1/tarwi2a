import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';

@freezed
class Review with _$Review {
  const factory Review({
    required String id,
    required String orderId,
    required String userId,
    required String productId,
    required int rating,
    String? comment,
    @Default([]) List<String> images,
    required DateTime createdAt,
  }) = _Review;
}
