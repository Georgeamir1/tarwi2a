import 'package:dartz/dartz.dart';
import '../../../domain/entities/order_rating.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/rating_repository.dart';
import '../../../core/logger/app_logger.dart';
import '../datasources/remote/rating_remote_data_source.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingRemoteDataSource _remoteDataSource;

  RatingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, OrderRating>> rateOrder({
    required String orderId,
    required String customerId,
    required String customerName,
    required int rating,
    String? comment,
  }) async {
    try {
      final dto = await _remoteDataSource.rateOrder(
        orderId: orderId,
        customerId: customerId,
        customerName: customerName,
        rating: rating,
        comment: comment,
      );
      return right(dto.toDomain());
    } catch (e, st) {
      appLogger.e('[RatingRepo] rateOrder FAILED', error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderRating>>> getProductRatings(
      String productId) async {
    try {
      final dtos = await _remoteDataSource.getProductRatings(productId);
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e, st) {
      appLogger.e('[RatingRepo] getProductRatings FAILED',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderRating?>> getOrderRating(String orderId) async {
    try {
      final dto = await _remoteDataSource.getOrderRating(orderId);
      return right(dto?.toDomain());
    } catch (e, st) {
      appLogger.e('[RatingRepo] getOrderRating FAILED',
          error: e, stackTrace: st);
      return left(Failure.unexpected(message: e.toString()));
    }
  }
}
