import 'package:dartz/dartz.dart';
import '../entities/delivery_zone.dart';
import '../failures/failure.dart';

abstract class DeliveryZoneRepository {
  Future<Either<Failure, List<DeliveryZone>>> getAll();
  Future<Either<Failure, void>> upsert(Map<String, dynamic> data, {String? id});
  Future<Either<Failure, void>> toggleActive(String id, bool isActive);
  Future<Either<Failure, void>> delete(String id);
  Stream<List<DeliveryZone>> watchDeliveryZones();
}
