import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/logger/app_logger.dart';
import '../../dtos/delivery_zone_dto.dart';

class DeliveryZoneRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<DeliveryZoneDTO>> getAll() async {
    final data = await _client
        .from('delivery_zones')
        .select()
        .order('created_at', ascending: false);
    appLogger.i('📊 delivery_zones getAll() raw result: $data');
    return (data as List).map((e) => DeliveryZoneDTO.fromJson(e)).toList();
  }

  Future<void> upsert(Map<String, dynamic> data, {String? id}) async {
    if (id != null) {
      await _client.from('delivery_zones').update(data).eq('id', id);
    } else {
      await _client.from('delivery_zones').insert(data);
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _client
        .from('delivery_zones')
        .update({'is_active': isActive}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('delivery_zones').delete().eq('id', id);
  }

  Stream<List<DeliveryZoneDTO>> watchDeliveryZones() {
    return _client.from('delivery_zones').stream(primaryKey: ['id']).map(
        (data) => data.map((json) => DeliveryZoneDTO.fromJson(json)).toList());
  }
}
