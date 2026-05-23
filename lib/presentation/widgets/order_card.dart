import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import 'status_badge.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final DateTime date;
  final String status;
  final int itemCount;
  final double total;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.date,
    required this.status,
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  StatusBadge _statusBadge() {
    return switch (status) {
      'pending' => StatusBadge.pending(),
      'confirmed' => StatusBadge.confirmed(),
      'preparing' => StatusBadge.preparing(),
      'ready' => StatusBadge.ready(),
      'delivered' => StatusBadge.delivered(),
      'cancelled' => StatusBadge.cancelled(),
      _ => StatusBadge(label: status, color: Colors.grey),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.onSurface;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.onSurfaceVariant;

    return Semantics(
      label: 'طلب رقم ${orderId.substring(0, 8)}',
      button: true,
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${orderId.substring(0, 8)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    _statusBadge(),
                  ],
                ),
                AppSpacing.gapH8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryColor,
                      ),
                    ),
                    Text(
                      '$itemCount عناصر',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH8,
                Text(
                  '$total ج',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
