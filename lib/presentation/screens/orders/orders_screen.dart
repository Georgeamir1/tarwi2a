import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_type.dart';
import '../../extensions/order_status_x.dart';
import '../../../domain/enums/order_status.dart';
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
      body: RefreshIndicator(
        onRefresh: () async {
          _load();
        },
        child: BlocBuilder<CustomerOrdersCubit, CustomerOrdersState>(
          builder: (context, state) {
            switch (state.status) {
              case CustomerOrdersStatus.initial:
              case CustomerOrdersStatus.loading:
                appLogger.i('[OrdersScreen] loading...');
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 140,
                  ),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, __) => const SkeletonListTile(),
                );
              case CustomerOrdersStatus.loaded:
                appLogger
                    .i('[OrdersScreen] loaded ${state.orders.length} orders');
                return state.orders.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: EmptyState(
                              icon: Icons.receipt_long_outlined,
                              title: 'مفيش طلبات لحد دلوقتي',
                              actionLabel: 'اطلب دلوقتي',
                              onAction: () {
                                appLogger.i('[OrdersScreen] navigate to /home');
                                context.go('/home');
                              },
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: 140,
                        ),
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
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Text(
                          'حصل خطأ: ${state.failure?.message ?? ''}\nاسحب للأسفل لإعادة المحاولة',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                    ),
                  ],
                );
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  double _scale = 1.0;

  Color get _statusColor => widget.order.status.color;

  IconData get _statusIcon {
    switch (widget.order.status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing:
        return Icons.restaurant_rounded;
      case OrderStatus.ready:
        return Icons.shopping_bag_outlined;
      case OrderStatus.delivered:
        return Icons.task_alt_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderType = OrderType.fromString(widget.order.orderType);
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOutCubic,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.outlineVariant,
              width: 1,
            ),
            boxShadow: const [
              AppShadows.card,
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${widget.order.id.substring(0, 8).toUpperCase()}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: AppRadius.xlAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon,
                          size: 13,
                          color: _statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.order.status.arabicLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.gapH8,
              Row(
                children: [
                  Icon(orderType.icon,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    orderType.arabicLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '•',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time_rounded,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy - hh:mm a')
                        .format(widget.order.createdAt.toLocal()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              if (widget.order.items.isNotEmpty) ...[
                AppSpacing.gapH10,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.restaurant_menu_rounded,
                          size: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.order.items
                            .map((e) =>
                                '${e.productName} × ${e.quantity}')
                            .join('، '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
          ],
              AppSpacing.gapH12,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.order.items.length} أصناف',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${widget.order.totalAmount.toStringAsFixed(0)} جنيه',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (widget.order.status != OrderStatus.cancelled) ...[
                const Divider(height: 24, thickness: 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.order.status == OrderStatus.delivered)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push('/orders/${widget.order.id}/rate');
                        },
                        icon: const Icon(Icons.star_outline_rounded, size: 16),
                        label: const Text('قيم الطلب'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          backgroundColor: AppColors.tertiary.withValues(alpha: 0.15),
                          foregroundColor: AppColors.tertiary,
                          elevation: 0,
                          textStyle: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push('/orders/${widget.order.id}/track', extra: widget.order);
                        },
                        icon: const Icon(Icons.navigation_outlined, size: 14),
                        label: const Text('تتبع الطلب'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          textStyle: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }}
