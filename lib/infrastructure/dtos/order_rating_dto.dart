import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/order_rating.dart';

part 'order_rating_dto.g.dart';

@JsonSerializable()
class OrderRatingDTO {
  final String id;
  @JsonKey(name: 'order_id')
  final String orderId;
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @JsonKey(name: 'customer_name')
  final String customerName;
  final int rating;
  final String? comment;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const OrderRatingDTO({
    required this.id,
    required this.orderId,
    this.customerId,
    required this.customerName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory OrderRatingDTO.fromJson(Map<String, dynamic> json) =>
      _$OrderRatingDTOFromJson(json);

  Map<String, dynamic> toJson() => _$OrderRatingDTOToJson(this);

  OrderRating toDomain() => OrderRating(
        id: id,
        orderId: orderId,
        customerId: customerId,
        customerName: customerName,
        rating: rating,
        comment: comment,
        createdAt: createdAt,
      );
}
