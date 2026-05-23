import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
  });

  factory StatusBadge.pending() => const StatusBadge(
        label: 'قيد الانتظار',
        color: AppColors.statusPending,
      );

  factory StatusBadge.confirmed() => const StatusBadge(
        label: 'تم التأكيد',
        color: AppColors.statusConfirmed,
      );

  factory StatusBadge.preparing() => const StatusBadge(
        label: 'قيد التحضير',
        color: AppColors.statusPreparing,
      );

  factory StatusBadge.ready() => const StatusBadge(
        label: 'جاهز',
        color: AppColors.statusReady,
      );

  factory StatusBadge.delivered() => const StatusBadge(
        label: 'تم التوصيل',
        color: AppColors.statusDelivered,
      );

  factory StatusBadge.cancelled() => const StatusBadge(
        label: 'ملغي',
        color: AppColors.statusCancelled,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? color.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
