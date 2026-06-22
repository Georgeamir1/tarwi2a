import 'package:supabase_flutter/supabase_flutter.dart';

class DeviceTokenRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> registerToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    await _client.from('device_tokens').upsert(
      {'user_id': userId, 'token': token, 'platform': platform},
      onConflict: 'token',
    );
  }

  Future<void> unregisterToken({required String token}) async {
    await _client.from('device_tokens').delete().eq('token', token);
  }

  Future<List<String>> getTokensForUser({required String userId}) async {
    final data = await _client
        .from('device_tokens')
        .select('token')
        .eq('user_id', userId);
    return (data as List).map((row) => row['token'] as String).toList();
  }
}
