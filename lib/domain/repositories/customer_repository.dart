import 'package:dartz/dartz.dart' hide Order;
import '../entities/customer.dart';
import '../entities/order.dart';
import '../failures/failure.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getAll();
  Future<Either<Failure, List<Customer>>> search(String query);
  Future<Either<Failure, Customer>> getById(String id);
  Future<Either<Failure, List<Order>>> getCustomerOrders(String customerId);
  Stream<List<Customer>> watchCustomers();
}
