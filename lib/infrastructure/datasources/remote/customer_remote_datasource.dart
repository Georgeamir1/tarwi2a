import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/logger/app_logger.dart';
import '../../dtos/customer_dto.dart';

class CustomerRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CustomerDTO>> getAll() async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('role', 'customer')
          .order('created_at', ascending: false);
      final profiles =
          (data as List).map((e) => CustomerDTO.fromJson(e)).toList();

      return profiles.map((dto) {
        return CustomerDTO(
          id: dto.id,
          name: dto.name,
          phone: dto.phone,
          role: dto.role,
          createdAt: dto.createdAt,
          totalOrders: 0,
          totalSpent: 0,
        );
      }).toList();
    } catch (e, s) {
      appLogger.e('Failed to fetch customers', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<Map<String, Map<String, dynamic>>> getOrderStats(
      List<String> customerIds) async {
    if (customerIds.isEmpty) return {};
    try {
      final ordersData = await _client
          .from('orders')
          .select('customer_id, total_amount, created_at');

      final stats = <String, Map<String, dynamic>>{};
      for (final o in (ordersData as List)) {
        final cid = o['customer_id'] as String?;
        if (cid == null || !customerIds.contains(cid)) continue;

        stats.putIfAbsent(cid, () => {'count': 0, 'spent': 0.0});
        stats[cid]!['count'] = (stats[cid]!['count'] as int) + 1;
        stats[cid]!['spent'] = (stats[cid]!['spent'] as num).toDouble() +
            (o['total_amount'] as num).toDouble();
        final orderDate = o['created_at'] as String?;
        if (orderDate != null) {
          final parsed = DateTime.tryParse(orderDate);
          if (parsed != null) {
            final current = stats[cid]!['last_order_at'] as DateTime?;
            if (current == null || parsed.isAfter(current)) {
              stats[cid]!['last_order_at'] = parsed;
            }
          }
        }
      }
      return stats;
    } catch (e, s) {
      appLogger.e('Failed to fetch order stats', error: e, stackTrace: s);
      return {};
    }
  }

  Future<List<CustomerDTO>> search(String query) async {
    final all = await getAll();
    final lower = query.toLowerCase();
    return all.where((c) {
      return c.name.toLowerCase().contains(lower) ||
          (c.phone?.contains(query) ?? false);
    }).toList();
  }

  Future<CustomerDTO?> getById(String id) async {
    final data =
        await _client.from('profiles').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return CustomerDTO.fromJson(data);
  }

  Stream<List<CustomerDTO>> watchCustomers() {
    return _client.from('profiles').stream(primaryKey: ['id']).map((data) =>
        data
            .where((json) => json['role'] == 'customer')
            .map((json) => CustomerDTO.fromJson(json))
            .toList());
  }
}
