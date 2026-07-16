import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_rating.freezed.dart';

@freezed
class OrderRating with _$OrderRating {
  const factory OrderRating({
    required String id,
    required String orderId,
    String? customerId,
    required String customerName,
    required int rating,
    String? comment,
    required DateTime createdAt,
  }) = _OrderRating;
}
