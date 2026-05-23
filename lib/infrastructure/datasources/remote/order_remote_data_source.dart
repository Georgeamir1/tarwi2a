import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dtos/order_dto.dart';

class OrderRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<OrderDTO> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> itemsData,
  }) async {
    final result =
        await _client.from('orders').insert(orderData).select().single();

    final orderId = result['id'] as String;
    final orderItems =
        itemsData.map((item) => {...item, 'order_id': orderId}).toList();

    await _client.from('order_items').insert(orderItems);

    return OrderDTO.fromJson({...result, 'order_items': []});
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
}
