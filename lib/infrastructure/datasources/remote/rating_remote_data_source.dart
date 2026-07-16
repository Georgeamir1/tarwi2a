import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/logger/app_logger.dart';
import '../../dtos/order_rating_dto.dart';

class RatingRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<OrderRatingDTO> rateOrder({
    required String orderId,
    required String customerId,
    required String customerName,
    required int rating,
    String? comment,
  }) async {
    appLogger.d('[RatingRemoteDS] rateOrder — orderId: $orderId, rating: $rating');
    try {
      final data = {
        'order_id': orderId,
        'customer_id': customerId,
        'customer_name': customerName,
        'rating': rating,
        if (comment != null) 'comment': comment,
      };
      final result = await _client
          .from('order_ratings')
          .insert(data)
          .select()
          .single();
      appLogger.d('[RatingRemoteDS] rateOrder success. Supabase response: $result');
      return OrderRatingDTO.fromJson(result);
    } catch (e, st) {
      appLogger.e('[RatingRemoteDS] rateOrder FAILED', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<OrderRatingDTO>> getProductRatings(String productId) async {
    try {
      final itemsData = await _client
          .from('order_items')
          .select('order_id')
          .eq('product_id', productId);
      
      final orderIds = (itemsData as List)
          .map((item) => item['order_id'] as String)
          .toList();
      
      if (orderIds.isEmpty) return [];

      final ratingsData = await _client
          .from('order_ratings')
          .select('*')
          .inFilter('order_id', orderIds)
          .order('created_at', ascending: false);

      return (ratingsData as List)
          .map((e) => OrderRatingDTO.fromJson(e))
          .toList();
    } catch (e, st) {
      appLogger.e('[RatingRemoteDS] getProductRatings FAILED', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<OrderRatingDTO?> getOrderRating(String orderId) async {
    try {
      final result = await _client
          .from('order_ratings')
          .select('*')
          .eq('order_id', orderId)
          .maybeSingle();
      if (result == null) return null;
      return OrderRatingDTO.fromJson(result);
    } catch (e, st) {
      appLogger.e('[RatingRemoteDS] getOrderRating FAILED', error: e, stackTrace: st);
      rethrow;
    }
  }
}
