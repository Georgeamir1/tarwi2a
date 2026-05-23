import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dtos/business_profile_dto.dart';

class BusinessProfileRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<BusinessProfileDTO?> get() async {
    final data =
        await _client.from('business_profiles').select().limit(1).single();
    return BusinessProfileDTO.fromJson(data);
  }

  Future<void> update(Map<String, dynamic> data) async {
    final profile = await _client
        .from('business_profiles')
        .select('id')
        .limit(1)
        .maybeSingle();

    if (profile != null) {
      await _client
          .from('business_profiles')
          .update(data)
          .eq('id', profile['id']);
    }
  }

  Future<void> toggleAcceptOrders(String id, bool accept) async {
    await _client.from('business_profiles').update({
      'accept_orders': accept,
      'updated_at': DateTime.now().toIso8601String()
    }).eq('id', id);
  }

  Future<void> toggleBusyMode(String id, bool isBusy, String? message) async {
    await _client.from('business_profiles').update({
      'is_busy': isBusy,
      'busy_message': message,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Stream<BusinessProfileDTO?> watchBusinessProfile() {
    return _client.from('business_profiles').stream(primaryKey: ['id']).map(
        (data) =>
            data.isEmpty ? null : BusinessProfileDTO.fromJson(data.first));
  }
}
