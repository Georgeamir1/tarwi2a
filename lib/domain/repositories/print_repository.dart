import 'package:dartz/dartz.dart';
import '../entities/order.dart' as entity;
import '../failures/failure.dart';

abstract class PrintRepository {
  Future<Either<Failure, bool>> printOrder(entity.Order order);
}
