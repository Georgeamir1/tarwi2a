import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../domain/entities/app_notification.dart';
import '../extensions/notification_type_x.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inSeconds < 60) return 'الآن';
    
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      if (m == 1) return 'منذ دقيقة';
      if (m == 2) return 'منذ دقيقتين';
      if (m >= 3 && m <= 10) return 'منذ $m دقائق';
      return 'منذ $m دقيقة';
    }
    
    if (diff.inHours < 24) {
      final h = diff.inHours;
      if (h == 1) return 'منذ ساعة';
      if (h == 2) return 'منذ ساعتين';
      if (h >= 3 && h <= 10) return 'منذ $h ساعات';
      return 'منذ $h ساعة';
    }
    
    if (diff.inDays < 7) {
      final d = diff.inDays;
      if (d == 1) return 'منذ يوم';
      if (d == 2) return 'منذ يومين';
      return 'منذ $d أيام';
    }
    
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      if (w == 1) return 'منذ أسبوع';
      if (w == 2) return 'منذ أسبوعين';
      return 'منذ $w أسابيع';
    }
    
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRead = notification.isRead;
    final typeColor = notification.type.color;
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
            color: typeColor.withValues(alpha: isRead ? 0.08 : 0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            notification.type.icon,
            color: isRead
                ? (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.onSurfaceVariant)
                : typeColor,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.titleAr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              notification.bodyAr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              notification.type.categoryLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: typeColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Text(
          _formatRelativeTime(notification.createdAt),
          style: theme.textTheme.labelSmall?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
