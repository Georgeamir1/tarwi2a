import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/logger/app_logger.dart';
import '../../dtos/order_dto.dart';

class OrderRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<OrderDTO> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> itemsData,
  }) async {
    appLogger.d(
        '[OrderRemoteDS] createOrder — keys: ${orderData.keys.toList()}, items: ${itemsData.length}');
    try {
      final orderId = await _client.rpc('create_order_with_items', params: {
        'p_order': orderData,
        'p_items': itemsData,
      });

      appLogger.d('[OrderRemoteDS] order created via RPC, id: $orderId');

      final orderResult = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId as String)
          .single();

      return OrderDTO.fromJson(orderResult);
    } catch (e, st) {
      appLogger.e('[OrderRemoteDS] createOrder FAILED',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<OrderDTO>> getCustomerOrders(String customerId) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => OrderDTO.fromJson(e)).toList();
  }

  Future<List<OrderDTO>> getAllAdmin() async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false);
    return (data as List).map((e) => OrderDTO.fromJson(e)).toList();
  }

  Future<void> updateStatus(String orderId, String status) async {
    await _client.from('orders').update({'status': status}).eq('id', orderId);
  }

  Future<void> updatePaymentStatus(String orderId, String paymentStatus,
      {String? paymentProofUrl}) async {
    final updates = <String, dynamic>{'payment_status': paymentStatus};
    if (paymentProofUrl != null) {
      updates['payment_proof_url'] = paymentProofUrl;
    }
    await _client.from('orders').update(updates).eq('id', orderId);
  }

  Stream<List<Map<String, dynamic>>> watchOrders() {
    return _client
        .from('orders')
        .stream(primaryKey: ['id']).order('created_at', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> watchCustomerOrders(String customerId) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .order('created_at', ascending: false)
        .map((rows) =>
            rows.where((row) => row['customer_id'] == customerId).toList());
  }
}
