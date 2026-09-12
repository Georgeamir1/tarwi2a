import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../logger/app_logger.dart';
import 'device_token_service.dart';
import 'notification_navigation_resolver.dart';

const _kChannelOrders = 'order_updates';
const _kChannelPromotions = 'promotions';
const _kChannelGeneral = 'general';

typedef NavigatorKeyProvider = GoRouter? Function();

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  appLogger.d(
    '[FCM] background message: ${message.notification?.title} '
    'data=${message.data}',
  );
}

class PushNotificationService {
  PushNotificationService({
    DeviceTokenService? deviceTokenService,
    NavigatorKeyProvider? routerProvider,
    NotificationNavigationResolver? resolver,
  })  : _deviceTokenService = deviceTokenService,
        _routerProvider = routerProvider,
        _resolver = resolver;

  final DeviceTokenService? _deviceTokenService;
  final NavigatorKeyProvider? _routerProvider;
  final NotificationNavigationResolver? _resolver;

  String? _pendingRoute;
  String? get pendingRoute => _pendingRoute;

  final FirebaseMessaging? _messaging =
      kIsWeb ? null : FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;
  StreamSubscription<String>? _onTokenRefreshSub;
  String? _lastToken;
  String? _currentUserId;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: _onLocalNotificationTap,
      );

      await _createAndroidChannels();

      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

      _onMessageSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      _onMessageOpenedSub =
          FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
      _onTokenRefreshSub =
          FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefreshed);

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        try {
          await _messaging?.setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
        } catch (e, st) {
          appLogger.e('[FCM] iOS presentation options failed',
              error: e, stackTrace: st);
        }
      }

      _initialized = true;
      appLogger.d('[FCM] PushNotificationService initialized');
    } catch (e, st) {
      appLogger.e('[FCM] init failed', error: e, stackTrace: st);
    }
  }

  Future<void> _onTokenRefreshed(String newToken) async {
    appLogger.d('[FCM] token refreshed: ${newToken.substring(0, 12)}…');
    final userId = _currentUserId;
    if (userId == null) {
      appLogger.w('[FCM] no current user — skipping refresh registration');
      return;
    }
    try {
      await _deviceTokenService?.registerToken(
        token: newToken,
        userId: userId,
      );
      _lastToken = newToken;
      appLogger.d('[FCM] refreshed token registered for user $userId');
    } catch (e, st) {
      appLogger.e('[FCM] failed to register refreshed token',
          error: e, stackTrace: st);
    }
  }

  void setCurrentUser(String? userId) {
    _currentUserId = userId;
    appLogger.d('[FCM] current user set: $userId');
    if (userId == null) {
      _pendingRoute = null;
    } else {
      flushPendingNavigation();
    }
  }

  void flushPendingNavigation() {
    if (_pendingRoute == null) return;
    final router = _routerProvider?.call();
    if (router == null || _currentUserId == null) return;
    final route = _pendingRoute!;
    _pendingRoute = null;
    try {
      router.go(route);
      appLogger.i('[FCM] flushed deferred navigation to $route');
    } catch (e) {
      appLogger.e('[FCM] flush navigation failed to $route', error: e);
    }
  }

  Future<bool> requestPermissionWithPriming(BuildContext context) async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ابق على اطلاع'),
        content: const Text(
          'نرسلك إشعارات فورية عند:\n'
          '• تحديث حالة طلبك\n'
          '• عروضنا الجديدة\n\n'
          'تقدر تلغي التفعيل في أي وقت من الإعدادات.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('لاحقاً'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );

    if (agreed != true) return false;
    return await _requestSystemPermission();
  }

  Future<bool> _requestSystemPermission() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final androidImpl = _local.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted =
            await androidImpl?.requestNotificationsPermission() ?? true;
        appLogger.d('[FCM] Android POST_NOTIFICATIONS granted: $granted');
        if (!granted) return false;
      }

      final settings = await _messaging?.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      final granted =
          settings?.authorizationStatus == AuthorizationStatus.authorized ||
              settings?.authorizationStatus == AuthorizationStatus.provisional;
      appLogger.d('[FCM] permission status: ${settings?.authorizationStatus}');
      return granted;
    } catch (e, st) {
      appLogger.e('[FCM] requestPermission failed', error: e, stackTrace: st);
      return false;
    }
  }

  Future<void> registerTokenForCurrentUser({String? userIdOverride}) async {
    if (kIsWeb) {
      appLogger.d('[FCM] web platform — skipping token registration');
      return;
    }
    final service = _deviceTokenService;
    if (service == null) {
      appLogger
          .w('[FCM] DeviceTokenService not injected — token not registered');
      return;
    }
    try {
      final userId =
          userIdOverride ?? Supabase.instance.client.auth.currentUser?.id ?? '';
      if (userId.isEmpty) {
        appLogger.w('[FCM] no logged-in user — skipping token registration');
        return;
      }
      _currentUserId = userId;
      await _messaging?.requestPermission();
      final token = await _messaging?.getToken();
      if (token == null || token.isEmpty) {
        appLogger.w('[FCM] getToken returned null/empty — FCM not available');
        return;
      }
      if (token == _lastToken) return;
      _lastToken = token;
      final platform =
          defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
      await service.registerToken(
          token: token, userId: userId, platform: platform);
      appLogger.d('[FCM] token registered for user $userId ($platform)');
    } catch (e, st) {
      appLogger.e('[FCM] registerTokenForCurrentUser failed',
          error: e, stackTrace: st);
    }
  }

  Future<void> unregisterCurrentToken() async {
    try {
      final token = await _messaging?.getToken();
      if (token == null) return;
      await _deviceTokenService?.unregisterToken(token: token);
      await _messaging?.deleteToken();
      _lastToken = null;
      appLogger.d('[FCM] token unregistered');
    } catch (e, st) {
      appLogger.e('[FCM] unregister failed', error: e, stackTrace: st);
    }
  }

  Future<void> clearBadge() async {
    try {
      await _local
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(badge: true);
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.cancelAll();
    } catch (e, st) {
      appLogger.e('[FCM] clearBadge failed', error: e, stackTrace: st);
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    appLogger.d('[FCM] foreground: ${message.notification?.title}');
    final notif = message.notification;
    if (notif == null) return;
    await _showLocal(
      id: message.messageId?.hashCode ?? message.hashCode,
      title: notif.title ?? '',
      body: notif.body ?? '',
      payload: message.data,
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    appLogger.d('[FCM] opened from background: ${message.data}');
    _navigateFromData(message.data);
  }

  Future<void> handleInitialMessageIfAny() async {
    try {
      final initial = await _messaging?.getInitialMessage();
      if (initial != null) {
        appLogger.d('[FCM] launched from terminated: ${initial.data}');
        _navigateFromData(initial.data);
      }
    } catch (e, st) {
      appLogger.e('[FCM] getInitialMessage failed', error: e, stackTrace: st);
    }
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (e) {
      appLogger.e('[FCM] local tap payload parse failed', error: e);
    }
  }

  Future<void> _navigateFromData(Map<String, dynamic> data) async {
    String? targetRoute;
    if (_resolver != null) {
      targetRoute = await _resolver.resolveRoute(data);
    } else {
      final refType = data['reference_type'] as String?;
      final refId = data['reference_id'] as String?;
      if (refType == 'order' && refId != null && refId.trim().isNotEmpty) {
        targetRoute = '/orders?expand=${Uri.encodeComponent(refId.trim())}';
      }
    }

    if (targetRoute == null) return;

    final router = _routerProvider?.call();
    if (router == null || _currentUserId == null) {
      _pendingRoute = targetRoute;
      appLogger.d(
          '[FCM] navigation deferred (cold-start / waiting for auth): $targetRoute');
      return;
    }

    try {
      router.go(targetRoute);
      appLogger.i('[FCM] navigated to $targetRoute');
    } catch (e) {
      appLogger.e('[FCM] navigation failed to $targetRoute', error: e);
    }
  }

  Future<void> _showLocal({
    required int id,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    final type = payload['type'] as String? ?? '';
    final channelId = _channelIdFor(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _channelNameFor(channelId),
      channelDescription: _channelDescFor(channelId),
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

    await _local.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: jsonEncode(payload),
    );
  }

  Future<void> _createAndroidChannels() async {
    final android = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    const orderChannel = AndroidNotificationChannel(
      _kChannelOrders,
      'تحديثات الطلبات',
      description: 'إشعارات حالة الطلب (تأكيد، تجهيز، توصيل)',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    const promoChannel = AndroidNotificationChannel(
      _kChannelPromotions,
      'العروض والتخفيضات',
      description: 'إشعارات العروض والكوبونات',
      importance: Importance.defaultImportance,
      playSound: true,
    );
    const generalChannel = AndroidNotificationChannel(
      _kChannelGeneral,
      'إشعارات عامة',
      description: 'إشعارات النظام',
      importance: Importance.defaultImportance,
    );

    await android.createNotificationChannel(orderChannel);
    await android.createNotificationChannel(promoChannel);
    await android.createNotificationChannel(generalChannel);
  }

  String _channelIdFor(String type) {
    if (type.startsWith('order_')) return _kChannelOrders;
    if (type == 'promotion') return _kChannelPromotions;
    return _kChannelGeneral;
  }

  String _channelNameFor(String channelId) {
    switch (channelId) {
      case _kChannelOrders:
        return 'تحديثات الطلبات';
      case _kChannelPromotions:
        return 'العروض والتخفيضات';
      default:
        return 'إشعارات عامة';
    }
  }

  String _channelDescFor(String channelId) {
    switch (channelId) {
      case _kChannelOrders:
        return 'إشعارات حالة الطلب (تأكيد، تجهيز، توصيل)';
      case _kChannelPromotions:
        return 'إشعارات العروض والكوبونات';
      default:
        return 'إشعارات النظام';
    }
  }

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onMessageOpenedSub?.cancel();
    await _onTokenRefreshSub?.cancel();
  }
}
