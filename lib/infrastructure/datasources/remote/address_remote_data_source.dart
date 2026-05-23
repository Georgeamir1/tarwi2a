import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/logger/app_logger.dart';
import '../../dtos/address_dto.dart';

class AddressRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<AddressDTO>> getAddresses(String userId) async {
    appLogger.d('[AddressDS] getAddresses for user: $userId');
    final data = await _client
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    appLogger.d('[AddressDS] got ${data.length} addresses');
    return (data as List).map((e) => AddressDTO.fromJson(e)).toList();
  }

  Future<AddressDTO> createAddress(Map<String, dynamic> data) async {
    appLogger.d('[AddressDS] createAddress');
    final result = await _client.from('addresses').insert(data).select().single();
    return AddressDTO.fromJson(result);
  }

  Future<AddressDTO> updateAddress(String id, Map<String, dynamic> data) async {
    appLogger.d('[AddressDS] updateAddress: $id');
    final result =
        await _client.from('addresses').update(data).eq('id', id).select().single();
    return AddressDTO.fromJson(result);
  }

  Future<void> deleteAddress(String id) async {
    appLogger.d('[AddressDS] deleteAddress: $id');
    await _client.from('addresses').delete().eq('id', id);
  }

  Future<void> setDefault(String id, String userId) async {
    appLogger.d('[AddressDS] setDefault: $id for user: $userId');
    await _client
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', userId)
        .neq('id', id);
    await _client
        .from('addresses')
        .update({'is_default': true})
        .eq('id', id);
  }
}
