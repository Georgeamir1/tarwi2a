import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../domain/enums/notification_type.dart';

extension NotificationTypeX on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.orderConfirmed:
      case NotificationType.orderPreparing:
      case NotificationType.orderOutForDelivery:
      case NotificationType.orderDelivered:
        return Icons.receipt_long_outlined;
      case NotificationType.orderCancelled:
        return Icons.cancel_outlined;
      case NotificationType.newOrderAdmin:
      case NotificationType.orderCancelledAdmin:
        return Icons.notifications_active_outlined;
      case NotificationType.promotion:
        return Icons.local_offer_outlined;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.orderConfirmed:
      case NotificationType.orderPreparing:
        return AppColors.primary;
      case NotificationType.orderOutForDelivery:
        return AppColors.tertiary;
      case NotificationType.orderDelivered:
        return AppColors.secondary;
      case NotificationType.orderCancelled:
        return AppColors.error;
      case NotificationType.newOrderAdmin:
        return AppColors.primary;
      case NotificationType.orderCancelledAdmin:
        return AppColors.error;
      case NotificationType.promotion:
        return AppColors.tertiary;
      case NotificationType.system:
        return AppColors.onSurfaceVariant;
    }
  }

  String get categoryLabel {
    switch (this) {
      case NotificationType.orderConfirmed:
        return 'تأكيد الطلب';
      case NotificationType.orderPreparing:
        return 'تجهيز الطلب';
      case NotificationType.orderOutForDelivery:
        return 'في الطريق';
      case NotificationType.orderDelivered:
        return 'تم التوصيل';
      case NotificationType.orderCancelled:
        return 'إلغاء الطلب';
      case NotificationType.newOrderAdmin:
        return 'طلب جديد';
      case NotificationType.orderCancelledAdmin:
        return 'إلغاء من العميل';
      case NotificationType.promotion:
        return 'عرض جديد';
      case NotificationType.system:
        return 'تنبيه';
    }
  }
}
