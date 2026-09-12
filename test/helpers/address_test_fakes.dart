import 'package:dartz/dartz.dart';
import 'package:tarwi2a/domain/entities/address.dart';
import 'package:tarwi2a/domain/entities/delivery_zone.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import 'package:tarwi2a/domain/repositories/address_repository.dart';
import 'package:tarwi2a/domain/repositories/delivery_zone_repository.dart';

class FakeAddressRepository implements AddressRepository {
  Either<Failure, List<Address>> getAddressesResult;
  Either<Failure, Address> createAddressResult;
  Either<Failure, Address> updateAddressResult;
  Either<Failure, void> deleteAddressResult;
  Either<Failure, void> setDefaultResult;

  int getAddressesCallCount = 0;
  int createAddressCallCount = 0;
  int updateAddressCallCount = 0;
  Map<String, dynamic>? lastCreatedData;
  Map<String, dynamic>? lastUpdatedData;

  FakeAddressRepository({
    Either<Failure, List<Address>>? getAddressesResult,
    Either<Failure, Address>? createAddressResult,
    Either<Failure, Address>? updateAddressResult,
    Either<Failure, void>? deleteAddressResult,
    Either<Failure, void>? setDefaultResult,
  })  : getAddressesResult = getAddressesResult ?? right([]),
        createAddressResult = createAddressResult ??
            left(const Failure.server(message: 'Not configured')),
        updateAddressResult = updateAddressResult ??
            left(const Failure.server(message: 'Not configured')),
        deleteAddressResult = deleteAddressResult ?? right(null),
        setDefaultResult = setDefaultResult ?? right(null);

  @override
  Future<Either<Failure, List<Address>>> getAddresses(String userId) async {
    getAddressesCallCount++;
    return getAddressesResult;
  }

  @override
  Future<Either<Failure, Address>> createAddress(
      Map<String, dynamic> data) async {
    createAddressCallCount++;
    lastCreatedData = Map<String, dynamic>.from(data);
    return createAddressResult;
  }

  @override
  Future<Either<Failure, Address>> updateAddress(
      String id, Map<String, dynamic> data) async {
    updateAddressCallCount++;
    lastUpdatedData = Map<String, dynamic>.from(data);
    return updateAddressResult;
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String id) async {
    return deleteAddressResult;
  }

  @override
  Future<Either<Failure, void>> setDefault(String id, String userId) async {
    return setDefaultResult;
  }
}

class FakeDeliveryZoneRepository implements DeliveryZoneRepository {
  Either<Failure, List<DeliveryZone>> getAllResult;

  FakeDeliveryZoneRepository({
    Either<Failure, List<DeliveryZone>>? getAllResult,
  }) : getAllResult = getAllResult ?? right([]);

  @override
  Future<Either<Failure, List<DeliveryZone>>> getAll() async {
    return getAllResult;
  }

  @override
  Future<Either<Failure, void>> upsert(Map<String, dynamic> data,
      {String? id}) async {
    return right(null);
  }

  @override
  Future<Either<Failure, void>> toggleActive(String id, bool isActive) async {
    return right(null);
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    return right(null);
  }

  @override
  Stream<List<DeliveryZone>> watchDeliveryZones() {
    return const Stream.empty();
  }
}
