import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../core/di/injection_container.dart';
import '../../extensions/order_status_x.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';

class AdminCustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const AdminCustomerDetailScreen({super.key, required this.customer});

  @override
  State<AdminCustomerDetailScreen> createState() =>
      _AdminCustomerDetailScreenState();
}

class _AdminCustomerDetailScreenState extends State<AdminCustomerDetailScreen> {
  List<Order> _orders = [];
  bool _loadingOrders = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final result = await sl<CustomerRepository>()
        .getCustomerOrders(widget.customer.id);
    result.fold(
      (_) {
        if (mounted) setState(() => _loadingOrders = false);
      },
      (orders) {
        if (mounted) {
          setState(() {
            _orders = orders;
            _loadingOrders = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;
    return Scaffold(
      appBar: const AppTopBar(
        title: 'تفاصيل العميل',
        variant: TopBarVariant.withBack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(c),
            AppSpacing.gapH16,
            _buildStatsCard(c),
            AppSpacing.gapH16,
            Text('سجل الطلبات',
                style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapH8,
            _buildOrdersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(Customer c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  if (c.phone != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16,
                            color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(c.phone!,
                            style: const TextStyle(
                                color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'انضم ${_formatDate(c.createdAt)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(Customer c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statColumn('إجمالي الطلبات', '${c.totalOrders}', Icons.receipt_long),
            _statColumn('إجمالي الإنفاق', '${c.totalSpent.toStringAsFixed(2)} ج.م', Icons.attach_money),
            _statColumn('آخر طلب', c.lastOrderAt != null ? _formatDate(c.lastOrderAt!) : '-', Icons.schedule),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildOrdersList() {
    if (_loadingOrders) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ));
    }
    if (_orders.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'لا توجد طلبات',
        subtitle: 'لم يقم العميل بأي طلب بعد',
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _orders.length,
      itemBuilder: (_, index) {
        final order = _orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: order.status.color.withValues(alpha: 0.12),
              child: Icon(Icons.receipt, size: 18, color: order.status.color),
            ),
            title: Text('طلب #${order.id.substring(0, 8)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              order.status.arabicLabel,
              style: TextStyle(
                  fontSize: 12, color: order.status.color),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${order.totalAmount.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  _formatDate(order.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
