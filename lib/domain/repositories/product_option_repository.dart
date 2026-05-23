import 'package:dartz/dartz.dart';
import '../entities/product_option.dart';
import '../failures/failure.dart';

abstract class ProductOptionRepository {
  Future<Either<Failure, List<ProductOption>>> getByProductId(String productId);
  Future<Either<Failure, void>> upsert(Map<String, dynamic> data, {String? id});
  Future<Either<Failure, void>> delete(String id);
}
