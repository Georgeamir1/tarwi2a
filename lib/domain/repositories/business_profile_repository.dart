import 'package:dartz/dartz.dart';
import '../entities/business_profile.dart';
import '../failures/failure.dart';

abstract class BusinessProfileRepository {
  Future<Either<Failure, BusinessProfile>> get();
  Future<Either<Failure, void>> update(Map<String, dynamic> data);
  Future<Either<Failure, void>> toggleAcceptOrders(bool accept);
  Future<Either<Failure, void>> toggleBusyMode(
      {required bool isBusy, String? message});
  Stream<BusinessProfile?> watchProfile();
}
