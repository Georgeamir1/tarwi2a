import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../logger/app_logger.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);
    _initialized = true;
    appLogger.d('[NotificationService] initialized');
  }

  static Future<void> showNewOrderNotification({
    required String orderId,
    required String customerName,
    required double total,
  }) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'new_orders',
      'طلبات جديدة',
      channelDescription: 'إشعارات الطلبات الجديدة',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: orderId.hashCode,
      title: 'طلب جديد! #${orderId.substring(0, 8).toUpperCase()}',
      body: '$customerName — ${total.toStringAsFixed(0)} جنيه',
      notificationDetails: details,
    );
    appLogger.d('[NotificationService] notification shown for order $orderId');
  }
}
