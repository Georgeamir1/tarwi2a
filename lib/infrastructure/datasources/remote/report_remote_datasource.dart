import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dtos/order_dto.dart';
import '../../dtos/product_dto.dart';

class ReportRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<OrderDTO>> getOrders(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final data = await _client
        .from('orders')
        .select()
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String());
    return (data as List).map((e) => OrderDTO.fromJson(e)).toList();
  }

  Future<List<OrderDTO>> getOrdersWithItems(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String());
    return (data as List).map((e) => OrderDTO.fromJson(e)).toList();
  }

  Future<int> getTotalCustomers() async {
    final data =
        await _client.from('profiles').select('*').count(CountOption.exact);
    return data.count;
  }

  Future<List<ProductDTO>> getProductsFromOrderItems(
    List<OrderDTO> orders,
  ) async {
    final productIds = <String>{};
    for (final order in orders) {
      if (order.items != null) {
        for (final item in order.items!) {
          if (item.productId != null) {
            productIds.add(item.productId!);
          }
        }
      }
    }
    if (productIds.isEmpty) return [];

    final data = await _client
        .from('products')
        .select()
        .inFilter('id', productIds.toList());
    return (data as List).map((e) => ProductDTO.fromJson(e)).toList();
  }
}
