import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dtos/coupon_dto.dart';

class CouponRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CouponDTO>> getAll() async {
    final data = await _client
        .from('coupons')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => CouponDTO.fromJson(e)).toList();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _client.from('coupons').insert(data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _client.from('coupons').update(data).eq('id', id);
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _client.from('coupons').update({'is_active': isActive}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('coupons').delete().eq('id', id);
  }

  Stream<List<CouponDTO>> watchCoupons() {
    return _client.from('coupons').stream(primaryKey: ['id']).map(
        (data) => data.map((json) => CouponDTO.fromJson(json)).toList());
  }
}
