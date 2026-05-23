import 'package:dartz/dartz.dart';
import '../entities/address.dart';
import '../failures/failure.dart';

abstract class AddressRepository {
  Future<Either<Failure, List<Address>>> getAddresses(String userId);
  Future<Either<Failure, Address>> createAddress(Map<String, dynamic> data);
  Future<Either<Failure, Address>> updateAddress(String id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteAddress(String id);
  Future<Either<Failure, void>> setDefault(String id, String userId);
}
