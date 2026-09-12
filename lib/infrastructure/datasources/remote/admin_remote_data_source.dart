import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dtos/coupon_dto.dart';
import '../../dtos/delivery_zone_dto.dart';
import '../../dtos/user_profile_dto.dart';

class AdminRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<UserProfileDTO>> getCustomers() async {
    final data = await _client
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => UserProfileDTO.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final totalOrders =
        await _client.from('orders').select('*').count(CountOption.exact);
    final pendingOrders = await _client
        .from('orders')
        .select('*')
        .eq('status', 'pending')
        .count(CountOption.exact);
    final totalProducts =
        await _client.from('products').select('*').count(CountOption.exact);
    final totalCustomers =
        await _client.from('profiles').select('*').count(CountOption.exact);

    return {
      'totalOrders': totalOrders.count,
      'pendingOrders': pendingOrders.count,
      'totalProducts': totalProducts.count,
      'totalCustomers': totalCustomers.count,
    };
  }

  Future<List<CouponDTO>> getCoupons() async {
    final data = await _client
        .from('coupons')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => CouponDTO.fromJson(e)).toList();
  }

  Future<void> upsertCoupon(Map<String, dynamic> data, {String? id}) async {
    if (id != null) {
      await _client.from('coupons').update(data).eq('id', id);
    } else {
      await _client.from('coupons').insert(data);
    }
  }

  Future<void> toggleCouponActive(String id, bool isActive) async {
    await _client.from('coupons').update({'is_active': isActive}).eq('id', id);
  }

  Future<List<DeliveryZoneDTO>> getDeliveryZones() async {
    final data = await _client.from('delivery_zones').select().order('name');
    return (data as List).map((e) => DeliveryZoneDTO.fromJson(e)).toList();
  }

  Future<void> upsertDeliveryZone(Map<String, dynamic> data,
      {String? id}) async {
    if (id != null) {
      await _client.from('delivery_zones').update(data).eq('id', id);
    } else {
      await _client.from('delivery_zones').insert(data);
    }
  }

  Future<List<Map<String, dynamic>>> getBusinessSettings() async {
    final data = await _client.from('business_settings').select();
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> upsertBusinessSetting(
      String key, Map<String, dynamic> value) async {
    await _client
        .from('business_settings')
        .upsert({'key': key, 'value': value});
  }
}
