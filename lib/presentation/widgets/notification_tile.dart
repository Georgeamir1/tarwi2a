import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final bool isRead;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    this.isRead = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        tileColor: isDark
            ? (isRead ? AppColors.darkSurface : AppColors.darkCard)
            : (isRead ? Colors.transparent : AppColors.surfaceContainerLow),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isRead ? 0.08 : 0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            icon,
            color: isRead
                ? isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.onSurfaceVariant
                : AppColors.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
        subtitle: Text(
          time,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.onSurfaceVariant,
          ),
        ),
        trailing: !isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
