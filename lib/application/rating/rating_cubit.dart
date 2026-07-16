import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/order_rating.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/rating_repository.dart';
import '../../../core/logger/app_logger.dart';

class RatingCubit extends Cubit<RatingState> {
  final RatingRepository _ratingRepository;

  RatingCubit(this._ratingRepository) : super(RatingState.initial());

  Future<void> rateOrder({
    required String orderId,
    required String customerId,
    required String customerName,
    required int rating,
    String? comment,
  }) async {
    emit(state.copyWith(status: RatingStatus.saving));
    final result = await _ratingRepository.rateOrder(
      orderId: orderId,
      customerId: customerId,
      customerName: customerName,
      rating: rating,
      comment: comment,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: RatingStatus.error,
        failure: failure,
      )),
      (orderRating) {
        appLogger.d('[RatingCubit] rateOrder successful for order: $orderId');
        emit(state.copyWith(
          status: RatingStatus.saved,
          orderRating: orderRating,
        ));
      },
    );
  }

  Future<void> loadProductRatings(String productId) async {
    emit(state.copyWith(status: RatingStatus.loading));
    final result = await _ratingRepository.getProductRatings(productId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: RatingStatus.error,
        failure: failure,
      )),
      (ratings) => emit(state.copyWith(
        status: RatingStatus.loaded,
        productRatings: ratings,
      )),
    );
  }

  Future<void> loadOrderRating(String orderId) async {
    emit(state.copyWith(status: RatingStatus.loading));
    final result = await _ratingRepository.getOrderRating(orderId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: RatingStatus.error,
        failure: failure,
      )),
      (rating) => emit(state.copyWith(
        status: RatingStatus.loaded,
        orderRating: rating,
      )),
    );
  }
}

enum RatingStatus { initial, loading, loaded, saving, saved, error }

class RatingState extends Equatable {
  final List<OrderRating> productRatings;
  final OrderRating? orderRating;
  final RatingStatus status;
  final Failure? failure;

  const RatingState({
    this.productRatings = const [],
    this.orderRating,
    this.status = RatingStatus.initial,
    this.failure,
  });

  factory RatingState.initial() => const RatingState();

  RatingState copyWith({
    List<OrderRating>? productRatings,
    OrderRating? orderRating,
    RatingStatus? status,
    Failure? failure,
  }) {
    return RatingState(
      productRatings: productRatings ?? this.productRatings,
      orderRating: orderRating ?? this.orderRating,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [productRatings, orderRating, status, failure];
}
