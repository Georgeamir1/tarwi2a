import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_orders_cubit.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_status.dart';
import '../../extensions/order_status_x.dart';
import '../../extensions/payment_method_x.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _filterStatus = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  static const _statuses = [
    ('all', 'الكل'),
    ('pending', 'جديدة'),
    ('confirmed', 'مؤكدة'),
    ('preparing', 'تحضير'),
    ('ready', 'جاهزة'),
    ('delivered', 'تم التوصيل'),
    ('cancelled', 'ملغية'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Order> _filterOrders(List<Order> orders) {
    var filtered = _filterStatus == 'all'
        ? orders
        : orders.where((o) => o.status.value == _filterStatus).toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((o) {
        return o.customerName.toLowerCase().contains(query) ||
            o.customerPhone.contains(query) ||
            o.id.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('إدارة الطلبات'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'بحث بالاسم أو الهاتف أو رقم الطلب...',
                      hintStyle: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                AppSpacing.gapH8,
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _statuses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final (value, label) = _statuses[index];
                      final isSelected = _filterStatus == value;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _filterStatus = value);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: AppRadius.xlAll,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.surface
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                AppSpacing.gapH8,
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<AdminOrdersCubit>().loadOrders();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: state.status == AdminOrdersStatus.loading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary))
                        : state.status == AdminOrdersStatus.error
                            ? Center(
                                child: Text(
                                    'خطأ: ${state.failure?.message ?? ''}'))
                            : () {
                                final filtered = _filterOrders(state.orders);
                                if (filtered.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.search_off,
                                            size: 48, color: AppColors.grey300),
                                        AppSpacing.gapH12,
                                        Text(
                                          _searchQuery.isNotEmpty
                                              ? 'مفيش نتائج للبحث'
                                              : 'مفيش طلبات',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) =>
                                      AppSpacing.gapH10,
                                  itemBuilder: (context, index) =>
                                      _AdminOrderCard(
                                    order: filtered[index],
                                    onTap: () {
                                      context.push(
                                        '/admin/orders/${filtered[index].id}',
                                        extra: filtered[index],
                                      );
                                    },
                                  ),
                                );
                              }(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _AdminOrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = order.status == OrderStatus.pending;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isPending
                ? AppColors.warning.withValues(alpha: 0.5)
                : AppColors.divider,
            width: isPending ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowSubtle,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isPending)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.warning, shape: BoxShape.circle),
                    margin: const EdgeInsets.only(left: 6),
                  ),
                Expanded(
                  child: Text(
                    order.customerName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.status.color.withValues(alpha: 0.12),
                    borderRadius: AppRadius.xlAll,
                  ),
                  child: Text(
                    order.status.arabicLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: order.status.color,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapH6,
            Row(
              children: [
                const Icon(Icons.phone_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  order.customerPhone,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('hh:mm a').format(order.createdAt.toLocal()),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            AppSpacing.gapH8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payment,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      order.paymentMethod.arabicLabel,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Text(
                  '${order.totalAmount.toStringAsFixed(0)} جنيه',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
