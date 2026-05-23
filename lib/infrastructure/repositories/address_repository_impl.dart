import 'package:dartz/dartz.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/address_repository.dart';
import '../datasources/remote/address_remote_data_source.dart';
import '../../core/logger/app_logger.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource _remoteDataSource;

  AddressRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Address>>> getAddresses(String userId) async {
    try {
      final dtos = await _remoteDataSource.getAddresses(userId);
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e, s) {
      appLogger.e('[AddressRepo] getAddresses failed', error: e, stackTrace: s);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Address>> createAddress(Map<String, dynamic> data) async {
    try {
      final dto = await _remoteDataSource.createAddress(data);
      return right(dto.toDomain());
    } catch (e, s) {
      appLogger.e('[AddressRepo] createAddress failed', error: e, stackTrace: s);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Address>> updateAddress(
      String id, Map<String, dynamic> data) async {
    try {
      final dto = await _remoteDataSource.updateAddress(id, data);
      return right(dto.toDomain());
    } catch (e, s) {
      appLogger.e('[AddressRepo] updateAddress failed', error: e, stackTrace: s);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String id) async {
    try {
      await _remoteDataSource.deleteAddress(id);
      return right<Failure, void>(null);
    } catch (e, s) {
      appLogger.e('[AddressRepo] deleteAddress failed', error: e, stackTrace: s);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setDefault(String id, String userId) async {
    try {
      await _remoteDataSource.setDefault(id, userId);
      return right<Failure, void>(null);
    } catch (e, s) {
      appLogger.e('[AddressRepo] setDefault failed', error: e, stackTrace: s);
      return left(Failure.unexpected(message: e.toString()));
    }
  }
}
