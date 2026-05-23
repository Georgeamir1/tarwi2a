import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/logger/app_logger.dart';
import '../../dtos/user_profile_dto.dart';

class ProfileRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserProfileDTO?> getProfile(String userId) async {
    appLogger.d('[ProfileDS] getProfile called — userId: $userId');
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) {
        appLogger
            .d('[ProfileDS] getProfile ⚠ — no row found in profiles table');
        return null;
      }
      appLogger.d('[ProfileDS] getProfile ✅ — profile loaded');
      return UserProfileDTO.fromJson(data);
    } catch (e, s) {
      appLogger.e('[ProfileDS] getProfile ❌ failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> updateProfile(UserProfileDTO profile) async {
    appLogger.d('[ProfileDS] updateProfile called — id: ${profile.id}');
    try {
      await _client
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id);
      appLogger.d('[ProfileDS] updateProfile ✅');
    } catch (e, s) {
      appLogger.e('[ProfileDS] updateProfile ❌ failed',
          error: e, stackTrace: s);
      rethrow;
    }
  }
}
