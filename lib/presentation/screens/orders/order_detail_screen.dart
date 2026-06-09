import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_type.dart';
import '../../../domain/enums/order_status.dart';
import '../../../core/logger/app_logger.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/orders/customer_orders_cubit.dart';
import '../../extensions/payment_method_x.dart';
import '../../widgets/app_top_bar.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final Order? initialOrder;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    _ensureLoaded();
  }

  void _ensureLoaded() {
    final authState = context.read<AuthCubit>().state;
    final customerId = authState is Authenticated ? authState.profile.id : '';
    if (customerId.isNotEmpty) {
      context.read<CustomerOrdersCubit>().loadOrders(customerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    appLogger.i('[OrderDetailScreen] build — orderId: ${widget.orderId}');

    return BlocBuilder<CustomerOrdersCubit, CustomerOrdersState>(
      builder: (context, state) {
        Order? order = widget.initialOrder;
        if (state.status == CustomerOrdersStatus.loaded) {
          try {
            order = state.orders.firstWhere((o) => o.id == widget.orderId);
          } catch (_) {}
        }

        if (order == null) {
          if (state.status == CustomerOrdersStatus.loading) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: const AppTopBar(
              title: 'تفاصيل الطلب',
              variant: TopBarVariant.withBack,
            ),
            body: Center(
              child: Text(
                state.status == CustomerOrdersStatus.error
                    ? 'خطأ في تحميل الطلب: ${state.failure?.message}'
                    : 'الطلب غير موجود',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        final orderType = OrderType.fromString(order.orderType);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppTopBar(
            title: '#${order.id.substring(0, 8).toUpperCase()}',
            variant: TopBarVariant.withBack,
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 120, // space for sticky bottom bar
                ),
                children: [
                  // Status Badge & Stepper Header
                  _HorizontalStepper(status: order.status),
                  AppSpacing.gapH16,

                  // Info Card
                  _InfoCard(
                    title: 'بيانات الطلب',
                    children: [
                      _InfoRow('الاسم', order.customerName),
                      _InfoRow('الهاتف', order.customerPhone),
                      if (order.customerAddress != null &&
                          order.customerAddress!.isNotEmpty)
                        _InfoRow('العنوان', order.customerAddress!),
                      _InfoRow('نوع الطلب', orderType.arabicLabel),
                      _InfoRow('طريقة الدفع', order.paymentMethod.arabicLabel),
                      _InfoRow(
                        'حالة الدفع',
                        order.paymentStatus == 'paid' ? 'تم الدفع' : 'معلق',
                        valueColor: order.paymentStatus == 'paid'
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      _InfoRow(
                        'التاريخ',
                        DateFormat('dd/MM/yyyy - hh:mm a')
                            .format(order.createdAt.toLocal()),
                      ),
                      if (order.scheduledFor != null)
                        _InfoRow(
                          'موعد التوصيل المجدول',
                          DateFormat('dd/MM/yyyy - hh:mm a')
                              .format(order.scheduledFor!.toLocal()),
                        ),
                      if (order.notes != null && order.notes!.isNotEmpty)
                        _InfoRow('ملاحظات', order.notes!),
                    ],
                  ),
                  AppSpacing.gapH16,

                  // Items Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 0.8),
                      boxShadow: const [AppShadows.card],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الأصناف المطلوبة',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Divider(height: 24, thickness: 0.5),
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.productName} × ${item.quantity}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${item.subtotal.toStringAsFixed(0)} ج',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item.selectedOptions.isNotEmpty) ...[
                                    AppSpacing.gapH6,
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: item.selectedOptions.map((option) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius:
                                                BorderRadius.circular(AppRadius.full),
                                          ),
                                          child: Text(
                                            option.name,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            )),
                        const Divider(height: 28, thickness: 0.5),
                        if (order.discountAmount > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الخصم',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '-${order.discountAmount.toStringAsFixed(0)} ج',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapH8,
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الإجمالي',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              '${order.totalAmount.toStringAsFixed(0)} جنيه',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Sticky Bottom Actions
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                    border: Border.all(color: AppColors.outlineVariant, width: 0.8),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowSubtle,
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: order.status == OrderStatus.cancelled
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cancel, color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'تم إلغاء هذا الطلب ولا يمكن تتبعه',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : order.status == OrderStatus.delivered
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/orders/${order!.id}/rate');
                                },
                                icon: const Icon(Icons.star_outline_rounded),
                                label: const Text('قيم الطلب الآن'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.tertiary,
                                  foregroundColor: AppColors.onTertiary,
                                  minimumSize: const Size(double.infinity, 52),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/orders/${order!.id}/track', extra: order);
                                },
                                icon: const Icon(Icons.navigation_outlined),
                                label: const Text('تتبع حالة الطلب'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  minimumSize: const Size(double.infinity, 52),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                  ),
                                ),
                              ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HorizontalStepper extends StatelessWidget {
  final OrderStatus status;
  const _HorizontalStepper({required this.status});

  int get _activeIndex {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'label': 'تم الطلب', 'icon': Icons.receipt_long_rounded},
      {'label': 'تأكيد', 'icon': Icons.thumb_up_alt_outlined},
      {'label': 'التحضير', 'icon': Icons.restaurant_rounded},
      {'label': 'جاهز', 'icon': Icons.shopping_bag_outlined},
      {'label': 'توصيل', 'icon': Icons.check_circle_outline_rounded},
    ];

    final activeIndex = _activeIndex;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant, width: 0.8),
        boxShadow: const [AppShadows.card],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isActive = index <= activeIndex;
          final isCurrent = index == activeIndex;
          final isCancelled = status == OrderStatus.cancelled;
          final color = isCancelled
              ? AppColors.error
              : (isActive ? AppColors.primary : AppColors.textMuted);
          final bg = isCancelled
              ? AppColors.error.withValues(alpha: 0.1)
              : (isActive
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceContainerLow);

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    // Line before
                    Expanded(
                      child: index == 0
                          ? const SizedBox.shrink()
                          : Container(
                              height: 2,
                              color: index <= activeIndex && !isCancelled
                                  ? AppColors.primary
                                  : AppColors.outlineVariant,
                            ),
                    ),
                    // Circle icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: bg,
                        shape: BoxShape.circle,
                        border: isCurrent || isCancelled
                            ? Border.all(color: color, width: 1.5)
                            : Border.all(color: Colors.transparent),
                      ),
                      child: Icon(
                        isCancelled ? Icons.cancel_outlined : (steps[index]['icon'] as IconData),
                        size: 16,
                        color: color,
                      ),
                    ),
                    // Line after
                    Expanded(
                      child: index == steps.length - 1
                          ? const SizedBox.shrink()
                          : Container(
                              height: 2,
                              color: index < activeIndex && !isCancelled
                                  ? AppColors.primary
                                  : AppColors.outlineVariant,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isCancelled && isCurrent ? 'ملغي' : (steps[index]['label'] as String),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: isActive || isCancelled ? FontWeight.w800 : FontWeight.w600,
                    color: isActive || (isCancelled && isCurrent) ? AppColors.onSurface : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant, width: 0.8),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const Divider(height: 24, thickness: 0.5),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.onSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
