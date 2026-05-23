import 'package:dartz/dartz.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/product_repository.dart';
import '../datasources/remote/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Product>>> getProducts(
      {String? categoryId}) async {
    try {
      final dtos = await _remoteDataSource.getProducts(categoryId: categoryId);
      return right(dtos.map((dto) => dto.toDomain()).toList());
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
  Stream<List<Product>> watchProducts({String? categoryId}) {
    return _remoteDataSource.watchProducts(categoryId: categoryId).map(
          (dtos) => dtos.map((dto) => dto.toDomain()).toList(),
        );
  }
}
