import 'package:flutter/material.dart';
import '../../../domain/enums/order_status.dart';
import '../../../app/theme/app_theme.dart';

extension OrderStatusX on OrderStatus {
  String get arabicLabel {
    switch (this) {
      case OrderStatus.pending:
        return 'في الانتظار';
      case OrderStatus.confirmed:
        return 'تم التأكيد';
      case OrderStatus.preparing:
        return 'جاري التحضير';
      case OrderStatus.ready:
        return 'جاهز للاستلام';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.confirmed:
        return AppColors.statusConfirmed;
      case OrderStatus.preparing:
        return AppColors.statusPreparing;
      case OrderStatus.ready:
        return AppColors.statusReady;
      case OrderStatus.delivered:
        return AppColors.statusDelivered;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing:
        return Icons.restaurant_rounded;
      case OrderStatus.ready:
        return Icons.shopping_bag_outlined;
      case OrderStatus.delivered:
        return Icons.task_alt_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  int get progressIndex {
    switch (this) {
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

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'طلبك وصل للمطعم وبانتظار التأكيد';
      case OrderStatus.confirmed:
        return 'تمت مراجعة الطلب والموافقة عليه';
      case OrderStatus.preparing:
        return 'طهاة ترويقة يحضرون وجبتك اللذيذة الآن';
      case OrderStatus.ready:
        return 'طعامك جاهز وبانتظار مندوب التوصيل';
      case OrderStatus.delivered:
        return 'تم التوصيل بنجاح — بالهنا والشفا!';
      case OrderStatus.cancelled:
        return 'تم إلغاء هذا الطلب';
    }
  }

  static List<Map<String, dynamic>> get steps {
    return const [
      {
        'label': 'تم الطلب',
        'icon': Icons.receipt_long_rounded,
        'desc': 'طلبك وصل للمطعم وبانتظار التأكيد',
      },
      {
        'label': 'تأكيد',
        'icon': Icons.thumb_up_alt_outlined,
        'desc': 'تمت مراجعة الطلب والموافقة عليه',
      },
      {
        'label': 'التحضير',
        'icon': Icons.restaurant_rounded,
        'desc': 'طهاة ترويقة يحضرون وجبتك اللذيذة الآن',
      },
      {
        'label': 'جاهز',
        'icon': Icons.delivery_dining_rounded,
        'desc': 'طعامك جاهز بانتظار التوصيل',
      },
      {
        'label': 'توصيل',
        'icon': Icons.check_circle_outline_rounded,
        'desc': 'تم التوصيل بنجاح — بالهنا والشفا!',
      },
    ];
  }
}
