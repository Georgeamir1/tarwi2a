import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/logger/app_logger.dart';
import '../../dtos/order_dto.dart';

class OrderRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<OrderDTO> createOrder({
    Map<String, dynamic>? payload,
    Map<String, dynamic>? orderData,
    List<Map<String, dynamic>>? itemsData,
  }) async {
    final effectivePayload = Map<String, dynamic>.from(payload ?? {});
    if (effectivePayload.isEmpty) {
      if (orderData != null) effectivePayload.addAll(orderData);
      if (itemsData != null) effectivePayload['items'] = itemsData;
    }
    appLogger.d(
        '[OrderRemoteDS] createAuthoritativeOrder — keys: ${effectivePayload.keys.toList()}');
    try {
      final orderId = await _client.rpc('create_authoritative_order', params: {
        'p_payload': effectivePayload,
      });

      appLogger.d(
          '[OrderRemoteDS] order created via authoritative RPC, id: $orderId');

      final orderResult = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId as String)
          .single();

      return OrderDTO.fromJson(orderResult);
    } catch (e, st) {
      appLogger.e('[OrderRemoteDS] createAuthoritativeOrder FAILED',
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

  Future<OrderDTO?> getOrderById(String orderId) async {
    try {
      final data = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .maybeSingle();
      if (data == null) return null;
      return OrderDTO.fromJson(data);
    } catch (e, st) {
      appLogger.e('[OrderRemoteDS] getOrderById failed',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> updateStatus(String orderId, String status) async {
    final updates = <String, dynamic>{'status': status};
    if (status == 'delivered') {
      updates['payment_status'] = 'confirmed';
    }
    final response = await _client
        .from('orders')
        .update(updates)
        .eq('id', orderId)
        .select()
        .single();
    appLogger.d(
        '[OrderRemoteDS] updateStatus success. Supabase response: $response');
  }

  Future<void> updatePaymentStatus(String orderId, String paymentStatus,
      {String? paymentProofUrl}) async {
    final updates = <String, dynamic>{'payment_status': paymentStatus};
    if (paymentProofUrl != null) {
      updates['payment_proof_url'] = paymentProofUrl;
    }
    final response = await _client
        .from('orders')
        .update(updates)
        .eq('id', orderId)
        .select()
        .single();
    appLogger.d(
        '[OrderRemoteDS] updatePaymentStatus success. Supabase response: $response');
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
