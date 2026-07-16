import 'package:dartz/dartz.dart';
import '../entities/order_rating.dart';
import '../failures/failure.dart';

abstract class RatingRepository {
  Future<Either<Failure, OrderRating>> rateOrder({
    required String orderId,
    required String customerId,
    required String customerName,
    required int rating,
    String? comment,
  });

  Future<Either<Failure, List<OrderRating>>> getProductRatings(String productId);
  Future<Either<Failure, OrderRating?>> getOrderRating(String orderId);
}
