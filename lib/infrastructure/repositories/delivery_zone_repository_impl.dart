import 'package:dartz/dartz.dart';
import '../../../domain/entities/delivery_zone.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/delivery_zone_repository.dart';
import '../datasources/remote/delivery_zone_remote_datasource.dart';

class DeliveryZoneRepositoryImpl implements DeliveryZoneRepository {
  final DeliveryZoneRemoteDataSource _remoteDataSource;

  DeliveryZoneRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<DeliveryZone>>> getAll() async {
    try {
      final dtos = await _remoteDataSource.getAll();
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
  Future<Either<Failure, void>> toggleActive(String id, bool isActive) async {
    try {
      await _remoteDataSource.toggleActive(id, isActive);
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

  @override
  Stream<List<DeliveryZone>> watchDeliveryZones() {
    return _remoteDataSource.watchDeliveryZones().map(
          (dtos) => dtos.map((dto) => dto.toDomain()).toList(),
        );
  }
}
