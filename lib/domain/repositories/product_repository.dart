import 'package:dartz/dartz.dart';
import '../entities/product.dart';
import '../failures/failure.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({String? categoryId});
  Future<Either<Failure, List<Product>>> getAllAdmin();
  Future<Either<Failure, void>> upsertProduct(
    Map<String, dynamic> data, {
    String? id,
  });
  Future<Either<Failure, void>> toggleAvailable(String id, bool isAvailable);
  Stream<List<Product>> watchProducts({String? categoryId});
}
