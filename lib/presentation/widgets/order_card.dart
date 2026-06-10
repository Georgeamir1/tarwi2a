import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_theme.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/enums/order_type.dart';
import '../extensions/order_status_x.dart';
import '../extensions/payment_method_x.dart';
import 'order_status_tracker.dart';
import '../../application/cart/cart_cubit.dart';

class OrderCard extends StatefulWidget {
  final Order order;
  final bool expanded;
  final VoidCallback onExpandToggle;
  final VoidCallback? onTrackTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.expanded,
    required this.onExpandToggle,
    this.onTrackTap,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  Color get _statusColor => widget.order.status.color;

  void _onReorder(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    final cartItems = widget.order.items.map((item) {
      return CartItem(
        productId: item.productId ?? '',
        productNameAr: item.productName,
        productPrice: item.productPrice,
        quantity: item.quantity,
        selectedOptions: item.selectedOptions,
      );
    }).toList();

    cartCubit.addItems(cartItems);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'تمت إضافة عناصر الطلب إلى السلة بنجاح',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'عرض السلة',
          textColor: Colors.amber,
          onPressed: () {
            context.push('/cart');
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final orderType = OrderType.fromString(widget.order.orderType);
    final isCancelled = widget.order.status == OrderStatus.cancelled;
    final isDelivered = widget.order.status == OrderStatus.delivered;
    final activeStep = widget.order.status.progressIndex;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: widget.expanded
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.outlineVariant,
          width: widget.expanded ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.expanded
                ? AppColors.primary.withValues(alpha: 0.06)
                : (isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.03)),
            blurRadius: widget.expanded ? 18 : 10,
            offset: Offset(0, widget.expanded ? 6 : 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ============ HEADER (always visible) ============
              InkWell(
                onTap: widget.onExpandToggle,
                splashColor: AppColors.primary.withValues(alpha: 0.05),
                highlightColor: Colors.transparent,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 4,
                        color: _statusColor,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '#${widget.order.id.substring(0, 8).toUpperCase()}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.onSurface,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _StatusBadge(
                                          status: widget.order.status,
                                          color: _statusColor,
                                          isDark: isDark,
                                          theme: theme),
                                      const SizedBox(width: 6),
                                      AnimatedRotation(
                                        turns: widget.expanded ? 0.5 : 0.0,
                                        duration:
                                            const Duration(milliseconds: 280),
                                        curve: Curves.easeOutCubic,
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.textSecondary,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              AppSpacing.gapH8,
                              Row(
                                children: [
                                  Icon(
                                    orderType.icon,
                                    size: 14,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    orderType.arabicLabel,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '•',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: AppColors.textMuted),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 13,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy - hh:mm a').format(
                                        widget.order.createdAt.toLocal()),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24, thickness: 0.5),

                              // Items preview (collapsed)
                              if (widget.order.items.isNotEmpty) ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...widget.order.items.take(2).map((item) =>
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 6),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? AppColors.darkBackground
                                                      : AppColors
                                                          .surfaceContainerLow,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppRadius.sm),
                                                ),
                                                child: Text(
                                                  '${item.quantity}x',
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  item.productName,
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? AppColors
                                                            .darkTextPrimary
                                                        : AppColors.onSurface,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                '${(item.productPrice * item.quantity).toStringAsFixed(0)} ج',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: isDark
                                                      ? AppColors
                                                          .darkTextSecondary
                                                      : AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    if (widget.order.items.length > 2)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 2, right: 4),
                                        child: Text(
                                          '+ ${widget.order.items.length - 2} أصناف أخرى',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                AppSpacing.gapH12,
                              ],

                              // Footer: total + summary chip
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${widget.order.items.length} أصناف',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${widget.order.totalAmount.toStringAsFixed(0)} جنيه',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  _StatusHint(
                                    status: widget.order.status,
                                    isDark: isDark,
                                    theme: theme,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ============ EXPANDED BODY (details + tracking) ============
              AnimatedSize(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: widget.expanded
                    ? _ExpandedBody(
                        order: widget.order,
                        isDark: isDark,
                        theme: theme,
                        isCancelled: isCancelled,
                        isDelivered: isDelivered,
                        activeStep: activeStep,
                        onReorder: () => _onReorder(context),
                        onRateTap: () =>
                            context.push('/orders/${widget.order.id}/rate'),
                        onTrackTap: widget.onTrackTap,
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final Color color;
  final bool isDark;
  final ThemeData theme;
  const _StatusBadge({
    required this.status,
    required this.color,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.xlAll,
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Icon(status.icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            status.arabicLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusHint extends StatelessWidget {
  final OrderStatus status;
  final bool isDark;
  final ThemeData theme;
  const _StatusHint({
    required this.status,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.expand_more_rounded, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            'التفاصيل',
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedBody extends StatelessWidget {
  final Order order;
  final bool isDark;
  final ThemeData theme;
  final bool isCancelled;
  final bool isDelivered;
  final int activeStep;
  final VoidCallback onReorder;
  final VoidCallback onRateTap;
  final VoidCallback? onTrackTap;

  const _ExpandedBody({
    required this.order,
    required this.isDark,
    required this.theme,
    required this.isCancelled,
    required this.isDelivered,
    required this.activeStep,
    required this.onReorder,
    required this.onRateTap,
    this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    final orderType = OrderType.fromString(order.orderType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, thickness: 0.5),

          // ===== DETAILS section =====
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              'تفاصيل الطلب',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.onSurface,
              ),
            ),
          ),
          _DetailRow('الاسم', order.customerName),
          _DetailRow('الهاتف', order.customerPhone),
          if (order.customerAddress != null &&
              order.customerAddress!.isNotEmpty)
            _DetailRow('العنوان', order.customerAddress!),
          _DetailRow('نوع الطلب', orderType.arabicLabel),
          _DetailRow('طريقة الدفع', order.paymentMethod.arabicLabel),
          _DetailRow(
            'حالة الدفع',
            order.paymentStatus == 'paid' ? 'تم الدفع' : 'معلق',
            valueColor: order.paymentStatus == 'paid'
                ? AppColors.success
                : AppColors.warning,
          ),
          _DetailRow(
            'التاريخ',
            DateFormat('dd/MM/yyyy - hh:mm a')
                .format(order.createdAt.toLocal()),
          ),
          if (order.scheduledFor != null)
            _DetailRow(
              'موعد التوصيل المجدول',
              DateFormat('dd/MM/yyyy - hh:mm a')
                  .format(order.scheduledFor!.toLocal()),
            ),
          if (order.notes != null && order.notes!.isNotEmpty)
            _DetailRow('ملاحظات', order.notes!),

          // All items in detail
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الأصناف',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
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
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.onSurface,
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
                            if (item.selectedOptions.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: item.selectedOptions.map((opt) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.full),
                                      ),
                                      child: Text(
                                        opt.name,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 9,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      )),
                  if (order.discountAmount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الخصم',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary)),
                        Text(
                          '-${order.discountAmount.toStringAsFixed(0)} ج',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 16, thickness: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجمالي',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.onSurface,
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toStringAsFixed(0)} جنيه',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // ===== TRACKING section =====
          if (!isCancelled || isDelivered) ...[
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'حالة الطلب',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color:
                      isDark ? AppColors.darkTextPrimary : AppColors.onSurface,
                ),
              ),
            ),
            if (!isCancelled)
              OrderStatusTracker.vertical(status: order.status)
            else
              _CancelledBanner(theme: theme),
            if (!isCancelled && activeStep >= 2) ...[
              const SizedBox(height: 12),
              _DriverCard(theme: theme, isDark: isDark),
            ],
          ] else ...[
            const SizedBox(height: 18),
            _CancelledBanner(theme: theme),
          ],

          // ===== ACTION buttons =====
          const SizedBox(height: 16),
          if (isCancelled)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onReorder,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('إعادة الطلب'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
              ),
            )
          else if (isDelivered)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReorder,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('إعادة طلب'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      side: const BorderSide(color: AppColors.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      foregroundColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRateTap,
                    icon: const Icon(Icons.star_outline_rounded, size: 16),
                    label: const Text('قييم الطلب'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      backgroundColor:
                          AppColors.tertiary.withValues(alpha: 0.15),
                      foregroundColor: AppColors.tertiary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTrackTap,
                icon: const Icon(Icons.navigation_outlined, size: 16),
                label: const Text('تتبع حالة الطلب'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ??
                    (isDark ? AppColors.darkTextPrimary : AppColors.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  final ThemeData theme;
  const _CancelledBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cancel_rounded, color: AppColors.error, size: 40),
          const SizedBox(height: 8),
          Text(
            'تم إلغاء الطلب',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'تم إلغاء هذا الطلب بمعرفة المطعم أو العميل. للاستفسار، يرجى التواصل مع الدعم.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.error,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  const _DriverCard({required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محمد علي (مندوب التوصيل)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.onSurface,
                  ),
                ),
                Text(
                  '+20 111 222 3333',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري الاتصال بمندوب التوصيل...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.phone_in_talk_rounded),
            color: AppColors.success,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.success.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }
}
