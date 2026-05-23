import 'package:dartz/dartz.dart';
import '../failures/failure.dart';

class ReportData {
  final double totalRevenue;
  final int totalOrders;
  final double averageOrder;
  final int cancelledOrders;
  final List<DailyRevenue> revenueByDay;
  final List<TopProduct> topProducts;
  final int totalCustomers;
  final double discountTotal;

  const ReportData({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrder,
    required this.cancelledOrders,
    required this.revenueByDay,
    required this.topProducts,
    required this.totalCustomers,
    required this.discountTotal,
  });
}

class DailyRevenue {
  final DateTime date;
  final double revenue;
  final int orderCount;

  const DailyRevenue({
    required this.date,
    required this.revenue,
    required this.orderCount,
  });
}

class TopProduct {
  final String productId;
  final String name;
  final int quantity;
  final double revenue;

  const TopProduct({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.revenue,
  });
}

abstract class ReportRepository {
  Future<Either<Failure, ReportData>> getReports({
    required DateTime startDate,
    required DateTime endDate,
  });
}
