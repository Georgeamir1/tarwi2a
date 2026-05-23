import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class PriceSummary extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double? discount;
  final double? tax;

  const PriceSummary({
    super.key,
    required this.subtotal,
    this.deliveryFee = 0,
    this.discount,
    this.tax,
  });

  double get total {
    var t = subtotal + deliveryFee;
    if (discount != null) t -= discount!;
    if (tax != null) t += tax!;
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.onSurface;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          _RowItem(
            label: 'المجموع الفرعي',
            value: '$subtotal ج',
            textColor: secondaryColor,
          ),
          AppSpacing.gapH8,
          if (deliveryFee > 0)
            _RowItem(
              label: 'التوصيل',
              value: '$deliveryFee ج',
              textColor: secondaryColor,
            ),
          if (deliveryFee > 0) AppSpacing.gapH8,
          if (discount != null && discount! > 0) ...[
            _RowItem(
              label: 'الخصم',
              value: '-${discount!} ج',
              textColor: AppColors.statusReady,
            ),
            AppSpacing.gapH8,
          ],
          if (tax != null && tax! > 0) ...[
            _RowItem(
              label: 'الضريبة',
              value: '$tax ج',
              textColor: secondaryColor,
            ),
            AppSpacing.gapH8,
          ],
          const Divider(height: 1),
          AppSpacing.gapH8,
          _RowItem(
            label: 'الإجمالي',
            value: '${total.toStringAsFixed(2)} ج',
            textColor: textColor,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final bool isBold;

  const _RowItem({
    required this.label,
    required this.value,
    required this.textColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
