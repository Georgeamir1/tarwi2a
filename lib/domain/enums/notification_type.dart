enum NotificationType {
  orderConfirmed('order_confirmed'),
  orderPreparing('order_preparing'),
  orderOutForDelivery('order_out_for_delivery'),
  orderDelivered('order_delivered'),
  orderCancelled('order_cancelled'),
  newOrderAdmin('new_order_admin'),
  orderCancelledAdmin('order_cancelled_admin'),
  promotion('promotion'),
  system('system');

  final String value;
  const NotificationType(this.value);

  factory NotificationType.fromValue(String value) {
    return NotificationType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => NotificationType.system,
    );
  }

  bool get isOrderUpdate =>
      value.startsWith('order_') && !value.endsWith('_admin');
  bool get isAdminNotification => value.endsWith('_admin');
  bool get isOrderAdminNew => this == NotificationType.newOrderAdmin;
  bool get isOrderAdminCancelled =>
      this == NotificationType.orderCancelledAdmin;
  bool get isPromotion => this == NotificationType.promotion;
  bool get isSystem => this == NotificationType.system;
}
