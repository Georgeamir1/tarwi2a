import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_status.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/orders/customer_orders_cubit.dart';
import '../../../core/logger/app_logger.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  final String? expandOrderId;
  const OrdersScreen({super.key, this.expandOrderId});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String? _expandedOrderId;

  @override
  void initState() {
    super.initState();
    if (widget.expandOrderId != null) {
      _expandedOrderId = widget.expandOrderId;
    }
    _load();
  }

  void _load() {
    final authState = context.read<AuthCubit>().state;
    final customerId = authState is Authenticated ? authState.profile.id : '';
    if (customerId.isNotEmpty) {
      sl<CustomerOrdersCubit>().loadOrders(customerId);
    }
  }

  void _toggleExpand(String orderId) {
    setState(() {
      _expandedOrderId = _expandedOrderId == orderId ? null : orderId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor:
                  isDark ? AppColors.darkSurface : AppColors.surface,
              title: Text(
                'طلباتي',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color:
                      isDark ? AppColors.darkTextPrimary : AppColors.onSurface,
                ),
              ),
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
            SliverToBoxAdapter(
              child: BlocBuilder<CustomerOrdersCubit, CustomerOrdersState>(
                builder: (context, state) {
                  switch (state.status) {
                    case CustomerOrdersStatus.initial:
                    case CustomerOrdersStatus.loading:
                      appLogger.i('[OrdersScreen] loading...');
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                        child: Column(
                          children: List.generate(
                            4,
                            (i) => const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: SkeletonListTile(),
                            ),
                          ),
                        ),
                      );

                    case CustomerOrdersStatus.loaded:
                      appLogger.i(
                          '[OrdersScreen] loaded ${state.orders.length} orders');
                      if (state.orders.isEmpty) {
                        return SizedBox(
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
                        );
                      }

                      final activeOrders = state.orders
                          .where((o) =>
                              o.status == OrderStatus.pending ||
                              o.status == OrderStatus.confirmed ||
                              o.status == OrderStatus.preparing ||
                              o.status == OrderStatus.ready)
                          .toList();

                      final pastOrders = state.orders
                          .where((o) =>
                              o.status == OrderStatus.delivered ||
                              o.status == OrderStatus.cancelled)
                          .toList();

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (activeOrders.isNotEmpty) ...[
                              _SectionLabel(
                                text: 'الطلبات النشطة',
                                color: AppColors.primary,
                                theme: theme,
                              ),
                              ...activeOrders.map((o) => _buildOrderCard(o)),
                            ],
                            if (pastOrders.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _SectionLabel(
                                text: 'الطلبات السابقة',
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.onSurface,
                                theme: theme,
                              ),
                              ...pastOrders.map((o) => _buildOrderCard(o)),
                            ],
                          ],
                        ),
                      );

                    case CustomerOrdersStatus.error:
                      appLogger
                          .e('[OrdersScreen] error: ${state.failure?.message}');
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: Text(
                            'حصل خطأ: ${state.failure?.message ?? ''}\nاسحب للأسفل لإعادة المحاولة',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ),
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order o) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OrderCard(
        order: o,
        expanded: _expandedOrderId == o.id,
        onExpandToggle: () => _toggleExpand(o.id),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  final ThemeData theme;
  const _SectionLabel({
    required this.text,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
