import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'core/services/push_notification_service.dart';
import 'core/utils/report_date_range.dart';
import 'infrastructure/datasources/local/secure_auth_local_storage.dart';
import 'app/theme/app_theme.dart';
import 'router/app_router.dart';
import 'application/auth/auth_cubit.dart';
import 'application/cart/cart_cubit.dart';
import 'application/theme/theme_cubit.dart';
import 'application/orders/customer_orders_cubit.dart';
import 'application/notifications/notifications_cubit.dart';
import 'core/logger/app_logger.dart';

class DebugBlocObserver extends BlocObserver {
  static const _watched = [
    'AdminCouponsCubit',
    'AdminCustomersCubit',
    'AdminDeliveryZonesCubit',
  ];

  @override
  void onChange(BlocBase bloc, Change change) {
    if (_watched.any((n) => bloc.runtimeType.toString().contains(n))) {
      appLogger
          .i('🟡 [${bloc.runtimeType}] ${change.currentState.runtimeType}');
    }
    super.onChange(bloc, change);
  }

  @override
  void onCreate(BlocBase bloc) {
    if (_watched.any((n) => bloc.runtimeType.toString().contains(n))) {
      appLogger.i('🟢 CREATED [${bloc.runtimeType}]');
    }
    super.onCreate(bloc);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (_watched.any((n) => bloc.runtimeType.toString().contains(n))) {
      appLogger.e('🔴 ERROR [${bloc.runtimeType}] $error');
    }
    super.onError(bloc, error, stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ReportDateRange.ensureInitialized();

  // Initialize Sentry (crash reporting)
  // Set SENTRY_DSN environment variable or use --dart-define
  final sentryDsn = const String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0.1;
        options.sampleRate = 0.1;
      },
    );
  }

  if (!kIsWeb) {
    await Firebase.initializeApp();
  }

  final sharedPrefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final persistSessionKey =
      'sb-${Uri.parse(AppConstants.supabaseUrl).host.split('.').first}-auth-token';

  final authLocalStorage = SecureAuthLocalStorage(
    secureStorage: secureStorage,
    prefs: sharedPrefs,
    persistSessionKey: persistSessionKey,
  );
  await authLocalStorage.initialize();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: authLocalStorage,
    ),
  );
  await initDependencies(
    sharedPreferences: sharedPrefs,
    authLocalStorage: authLocalStorage,
  );

  final pushService = sl<PushNotificationService>();
  if (!kIsWeb) {
    await pushService.init();
    await pushService.handleInitialMessageIfAny();
  }

  Bloc.observer = DebugBlocObserver();

  runApp(const TarwikaApp());
}

class TarwikaApp extends StatefulWidget {
  const TarwikaApp({super.key});

  @override
  State<TarwikaApp> createState() => _TarwikaAppState();
}

class _TarwikaAppState extends State<TarwikaApp> {
  late final ThemeCubit _themeCubit;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _themeCubit = sl<ThemeCubit>();
    _authSub = sl<AuthCubit>().stream.listen(_onAuthChanged);
  }

  void _onAuthChanged(AuthState authState) {
    if (authState is Authenticated) {
      final userId = authState.profile.id;
      sl<NotificationsCubit>().loadNotifications(userId);
      sl<PushNotificationService>().setCurrentUser(userId);
      sl<PushNotificationService>().registerTokenForCurrentUser(
        userIdOverride: userId,
      );
    } else if (authState is Unauthenticated) {
      sl<NotificationsCubit>().switchUser(null);
      sl<PushNotificationService>().setCurrentUser(null);
      unawaited(sl<PushNotificationService>().unregisterCurrentToken());
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (_) => sl<CartCubit>()..loadCart()),
        BlocProvider.value(value: sl<CustomerOrdersCubit>()),
        BlocProvider.value(value: sl<NotificationsCubit>()),
        BlocProvider.value(value: _themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            routerConfig: appRouter,
            builder: (context, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
