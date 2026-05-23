import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/sanitizer.dart';
import '../../dtos/product_dto.dart';

class ProductRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ProductDTO>> getProducts({String? categoryId}) async {
    var query = _client.from('products').select().eq('is_available', true);
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    final data = await query.order('sort_order');
    return (data as List).map((e) => ProductDTO.fromJson(e)).toList();
  }

  Future<List<ProductDTO>> getAllAdmin() async {
    final data = await _client.from('products').select().order('sort_order');
    return (data as List).map((e) => ProductDTO.fromJson(e)).toList();
  }

  Future<void> upsert(Map<String, dynamic> data, {String? id}) async {
    final sanitizedData = _sanitizeData(data);
    if (id != null) {
      await _client.from('products').update(sanitizedData).eq('id', id);
    } else {
      await _client.from('products').insert(sanitizedData);
    }
  }

  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    return Map.fromEntries(
      data.entries.map((e) {
        if (e.key == 'description' ||
            e.key == 'description_ar' ||
            e.key == 'name' ||
            e.key == 'name_ar') {
          return MapEntry(
              e.key, Sanitizer.sanitizeNullable(e.value as String?));
        }
        return e;
      }),
    );
  }

  Future<void> toggleAvailable(String id, bool isAvailable) async {
    await _client
        .from('products')
        .update({'is_available': isAvailable}).eq('id', id);
  }

  Stream<List<ProductDTO>> watchProducts({String? categoryId}) {
    return _client.from('products').stream(primaryKey: ['id']).map((data) {
      final dtos = data.map((json) => ProductDTO.fromJson(json)).toList();
      if (categoryId != null) {
        return dtos.where((p) => p.categoryId == categoryId).toList();
      }
      return dtos;
    });
  }
}
