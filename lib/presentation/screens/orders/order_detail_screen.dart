import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_type.dart';
import '../../../domain/enums/payment_method.dart';
import '../../../core/logger/app_logger.dart';
import 'orders_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    appLogger.i('[OrderDetailScreen] build — order: ${order.id}');

    final orderType = OrderType.fromString(order.orderType);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('#${order.id.substring(0, 8).toUpperCase()}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              appLogger.i('[OrderDetailScreen] back pressed');
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/orders');
              }
            },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OrderCard(order: order, onTap: () {}),
          AppSpacing.gapH16,
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
          Container(
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
                Text(
                  'الأصناف',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.gapH12,
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
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${item.subtotal.toStringAsFixed(0)} ج',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          if (item.selectedOptions.isNotEmpty) ...[
                            AppSpacing.gapH4,
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
                                        BorderRadius.circular(AppRadius.xl),
                                  ),
                                  child: Text(
                                    option.name,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    )),
                const Divider(height: 28),
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
                          fontWeight: FontWeight.w700,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${order.totalAmount.toStringAsFixed(0)} جنيه',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
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
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapH12,
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
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
