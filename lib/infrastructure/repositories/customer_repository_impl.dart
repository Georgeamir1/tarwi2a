import 'package:dartz/dartz.dart' hide Order;
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../domain/repositories/order_repository.dart';
import '../datasources/remote/customer_remote_datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource _remoteDataSource;
  final OrderRepository _orderRepository;

  CustomerRepositoryImpl(this._remoteDataSource, this._orderRepository);

  @override
  Future<Either<Failure, List<Customer>>> getAll() async {
    try {
      final dtos = await _remoteDataSource.getAll();
      final ids = dtos.map((d) => d.id).toList();
      final stats = await _remoteDataSource.getOrderStats(ids);

      final customers = dtos.map((dto) {
        final s = stats[dto.id];
        return Customer(
          id: dto.id,
          name: dto.name,
          phone: dto.phone,
          role: dto.toDomain().role,
          totalOrders: s?['count'] as int? ?? 0,
          totalSpent: (s?['spent'] as num?)?.toDouble() ?? 0.0,
          lastOrderAt: s?['last_order_at'] as DateTime?,
          createdAt: dto.createdAt ?? DateTime.now(),
        );
      }).toList();

      return right(customers);
    } catch (e, s) {
      appLogger.e('Failed to load customers', error: e, stackTrace: s);
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> search(String query) async {
    try {
      final dtos = await _remoteDataSource.search(query);
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> getById(String id) async {
    try {
      final dto = await _remoteDataSource.getById(id);
      if (dto == null) {
        return left(const Failure.unexpected(message: 'العميل غير موجود'));
      }
      return right(dto.toDomain());
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getCustomerOrders(
      String customerId) async {
    return _orderRepository.getCustomerOrders(customerId);
  }

  @override
  Stream<List<Customer>> watchCustomers() {
    return _remoteDataSource.watchCustomers().map(
          (dtos) => dtos.map((dto) => dto.toDomain()).toList(),
        );
  }
}
