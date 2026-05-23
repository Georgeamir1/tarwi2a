import 'package:dartz/dartz.dart';
import '../entities/category.dart';
import '../failures/failure.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<Category>>> getAllAdmin();
  Future<Either<Failure, void>> upsertCategory(
    Map<String, dynamic> data, {
    String? id,
  });
  Future<Either<Failure, void>> toggleActive(String id, bool isActive);
  Stream<List<Category>> watchCategories();
}
