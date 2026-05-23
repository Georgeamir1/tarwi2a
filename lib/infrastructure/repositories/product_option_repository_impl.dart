import 'package:dartz/dartz.dart';
import '../../../domain/entities/product_option.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/product_option_repository.dart';
import '../datasources/remote/product_option_remote_datasource.dart';

class ProductOptionRepositoryImpl implements ProductOptionRepository {
  final ProductOptionRemoteDataSource _remoteDataSource;

  ProductOptionRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ProductOption>>> getByProductId(
      String productId) async {
    try {
      final dtos = await _remoteDataSource.getByProductId(productId);
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> upsert(Map<String, dynamic> data,
      {String? id}) async {
    try {
      await _remoteDataSource.upsert(data, id: id);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await _remoteDataSource.delete(id);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }
}
