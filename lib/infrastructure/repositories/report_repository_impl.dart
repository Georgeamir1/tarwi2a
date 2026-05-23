import 'package:dartz/dartz.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/report_repository.dart';
import '../datasources/remote/report_remote_datasource.dart';
import '../dtos/order_dto.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remoteDataSource;

  ReportRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ReportData>> getReports({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final orders =
          await _remoteDataSource.getOrdersWithItems(startDate, endDate);
      final totalCustomers = await _remoteDataSource.getTotalCustomers();

      final confirmedOrders =
          orders.where((o) => o.status != 'cancelled').toList();
      final cancelledOrders =
          orders.where((o) => o.status == 'cancelled').toList();

      final double totalRevenue = confirmedOrders.fold(
        0,
        (sum, o) => sum + o.totalAmount,
      );
      final double discountTotal = confirmedOrders.fold(
        0,
        (sum, o) => sum + (o.discountAmount ?? 0),
      );
      final int totalOrders = confirmedOrders.length;
      final double averageOrder =
          totalOrders > 0 ? totalRevenue / totalOrders : 0;

      final revenueByDay = _computeRevenueByDay(confirmedOrders);

      final topProducts = _computeTopProducts(orders);

      return right(ReportData(
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        averageOrder: averageOrder,
        cancelledOrders: cancelledOrders.length,
        revenueByDay: revenueByDay,
        topProducts: topProducts,
        totalCustomers: totalCustomers,
        discountTotal: discountTotal,
      ));
    } catch (e) {
      return left(Failure.unexpected(message: e.toString()));
    }
  }

  List<DailyRevenue> _computeRevenueByDay(List<OrderDTO> orders) {
    final Map<String, DailyRevenue> dayMap = {};

    for (final order in orders) {
      final dayKey = _dateKey(order.createdAt);
      final current = dayMap[dayKey];
      if (current != null) {
        dayMap[dayKey] = DailyRevenue(
          date: order.createdAt,
          revenue: current.revenue + order.totalAmount,
          orderCount: current.orderCount + 1,
        );
      } else {
        dayMap[dayKey] = DailyRevenue(
          date: order.createdAt,
          revenue: order.totalAmount,
          orderCount: 1,
        );
      }
    }

    final entries = dayMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => e.value).toList();
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  List<TopProduct> _computeTopProducts(List<OrderDTO> orders) {
    final Map<String, Map<String, dynamic>> productStats = {};

    for (final order in orders) {
      final items = order.items;
      if (items == null) continue;
      for (final item in items) {
        final pid = item.productId ?? item.productName;
        final qty = item.quantity;
        final price = item.productPrice;

        final current = productStats[pid];
        if (current != null) {
          current['quantity'] = (current['quantity'] as int) + qty;
          current['revenue'] = (current['revenue'] as double) + (price * qty);
        } else {
          productStats[pid] = {
            'productId': item.productId ?? pid,
            'name': item.productName,
            'quantity': qty,
            'revenue': price * qty,
          };
        }
      }
    }

    final sorted = productStats.entries.toList()
      ..sort((a, b) => (b.value['revenue'] as double)
          .compareTo(a.value['revenue'] as double));

    return sorted
        .take(5)
        .map((e) => TopProduct(
              productId: e.value['productId'] as String,
              name: e.value['name'] as String,
              quantity: e.value['quantity'] as int,
              revenue: (e.value['revenue'] as double),
            ))
        .toList();
  }
}
