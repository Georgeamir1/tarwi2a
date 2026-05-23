import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/sanitizer.dart';
import '../../dtos/category_dto.dart';

class CategoryRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CategoryDTO>> getCategories() async {
    final data = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return (data as List).map((e) => CategoryDTO.fromJson(e)).toList();
  }

  Future<List<CategoryDTO>> getAllAdmin() async {
    final data = await _client.from('categories').select().order('sort_order');
    return (data as List).map((e) => CategoryDTO.fromJson(e)).toList();
  }

  Future<void> upsert(Map<String, dynamic> data, {String? id}) async {
    final sanitizedData = _sanitizeData(data);
    if (id != null) {
      await _client.from('categories').update(sanitizedData).eq('id', id);
    } else {
      await _client.from('categories').insert(sanitizedData);
    }
  }

  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    return Map.fromEntries(
      data.entries.map((e) {
        if (e.key == 'name' || e.key == 'name_ar') {
          return MapEntry(
              e.key, Sanitizer.sanitizeNullable(e.value as String?));
        }
        return e;
      }),
    );
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _client
        .from('categories')
        .update({'is_active': isActive}).eq('id', id);
  }

  Stream<List<CategoryDTO>> watchCategories() {
    return _client.from('categories').stream(primaryKey: ['id']).map(
        (data) => data.map((json) => CategoryDTO.fromJson(json)).toList());
  }
}
