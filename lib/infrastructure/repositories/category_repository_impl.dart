import 'package:dartz/dartz.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/category_repository.dart';
import '../datasources/remote/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final dtos = await _remoteDataSource.getCategories();
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getAllAdmin() async {
    try {
      final dtos = await _remoteDataSource.getAllAdmin();
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> upsertCategory(
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
  Future<Either<Failure, void>> toggleActive(String id, bool isActive) async {
    try {
      await _remoteDataSource.toggleActive(id, isActive);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _remoteDataSource.deleteCategory(id);
      return right<Failure, void>(null);
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _remoteDataSource.watchCategories().map(
          (dtos) => dtos.map((dto) => dto.toDomain()).toList(),
        );
  }
}
