import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dtos/product_option_dto.dart';

class ProductOptionRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ProductOptionDTO>> getByProductId(String productId) async {
    final data = await _client
        .from('product_options')
        .select()
        .eq('product_id', productId)
        .order('sort_order');
    return (data as List).map((e) => ProductOptionDTO.fromJson(e)).toList();
  }

  Future<void> upsert(Map<String, dynamic> data, {String? id}) async {
    if (id != null) {
      await _client.from('product_options').update(data).eq('id', id);
    } else {
      await _client.from('product_options').insert(data);
    }
  }

  Future<void> delete(String id) async {
    await _client.from('product_options').delete().eq('id', id);
  }
}
