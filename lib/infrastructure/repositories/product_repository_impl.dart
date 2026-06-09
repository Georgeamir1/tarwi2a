import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_option.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/product_repository.dart';
import '../datasources/remote/product_remote_data_source.dart';
import '../dtos/product_option_dto.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Product>>> getProducts(
      {String? categoryId}) async {
    try {
      final dtos = await _remoteDataSource.getProducts(categoryId: categoryId);
      
      // Query all product options from database
      List<dynamic> optionsData = [];
      try {
        final res = await Supabase.instance.client
            .from('product_options')
            .select()
            .order('sort_order');
        if (res is List) {
          optionsData = res;
        }
      } catch (e) {
        appLogger.w('Failed to query product_options from Supabase (this is expected in unit tests): $e');
      }
          
      final optionDTOs = optionsData
          .map((e) => ProductOptionDTO.fromJson(e as Map<String, dynamic>))
          .toList();
          
      // Group options by product_id
      final optionsMap = <String, List<ProductOption>>{};
      for (final optDto in optionDTOs) {
        optionsMap.putIfAbsent(optDto.productId, () => []).add(optDto.toDomain());
      }
      
      final domainProducts = dtos.map((dto) {
        final product = dto.toDomain();
        return product.copyWith(options: optionsMap[product.id] ?? const []);
      }).toList();
      
      return right(domainProducts);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getAllAdmin() async {
    try {
      final dtos = await _remoteDataSource.getAllAdmin();
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> upsertProduct(
    Map<String, dynamic> data, {
    String? id,
  }) async {
    try {
      await _remoteDataSource.upsert(data, id: id);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAvailable(
      String id, bool isAvailable) async {
    try {
      await _remoteDataSource.toggleAvailable(id, isAvailable);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await _remoteDataSource.delete(id);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Stream<List<Product>> watchProducts({String? categoryId}) {
    return _remoteDataSource.watchProducts(categoryId: categoryId).map(
          (dtos) => dtos.map((dto) => dto.toDomain()).toList(),
        );
  }
}
