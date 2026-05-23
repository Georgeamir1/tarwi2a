import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_type.dart';
import '../../extensions/order_status_x.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/orders/customer_orders_cubit.dart';
import '../../../core/logger/app_logger.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final authState = context.read<AuthCubit>().state;
    final customerId = authState is Authenticated ? authState.profile.id : '';
    if (customerId.isNotEmpty) {
      sl<CustomerOrdersCubit>().loadOrders(customerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('طلباتي'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              appLogger.i('[OrdersScreen] back pressed');
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
        ),
      ),
      body: BlocBuilder<CustomerOrdersCubit, CustomerOrdersState>(
        builder: (context, state) {
          switch (state.status) {
            case CustomerOrdersStatus.initial:
            case CustomerOrdersStatus.loading:
              appLogger.i('[OrdersScreen] loading...');
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const SkeletonListTile(),
              );
            case CustomerOrdersStatus.loaded:
              appLogger
                  .i('[OrdersScreen] loaded ${state.orders.length} orders');
              return state.orders.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'مفيش طلبات لحد دلوقتي',
                      actionLabel: 'اطلب دلوقتي',
                      onAction: () {
                        appLogger.i('[OrdersScreen] navigate to /home');
                        context.go('/home');
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.orders.length,
                      separatorBuilder: (_, __) => AppSpacing.gapH12,
                      itemBuilder: (context, index) => OrderCard(
                        order: state.orders[index],
                        onTap: () {
                          appLogger.i(
                              '[OrdersScreen] order tapped: ${state.orders[index].id}');
                          context.push('/orders/${state.orders[index].id}',
                              extra: state.orders[index]);
                        },
                      ),
                    );
            case CustomerOrdersStatus.error:
              appLogger.e('[OrdersScreen] error: ${state.failure?.message}');
              return Center(
                  child: Text('حصل خطأ: ${state.failure?.message ?? ''}'));
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  Color get _statusColor => order.status.color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderType = OrderType.fromString(order.orderType);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.id.substring(0, 8).toUpperCase()}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.xlAll,
                  ),
                  child: Text(
                    order.status.arabicLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapH8,
            Row(
              children: [
                Icon(orderType.icon, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  orderType.arabicLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '•',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd/MM/yyyy - hh:mm a')
                      .format(order.createdAt.toLocal()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            AppSpacing.gapH12,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} أصناف',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                ),
                Text(
                  '${order.totalAmount.toStringAsFixed(0)} جنيه',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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
