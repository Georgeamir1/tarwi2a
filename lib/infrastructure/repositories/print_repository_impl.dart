import 'package:dartz/dartz.dart';
import '../../domain/entities/order.dart' as entity;
import '../../domain/failures/failure.dart';
import '../../domain/repositories/print_repository.dart';
import '../../core/services/thermal_printer_service.dart';
import '../../core/logger/app_logger.dart';

class PrintRepositoryImpl implements PrintRepository {
  final ThermalPrinterService _printerService;

  PrintRepositoryImpl(this._printerService);

  @override
  Future<Either<Failure, bool>> printOrder(entity.Order order) async {
    try {
      final result = await _printerService.printOrder(order);
      return right(result);
    } catch (e) {
      appLogger.e('[PrintRepositoryImpl] print error', error: e);
      return left(Failure.unexpected(message: 'فشل في الطباعة: $e'));
    }
  }
}
